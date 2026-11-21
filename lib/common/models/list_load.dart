import 'package:get/get.dart';

/// A list fetched silently, plus what the caller needs to choose a message:
/// the status code and the server's text (D-12). [list] is null on failure.
class ListLoad<T> {
  final List<T>? list;
  final int? statusCode;
  final String? message;

  const ListLoad(this.list, {this.statusCode, this.message});

  /// A failed or unreadable response: no list, its status and text.
  ListLoad.failed(Response response)
      : list = null,
        statusCode = response.statusCode,
        message = response.statusText;

  bool get ok => list != null;
}
