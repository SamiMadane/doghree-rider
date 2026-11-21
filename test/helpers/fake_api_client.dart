import 'package:doghree_rider/api/api_client.dart';
import 'package:get/get.dart';

/// One recorded request. No network is used.
class RecordedCall {
  final String method;
  final String uri;
  final Map<String, dynamic>? query;
  final dynamic body;
  final bool handleError;
  RecordedCall(this.method, this.uri, this.query, this.body, this.handleError);
}

/// Records every call and returns a canned response. No network.
class FakeApiClient extends ApiClient {
  Response nextResponse;
  final List<String> getUris = [];
  final List<bool> getHandleErrors = [];
  final List<RecordedCall> calls = [];

  FakeApiClient({
    required super.sharedPreferences,
    this.nextResponse = const Response(statusCode: 200),
  }) : super(appBaseUrl: 'http://fake.local');

  RecordedCall get last => calls.last;

  @override
  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    getUris.add(uri);
    getHandleErrors.add(handleError);
    calls.add(RecordedCall('GET', uri, query, null, handleError));
    return nextResponse;
  }

  @override
  Future<Response> getBytes(String uri, {Map<String, dynamic>? query}) async {
    calls.add(RecordedCall('BYTES', uri, query, null, false));
    return nextResponse;
  }

  @override
  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    calls.add(RecordedCall('POST', uri, null, body, handleError));
    return nextResponse;
  }

  @override
  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    calls.add(RecordedCall('PUT', uri, null, body, handleError));
    return nextResponse;
  }

  @override
  Future<Response> patchData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    calls.add(RecordedCall('PATCH', uri, null, body, handleError));
    return nextResponse;
  }

  @override
  Future<Response> deleteData(String uri,
      {Map<String, String>? headers, bool handleError = true}) async {
    calls.add(RecordedCall('DELETE', uri, null, null, handleError));
    return nextResponse;
  }

  @override
  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers, bool handleError = true}) async {
    calls.add(RecordedCall('MULTIPART', uri, null, body, handleError));
    return nextResponse;
  }
}
