import 'package:doghree_rider/api/api_client.dart';
import 'package:get/get.dart';

/// Records GET calls and returns a canned response. No network.
class FakeApiClient extends ApiClient {
  Response nextResponse;
  final List<String> getUris = [];
  final List<bool> getHandleErrors = [];

  FakeApiClient({
    required super.sharedPreferences,
    this.nextResponse = const Response(statusCode: 200),
  }) : super(appBaseUrl: 'http://fake.local');

  @override
  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    getUris.add(uri);
    getHandleErrors.add(handleError);
    return nextResponse;
  }
}
