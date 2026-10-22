import "package:http/http.dart" as http;

class APIService {
  static final http.Client client = http.Client();
  static final String basePath = '/api/';
  static final String domain = 'localhost:3000';

  ///Method to request a ping to the server. Returns a bool representing success of request.
  static Future<bool> ping() async {
    var response = await client.get(Uri.http(domain, basePath));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
