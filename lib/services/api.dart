import 'dart:convert';
import 'dart:io';

import 'package:lilypad/services/session.dart';
import 'package:lilypad/util/api_ex.dart';

import 'log.dart';

import "package:http/http.dart";

class APIService {
  static final Client _client = Client();
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
  static Future<Response> send(Request req) async {
    //get cookier header from session
    String? cHeader = SessionService.getCookieHeader();

    //append to header if cookies not null
    if (cHeader != null) {
      req.headers['Cookie'] = cHeader;
      req.headers['Origin'] = 'http://$_domain';
    }

    try {
      LogService.log(
        '${req.method} at ${req.url.toString()}',
        src: 'API Service',
      );
      LogService.log('Request Headers=${req.headers}', src: 'API Service');
      LogService.log('Request Body=${req.body}', src: 'API Service');

      //send request to server
      final responseStream = await _client.send(req);

      //check response code
      if (responseStream.statusCode == 200) {
        //capture any set-cookie from request
        if (responseStream.headers['set-cookie'] != null &&
            responseStream.headers['set-cookie'] != '') {
          SessionService.capture(responseStream.headers['set-cookie']!);
        }

        //await response completion
        final Response res = await Response.fromStream(responseStream);

        LogService.log(
          'Response recieved. Total ${res.contentLength} Bytes recieved from server.',
          src: 'API Service',
        );
        LogService.log('Response Headers=${res.headers}', src: 'API Service');
        LogService.log('Response Body=${res.body}', src: 'API Service');

        return res;
      } else {
        //await response completion
        final Response res = await Response.fromStream(responseStream);

        LogService.log(
          'Response recieved. Total ${res.contentLength} Bytes recieved from server.',
          src: 'API Service',
        );
        LogService.log('Response Headers=${res.headers}', src: 'API Service');
        LogService.log('Response Headers=${res.body}', src: 'API Service');
        LogService.err(
          'HTTP ${res.statusCode} - ${res.reasonPhrase}',
          src: 'API Service',
        );

        //check if session invalid
        if (res.statusCode == 401) {
          //clear session cookies
          SessionService.clear();
        } else {
          //capture any set-cookie from request
          if (res.headers['set-cookie'] != null &&
              res.headers['set-cookie'] != '') {
            SessionService.capture(res.headers['set-cookie']!);
          }
        }

        throw APIException(
          '${jsonDecode(res.body)['error'] ?? jsonDecode(res.body)['message']}',
          uri: req.url,
          statusCode: res.statusCode,
        );
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
