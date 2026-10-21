import "package:http/http.dart" as http;

class Connector {
  late final http.Client client;
  late final String basePath;
  late final String domain;

  Connector(String srvDomain) {
    basePath = "/api/";
    domain = srvDomain;
    client = http.Client();
  }

  ///Method to request a ping to the server. Returns a bool representing success of request
  Future<bool> ping() async {
    var response = await client.get(Uri.http(domain, basePath));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
