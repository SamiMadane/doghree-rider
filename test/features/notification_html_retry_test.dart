import 'package:doghree_rider/features/html/controllers/html_controller.dart';
import 'package:doghree_rider/features/html/domain/repositories/html_repository.dart';
import 'package:doghree_rider/features/html/domain/services/html_service.dart';
import 'package:doghree_rider/features/html/screens/html_viewer_screen.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/features/language/domain/services/language_service_interface.dart';
import 'package:doghree_rider/features/notification/controllers/notification_controller.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository.dart';
import 'package:doghree_rider/features/notification/domain/services/notification_service.dart';
import 'package:doghree_rider/features/notification/screens/notification_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';
import '../helpers/pump_phone.dart';

/// D-13: Notifications and the HTML pages after a failed first load. These
/// tests use only the old public API, so they also run on the old code.
const Response _offline = Response(statusCode: 1, statusText: 'no internet');

/// A 200 as ApiClient builds it: `body` is the decoded JSON, or the raw text
/// when it does not decode; `bodyString` is always the raw text.
Response _ok200(String raw, dynamic decoded) =>
    Response(statusCode: 200, body: decoded, bodyString: raw);

class _NoSavedLanguage implements LanguageServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs, nextResponse: _offline);
    Get.put<LocalizationController>(
        LocalizationController(languageServiceInterface: _NoSavedLanguage()));
  });

  tearDown(Get.reset);

  HtmlController htmlController() => HtmlController(
      htmlServiceInterface: HtmlService(
          htmlRepositoryInterface: HtmlRepository(apiClient: api)));

  group('HTML pages: the expected shape is a JSON string', () {
    test('R3 the page load does not use ApiChecker toasts', () async {
      await htmlController().getHtmlText(true);
      expect(api.getHandleErrors.last, isFalse);
    });

    test('R6 a 200 with a login page (raw HTML) is not shown as the policy',
        () async {
      const String portal = '<html><body>Login to Wi-Fi</body></html>';
      api.nextResponse = _ok200(portal, portal);
      final HtmlController c = htmlController();

      await c.getHtmlText(true);

      expect(c.htmlText, isNull);
    });

    test('H1 guard: an empty body is an empty page, not a failure', () async {
      api.nextResponse = _ok200('', '');
      final HtmlController c = htmlController();
      await c.getHtmlText(true);
      expect(c.htmlText, '');
    });

    test('H2 guard: a JSON "" (what the server sends today) is an empty page',
        () async {
      api.nextResponse = _ok200('""', '');
      final HtmlController c = htmlController();
      await c.getHtmlText(false);
      expect(c.htmlText, '');
    });

    test('H3 guard: a JSON string is the page text', () async {
      api.nextResponse = _ok200('"<p>Terms</p>"', '<p>Terms</p>');
      final HtmlController c = htmlController();
      await c.getHtmlText(false);
      expect(c.htmlText, '<p>Terms</p>');
    });
  });

  group('HTML screen', () {
    testWidgets('W5 offline: no-connection state; Retry online shows the page',
        (tester) async {
      final HtmlController c = htmlController();
      Get.put<HtmlController>(c);
      await pumpPhone(tester, const HtmlViewerScreen(isPrivacyPolicy: true));
      await tester.pump();

      expect(find.text('no_connection'), findsOneWidget);
      expect(find.byType(HtmlWidget), findsNothing);

      api.nextResponse = _ok200('"<p>Privacy</p>"', '<p>Privacy</p>');
      await tester.tap(find.text('retry'));
      await tester.pump();
      await tester.pump();

      expect(find.text('no_connection'), findsNothing);
      expect(find.byType(HtmlWidget), findsOneWidget);
    });

    testWidgets('W7 an empty page shows the empty state, not a blank page',
        (tester) async {
      api.nextResponse = _ok200('""', '');
      Get.put<HtmlController>(htmlController());
      await pumpPhone(tester, const HtmlViewerScreen(isPrivacyPolicy: false));
      await tester.pump();

      expect(find.text('not_found'), findsOneWidget);
      expect(find.text('server_problem'), findsNothing);
    });
  });

  group('Notifications screen', () {
    testWidgets('W4 offline first open: no-connection state and no toast',
        (tester) async {
      final NotificationController c = NotificationController(
          notificationServiceInterface: NotificationService(
              notificationRepositoryInterface: NotificationRepository(
                  apiClient: api, sharedPreferences: prefs)));
      final List<String?> toasts = [];
      c.toast = (String? message, {bool isError = true}) => toasts.add(message);
      Get.put<NotificationController>(c);

      await pumpPhone(tester, const NotificationScreen());
      await tester.pump();
      await tester.pump();

      expect(find.text('no_connection'), findsOneWidget);
      expect(find.text('retry'), findsOneWidget);
      expect(toasts, isEmpty);
    });

    testWidgets('W8 Retry online: the list (here empty) replaces the state',
        (tester) async {
      final NotificationController c = NotificationController(
          notificationServiceInterface: NotificationService(
              notificationRepositoryInterface: NotificationRepository(
                  apiClient: api, sharedPreferences: prefs)));
      c.toast = (String? message, {bool isError = true}) {};
      Get.put<NotificationController>(c);
      await pumpPhone(tester, const NotificationScreen());
      await tester.pump();
      await tester.pump();

      api.nextResponse = const Response(statusCode: 200, body: []);
      await tester.tap(find.text('retry'));
      await tester.pump();
      await tester.pump();

      expect(find.text('no_connection'), findsNothing);
      expect(find.text('no_notifications'), findsOneWidget);
    });
  });
}
