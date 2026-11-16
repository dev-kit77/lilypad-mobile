import 'dart:convert';

import 'package:http/http.dart';

///A canned response for stub client to return.
class StubResponse {
  StubResponse(
    this.statusCode, {
    this.headers = const <String, String>{},
    this.body = '',
  }) : error = null;

  ///A canned response that fails the request as if the connection dropped.
  StubResponse.error(this.error)
    : statusCode = 0,
      headers = const <String, String>{},
      body = '';

  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final Exception? error;
}

///A request captured by stub client
class RecordedRequest {
  RecordedRequest(this.request, this.body);

  final BaseRequest request;
  final String body;
}

/// Stands in for the HTTP clients the app creates internally recording
/// every request it is asked to send and replies with cannedresponses.
class StubClient extends BaseClient {
  final List<RecordedRequest> requests = <RecordedRequest>[];
  final List<StubResponse> _responses = <StubResponse>[];

  static const Map<int, String> _reasonPhrases = <int, String>{
    200: 'OK',
    401: 'Unauthorized',
    500: 'Internal Server Error',
  };

  ///url of the most recent request or null
  Uri? get lastRequestUrl =>
      requests.isEmpty ? null : requests.last.request.url;

  ///queues a canned response for the next request the stub receives.
  void queueResponse(StubResponse response) => _responses.add(response);

  ///queues a json response for the next request the stub receives.
  void queueJson(Object body) => queueResponse(
    StubResponse(
      200,
      headers: const <String, String>{'content-type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  ///queues a response with an empty body and the given status code.
  void queueStatus(int statusCode) => queueResponse(StubResponse(statusCode));

  ///forgets all queued responses and recorded requests.
  void reset() {
    _responses.clear();
    requests.clear();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final String body = await utf8.decoder.bind(request.finalize()).join();
    requests.add(RecordedRequest(request, body));

    if (_responses.isEmpty) {
      throw StateError(
        'StubClient received a ${request.method} request at '
        '${request.url} but no response was queued for it.',
      );
    }

    final StubResponse response = _responses.removeAt(0);

    //fail the request as if the connection dropped before the server answered.
    final Exception? error = response.error;
    if (error != null) {
      throw error;
    }

    final List<int> bytes = utf8.encode(response.body);

    return StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      contentLength: bytes.length,
      reasonPhrase: _reasonPhrases[response.statusCode] ?? 'Unknown',
      headers: response.headers,
    );
  }
}
