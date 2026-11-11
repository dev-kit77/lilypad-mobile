import 'dart:io';

import 'package:lilypad/services/session.dart';

import 'log.dart';

import "package:http/http.dart" as http;

class APIService {
  static final http.Client _client = http.Client();
  static const String _basePath = '/api/';
  static const String _domain = 'localhost:3000';

  APIService._();

  ///Method to build a uri object from a given path
  static Uri getUri({String path = ''}) {
    return Uri.http(_domain, '$_basePath$path');
  }

  ///Method to request a ping to the server. Returns a bool representing success of request.
  static Future<bool> ping() async {
    //get uri
    final uri = getUri();

    try {
      LogService.log(
        'Pinging Server at ${uri.toString()}.',
        src: 'API Service',
      );
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        LogService.log('Ping Recieved.', src: 'API Service');
        return true;
      } else {
        throw HttpException(
          'HTTP ${response.statusCode} - ${response.reasonPhrase}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      LogService.err(
        e.message,
        code: e.osError?.errorCode,
        ex: e,
        src: 'API Service',
      );
      return false;
    } on HttpException catch (e) {
      LogService.err(e.message, ex: e, src: 'API Service');
      return false;
    }
  }

  ///Method to send a request to the server. Returns a response object if server reached or throws upon client error.
  static Future<http.StreamedResponse> send(http.Request req) async {
    //get cookier header from session
    String? cHeader = SessionService.getCookieHeader();

    //append cookies to header if not null
    if (cHeader != null) {
      req.headers['Cookie'] = cHeader;
    }

    try {
      LogService.log(
        '${req.method} at ${req.url.toString()}',
        src: 'API Service',
      );
      //send request to server
      final response = await _client.send(req);

      //check response code
      if (response.statusCode == 200) {
        LogService.log(
          '${response.contentLength} Bytes recieved from server.',
          src: 'API Service',
        );

        //capture any set-cookie from request
        if (response.headers['set-cookie'] != null &&
            response.headers['set-cookie'] != '') {
          SessionService.capture(response.headers['set-cookie']!);
        }

        return response;
      } else {
        LogService.log(
          '${response.contentLength} Bytes recieved from server.',
          src: 'API Service',
        );

        LogService.err(
          'HTTP ${response.statusCode} - ${response.reasonPhrase}',
          src: 'API Service',
        );

        //check if session invalid
        if (response.statusCode == 401) {
          //clear session cookies
          SessionService.clear();
        } else {
          //capture any set-cookie from request
          if (response.headers['set-cookie'] != null &&
              response.headers['set-cookie'] != '') {
            SessionService.capture(response.headers['set-cookie']!);
          }
        }

        return response;
      }
    } on SocketException catch (e) {
      LogService.err(
        e.message,
        code: e.osError?.errorCode,
        ex: e,
        src: 'API Service',
      );
      rethrow;
    }
  }

  ///Method to close the client for application shutdown
  static void close() {
    _client.close();
  }
}
