import 'dart:io';
import 'log.dart';
import "package:http/http.dart" as http;

class APIService {
  static final http.Client client = http.Client();
  static final String basePath = '/api/';
  static final String domain = 'localhost:3000';

  ///Method to request a ping to the server. Returns a bool representing success of request.
  static Future<bool> ping() async {
    final uri = Uri.http(domain, basePath);

    try {
      LogService.log('Pinging Server at ${uri.toString()}', src: 'API Service');
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        LogService.log('Ping Recieved', src: 'API Service');
        return true;
      } else {
        throw HttpException(
          'HTTP ${response.statusCode} - ${response.reasonPhrase}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      LogService.err(e.message, code: e.osError?.errorCode, ex: e, src: 'API Service');
      return false;
    } on HttpException catch (e) {
      LogService.err(e.message, ex: e, src: 'API Service');
      return false;
    } finally {
      client.close();
    }
  }
}
