import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/data_load.dart';
import 'package:doghree_rider/features/html/domain/repositories/html_repository_interface.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/util/app_constants.dart';

class HtmlRepository implements HtmlRepositoryInterface {
  final ApiClient apiClient;
  HtmlRepository({required this.apiClient});

  /// Silent (D-13): the page shows its own failure state. Only the expected
  /// shape is accepted (see [readHtmlText]).
  @override
  Future<DataLoad<String>> getHtmlText(bool isPrivacyPolicy) async {
    final Response response = await apiClient.getData(
      isPrivacyPolicy ? AppConstants.privacyPolicyUri : AppConstants.tramsAndConditionUri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'moduleId': '',
        AppConstants.localizationKey: Get.find<LocalizationController>().locale.languageCode,
      },
      handleError: false,
    );
    ApiChecker.checkSession(response);
    if (response.statusCode != 200) return DataLoad<String>.failed(response.statusCode);
    final String? text = readHtmlText(response.bodyString);
    return text == null
        ? const DataLoad<String>.failed(0)
        : DataLoad<String>(text, statusCode: 200);
  }

  /// The page text from the raw body. The server sends it as a JSON string
  /// (observed 2026-11-22: `""` for both pages).
  ///
  /// - An empty body, `""` or `null` is an empty page: a success with no text.
  /// - A JSON string is the page.
  /// - Anything else (for example the HTML login page of a captive Wi-Fi) is
  ///   not this page: null, a failure. Both a JSON string and raw HTML arrive
  ///   in `Response.body` as a String, so only the raw body tells them apart.
  @visibleForTesting
  static String? readHtmlText(String? rawBody) {
    final String raw = rawBody?.trim() ?? '';
    if (raw.isEmpty) return '';
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded == null) return '';
      return decoded is String ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}