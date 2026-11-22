/// One object fetched silently, plus its status code, so the screen can pick
/// its failure state (D-13). [data] is null on failure. The single-object
/// counterpart of `ListLoad`.
class DataLoad<T> {
  final T? data;

  /// 200 on success. On failure the response status, 1 for no internet, or
  /// 0 when a 200 did not have the expected shape.
  final int? statusCode;

  const DataLoad(this.data, {this.statusCode});

  const DataLoad.failed(this.statusCode) : data = null;

  bool get ok => data != null;
}
