import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/models/data_load.dart';
import 'package:doghree_rider/common/models/load_failure.dart';
import 'package:doghree_rider/features/html/domain/services/html_service_interface.dart';

class HtmlController extends GetxController implements GetxService {
  final HtmlServiceInterface htmlServiceInterface;
  HtmlController({required this.htmlServiceInterface});

  /// The last good text of each page (privacy: true, terms: false), so a
  /// failed reload keeps what the rider already read (D-13).
  final Map<bool, String> _texts = {};

  bool? _page;

  String? _htmlText;

  /// The text of the open page. Null while loading or after a failed first
  /// load; empty when the server has no text for this page.
  String? get htmlText => _htmlText;

  LoadFailure? _failure;

  /// Why the page could not be loaded, when there is no text to show (D-13).
  LoadFailure? get failure => _failure;

  Future<void> getHtmlText(bool isPrivacyPolicy) async {
    // No update() here: this runs from initState. The first build shows the
    // last good text of this page, or the spinner.
    _page = isPrivacyPolicy;
    _htmlText = _texts[isPrivacyPolicy];
    _failure = null;
    try {
      final DataLoad<String> load =
          await htmlServiceInterface.getHtmlText(isPrivacyPolicy);
      // The rider opened the other page meanwhile: this answer is stale.
      if (_page != isPrivacyPolicy) return;
      final String? text = load.data;
      if (text != null) {
        _htmlText = text.replaceAll('href=', 'target="_blank" href=');
        _texts[isPrivacyPolicy] = _htmlText!;
      } else if (_htmlText == null) {
        _failure = LoadFailures.fromStatus(load.statusCode);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('html page failed: ${e.runtimeType}');
      if (_page == isPrivacyPolicy && _htmlText == null) {
        _failure = LoadFailure.serverProblem;
      }
    } finally {
      update();
    }
  }

  /// Retry from the failure state: the spinner shows, then one request.
  Future<void> retry(bool isPrivacyPolicy) async {
    _failure = null;
    update();
    await getHtmlText(isPrivacyPolicy);
  }
}
