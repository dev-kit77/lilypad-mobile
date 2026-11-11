import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lilypad/services/log.dart';

class SessionService {
  static const _key = 'lilypad_cookies';
  static const _storage = FlutterSecureStorage();
  static final List<Cookie> _cookies = <Cookie>[];

  SessionService._();

  ///helper for checking if cookies are expired
  static bool _isExpired(Cookie c) {
    return ((c.maxAge != null && c.maxAge! <= 0) ||
        (c.expires?.isBefore(DateTime.now()) ?? false) ||
        c.value.isEmpty);
  }

  ///check for if any stored session cookies
  static bool get activeSession => _cookies.isNotEmpty;

  //init method to
  static Future<void> init() async {
    //clear cookie values
    _cookies.clear();

    //get stored cookies
    String? storedCookieString = await _storage.read(key: _key);

    //check for null storage
    if (storedCookieString != null) {
      //init list of strings
      List<dynamic> cookieStrings;

      //decode into list of cookie strings
      try {
        cookieStrings = jsonDecode(storedCookieString);
      } on FormatException catch (e) {
        LogService.warn(
          'Session Storage Malformed: ${e.message}',
          src: 'Session Service',
        );
        LogService.warn(
          'Cached cookies will not be loaded!',
          src: 'Session Service',
        );
        //exit as no cookies to be loaded
        return;
      }

      //init bad cookie list
      List<Cookie> badCookies = <Cookie>[];

      //for each string
      for (dynamic cookieString in cookieStrings) {
        if (cookieString is! String) {
          continue;
        }
        try {
          //extract to cookie type
          Cookie newCookie = Cookie.fromSetCookieValue(cookieString.trim());

          //skip if expired
          if (_isExpired(newCookie)) {
            continue;
          }

          //loop for exising cookies
          for (Cookie currCookie in _cookies) {
            //check for old/duplicate cookie
            if (currCookie.name == newCookie.name) {
              //set cookie for removal
              badCookies.add(currCookie);
            }
          }

          //add new cookie
          _cookies.add(newCookie);
        } on HttpException catch (e) {
          LogService.warn(
            'Skipping malformed cookie: ${e.message}',
            src: 'Session Service',
          );
        } on FormatException catch (e) {
          LogService.warn(
            'Skipping malformed cookie: ${e.message}',
            src: 'Session Service',
          );
        }

        //remove bad cookies
        _cookies.removeWhere((c) => badCookies.contains(c));
      }

      LogService.log('Cookies Retrieved.', src: 'Session Service');
    } else {
      LogService.log('No cached cookies found.', src: 'Session Service');
    }
  }

  ///method to parse the set-cookie string into a list of cookies stored as a key/val map
  static List<Cookie> parseSetCookie(String setCookie) {
    final split = RegExp(r",(?=\s*[!#$%&'*+\-.^_`|~0-9A-Za-z]+=)");

    //create list of cookies
    List<Cookie> cookieList = <Cookie>[];

    //split set cookie into individual cookies using regex matching
    List<String> setCookiePart = setCookie.split(split);

    //itterate cookies
    for (String cookiePart in setCookiePart) {
      //check for empty string
      if (cookiePart.trim().isEmpty) continue;
      try {
        //parse cookie frm string
        cookieList.add(Cookie.fromSetCookieValue(cookiePart.trim()));
      } on HttpException catch (e) {
        LogService.warn(
          'Skipping malformed cookie: ${e.message}',
          src: 'Session Service',
        );
      } on FormatException catch (e) {
        LogService.warn(
          'Skipping malformed cookie: ${e.message}',
          src: 'Session Service',
        );
      }
    }

    //return list of cookies
    return cookieList;
  }

  static Future<void> capture(String setCookie) async {
    List<Cookie> newCookies = parseSetCookie(setCookie);
    List<Cookie> badCookies = <Cookie>[];

    //loop for all cookies being set
    for (Cookie newCookie in newCookies) {
      for (Cookie currCookie in _cookies) {
        //check for old cookie
        if (currCookie.name == newCookie.name) {
          //set old cookie for removal
          badCookies.add(currCookie);
        }
      }

      //add new cookie
      _cookies.add(newCookie);
    }

    //remove all old cookies
    _cookies.removeWhere((c) => _isExpired(c));
    _cookies.removeWhere((c) => badCookies.contains(c));

    //update storage with list of cookie objects
    await _storage.write(
      key: _key,
      value: jsonEncode(_cookies.map((Cookie c) => c.toString()).toList()),
    );

    LogService.log('Cookies cached to local', src: 'Session Service');
  }

  ///function to create the cookie header for sending requests
  static String? getCookieHeader() {
    //init header
    String? header;

    //loop for all cookies
    for (Cookie currCookie in _cookies) {
      //check if header empty
      if (header == null) {
        //add base cookie
        header = '${currCookie.name}=${currCookie.value}';
      } else {
        //add extra cookie
        header += '; ${currCookie.name}=${currCookie.value}';
      }
    }

    return header;
  }

  ///function to clear cookies from memory and storage
  static Future<void> clear() async {
    //clear from memory
    _cookies.clear();

    //clear storage
    await _storage.delete(key: _key);

    LogService.log('Cached cookies cleared.', src: 'Session Service');
  }
}
