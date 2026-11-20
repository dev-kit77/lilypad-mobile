import 'dart:io';

class APIException extends HttpException {
  int? statusCode;

  APIException(super.message, {super.uri, this.statusCode});
}
