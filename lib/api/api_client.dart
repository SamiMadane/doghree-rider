import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_error_handler.dart';
import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
import 'package:doghree_rider/api/log_sanitizer.dart';
import 'package:doghree_rider/util/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    updateHeader(token, sharedPreferences.getString(AppConstants.languageCode));
  }

  void updateHeader(String? token, String? languageCode) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      AppConstants.localizationKey:
          languageCode ?? AppConstants.languages[0].languageCode!,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Debug only. Every line goes through [LogSanitizer]; exceptions are logged
  /// by type only because their text can contain the full request URL.
  void _log(String m) {
    if (foundation.kDebugMode) debugPrint(LogSanitizer.text(m));
  }

  // ---------- نقطة الإرسال الوحيدة ----------
  Future<Response> _send(String uri, Future<http.Response> Function() call,
      bool handleError, {Map<String, dynamic>? query}) async {
    try {
      final String keys =
          (query == null || query.isEmpty) ? '' : ' query: ${query.keys.join(',')}';
      _log('API ▶ $uri$keys [${_mainHeaders[AppConstants.localizationKey]}]');
      final res = await call().timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(res, uri, handleError);
    } catch (e) {
      return _failure(e, uri);
    }
  }

  Response _failure(Object e, String uri) {
    _log('API ✖ $uri → ${e.runtimeType}');
    if (e is SocketException ||
        e is TimeoutException ||
        e is http.ClientException) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
    // أي خطأ آخر (تحليل، منطق) ما بنسمّيه "لا يوجد إنترنت"
    return Response(
        statusCode: 0, statusText: ErrorMessages.getMessage(ErrorType.unknown));
  }

  Future<Response> getData(String uri,
          {Map<String, dynamic>? query,
          Map<String, String>? headers,
          bool handleError = true}) =>
      _send(uri, () {
        var url = Uri.parse(appBaseUrl + uri);
        if (query != null && query.isNotEmpty) {
          url = url.replace(queryParameters: {
            ...url.queryParameters,
            ...query.map((k, v) => MapEntry(k, '$v')),
          });
        }
        return http.get(url, headers: headers ?? _mainHeaders);
      }, handleError, query: query);

  /// Binary download (audit row 41). Always silent: the caller shows the one
  /// message. Sends the normal headers (Bearer), never a token in the query.
  /// On 200 the body is the raw `Uint8List`; see [handleBytesResponse].
  Future<Response> getBytes(String uri, {Map<String, dynamic>? query}) async {
    try {
      final String keys =
          (query == null || query.isEmpty) ? '' : ' query: ${query.keys.join(',')}';
      _log('API ▶ $uri (bytes)$keys');
      var url = Uri.parse(appBaseUrl + uri);
      if (query != null && query.isNotEmpty) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          ...query.map((k, v) => MapEntry(k, '$v')),
        });
      }
      final res = await http
          .get(url, headers: _mainHeaders)
          .timeout(const Duration(seconds: 60));
      _log('API ◀ $uri ${res.statusCode} (${res.bodyBytes.length} bytes)');
      return handleBytesResponse(res);
    } catch (e) {
      return _failure(e, uri);
    }
  }

  /// 200: `body` is the untouched `bodyBytes`, whatever the charset header
  /// says. Otherwise the body is decoded leniently for the server message.
  static Response handleBytesResponse(http.Response response) {
    if (response.statusCode == 200) {
      return Response(
        body: response.bodyBytes,
        headers: response.headers,
        statusCode: 200,
      );
    }
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
    } catch (_) {}
    return Response(
      body: body,
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: ApiErrorHandler.extractMessage(body) ??
          ErrorMessages.getMessage(
              ApiErrorHandler.getErrorType(response.statusCode)),
    );
  }

  Future<Response> postData(String uri, dynamic body,
          {Map<String, String>? headers, bool handleError = true}) =>
      _send(
          uri,
          () => http.post(Uri.parse(appBaseUrl + uri),
              body: jsonEncode(body), headers: headers ?? _mainHeaders),
          handleError);

  Future<Response> putData(String uri, dynamic body,
          {Map<String, String>? headers, bool handleError = true}) =>
      _send(
          uri,
          () => http.put(Uri.parse(appBaseUrl + uri),
              body: jsonEncode(body), headers: headers ?? _mainHeaders),
          handleError);

  Future<Response> patchData(String uri, dynamic body,
          {Map<String, String>? headers, bool handleError = true}) =>
      _send(
          uri,
          () => http.patch(Uri.parse(appBaseUrl + uri),
              body: jsonEncode(body), headers: headers ?? _mainHeaders),
          handleError);

  Future<Response> deleteData(String uri,
          {Map<String, String>? headers, bool handleError = true}) =>
      _send(
          uri,
          () => http.delete(Uri.parse(appBaseUrl + uri),
              headers: headers ?? _mainHeaders),
          handleError);

  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      _log('API ▶ $uri (multipart, ${multipartBody.length} files)');
      final request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for (final multipart in multipartBody) {
        if (multipart.file == null) continue;
        final name = p.basename(multipart.file!.path);
        final type = _mediaType(name);
        if (foundation.kIsWeb) {
          final Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(multipart.key, list,
              filename: name, contentType: type));
        } else {
          final file = File(multipart.file!.path);
          request.files.add(http.MultipartFile(
              multipart.key, file.openRead(), file.lengthSync(),
              filename: name, contentType: type));
        }
      }
      request.fields.addAll(body);
      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      return handleResponse(res, uri, handleError);
    } catch (e) {
      return _failure(e, uri);
    }
  }

  MediaType _mediaType(String filename) {
    switch (p.extension(filename).toLowerCase()) {
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.pdf':
        return MediaType('application', 'pdf');
      case '.jpg':
      case '.jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  // ---------- معالجة الجواب (المكان الوحيد للأخطاء) ----------
  Response handleResponse(
      http.Response response, String uri, bool handleError) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}

    final bool ok = response.statusCode == 200;
    final String? statusText = ok
        ? response.reasonPhrase
        : (ApiErrorHandler.extractMessage(body) ??
            ErrorMessages.getMessage(
                ApiErrorHandler.getErrorType(response.statusCode)));

    final Response result = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: statusText,
    );

    if (!handleError) return result;
    if (ok) return result;

    ApiChecker.checkApi(result, sessionAware: !uri.contains('/auth/'));
    return const Response();
  }
}

class MultipartBody {
  String key;
  XFile? file;
  MultipartBody(this.key, this.file);
}
