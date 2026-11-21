import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/wallet/domain/models/invoice_download.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_action_result.dart';
import 'package:doghree_rider/features/wallet/domain/models/withdrawals_page.dart';
import 'package:doghree_rider/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

const String secret = 'SECRET-TOKEN-123';

/// Real PDF start: header plus the binary comment line, which is not UTF-8.
final Uint8List pdfBytes = Uint8List.fromList([
  ...'%PDF-1.7\n%'.codeUnits,
  0xE2, 0xE3, 0xCF, 0xD3, 0x0A, // binary marker
  0x00, 0xFF, 0x80, 0xC3, 0x28, // more bytes that are not valid UTF-8
  ...'\n%%EOF\n'.codeUnits,
]);

void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;
  late WalletRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({AppConstants.token: secret});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
    repo = WalletRepository(apiClient: api, sharedPreferences: prefs);
  });

  group('withdrawals page (audit row 42)', () {
    test('P1 page 2 sends limit 20 and offset 2 as query, silently', () async {
      api.nextResponse = const Response(
          statusCode: 200, body: {'total_size': 0, 'withdrawals': []});
      await repo.getWithdrawals(page: 2);

      final RecordedCall c = api.last;
      expect(c.uri, AppConstants.walletWithdrawalsUri);
      expect(c.query, {'limit': 20, 'offset': 2});
      expect(c.handleError, isFalse);
    });

    test('P2 parses total_size and rows; wrong shapes are a failure (null)',
        () async {
      api.nextResponse = const Response(statusCode: 200, body: {
        'total_size': '25',
        'limit': 20,
        'offset': 1,
        'withdrawals': [
          {'id': 9, 'amount': 4.25, 'status': 'pending'},
          'junk',
        ],
      });
      final WithdrawalsPage? page = await repo.getWithdrawals();
      expect(page!.totalSize, 25);
      expect(page.items.map((w) => w.id), [9]);
      expect(page.items.single.amount, 4.25);

      api.nextResponse = const Response(statusCode: 200, body: [1, 2]);
      expect(await repo.getWithdrawals(), isNull);
      api.nextResponse =
          const Response(statusCode: 200, body: {'withdrawals': 'x'});
      expect(await repo.getWithdrawals(), isNull);
      api.nextResponse = const Response(statusCode: 1);
      expect(await repo.getWithdrawals(), isNull);
    });
  });

  group('silent refreshes (audit row 43)', () {
    test('S1 GET wallet is silent (handleError false)', () async {
      api.nextResponse = const Response(statusCode: 1);
      await repo.getWallet();
      expect(api.last.uri, AppConstants.walletUri);
      expect(api.last.handleError, isFalse);
    });

    test('S2 GET withdrawals is silent (handleError false)', () async {
      api.nextResponse = const Response(statusCode: 1);
      await repo.getWithdrawals();
      expect(api.last.handleError, isFalse);
    });
  });

  group('withdraw and delete map codes, never text', () {
    test('R1 withdraw 403 carries the first recognized code and the message',
        () async {
      api.nextResponse = const Response(
        statusCode: 403,
        statusText: 'server text',
        body: {
          'errors': [
            {'code': 'withdraw_weekly_limit', 'message': 'server text'}
          ]
        },
      );
      final WithdrawResult r = await repo.requestWithdraw(amount: 4.25);
      expect(r.decision.outcome, WithdrawOutcome.blocked);
      expect(r.message, 'server text');
      expect(api.last.handleError, isFalse);
    });

    test('R2 withdraw 200 is sent', () async {
      api.nextResponse =
          const Response(statusCode: 200, body: {'message': 'ok'});
      final WithdrawResult r = await repo.requestWithdraw(amount: 4);
      expect(r.decision.outcome, WithdrawOutcome.sent);
    });

    test('R3 delete 404 account is gone', () async {
      api.nextResponse = const Response(
        statusCode: 404,
        statusText: 'not found text',
        body: {
          'errors': [
            {'code': 'account', 'message': 'not found text'}
          ]
        },
      );
      final DeleteAccountResult r = await repo.deleteWalletAccount(7);
      expect(r.outcome, DeleteAccountOutcome.gone);
      expect(r.message, 'not found text');
      expect(api.last.handleError, isFalse);
    });
  });

  group('invoice bytes (audit row 41)', () {
    test('B1 a PDF sent with charset=utf-8 arrives byte for byte', () async {
      final ApiClient client =
          ApiClient(appBaseUrl: 'http://fake.local', sharedPreferences: prefs);
      final WalletRepository real =
          WalletRepository(apiClient: client, sharedPreferences: prefs);

      final InvoiceDownload d = await http.runWithClient(
        () => real.downloadEarningInvoice(dmId: 5, type: 'all'),
        () => MockClient((request) async => http.Response.bytes(pdfBytes, 200,
            headers: {'content-type': 'application/pdf; charset=utf-8'})),
      );

      expect(d.statusCode, 200);
      expect(d.bytes, pdfBytes);
      expect(d.isPdf, isTrue);
    });

    test('GB1 guard: a PDF without a charset arrives byte for byte', () async {
      final ApiClient client =
          ApiClient(appBaseUrl: 'http://fake.local', sharedPreferences: prefs);
      final WalletRepository real =
          WalletRepository(apiClient: client, sharedPreferences: prefs);

      final InvoiceDownload d = await http.runWithClient(
        () => real.downloadEarningInvoice(dmId: 5),
        () => MockClient((request) async => http.Response.bytes(pdfBytes, 200,
            headers: {'content-type': 'application/pdf'})),
      );
      expect(d.bytes, pdfBytes);
    });

    test('B6 getBytes sends the Bearer header, no token in the query, and '
        'logs only the length', () async {
      final ApiClient client =
          ApiClient(appBaseUrl: 'http://fake.local', sharedPreferences: prefs);
      final List<http.BaseRequest> requests = [];
      final List<String> logs = [];
      final DebugPrintCallback original = debugPrint;
      debugPrint = (String? m, {int? wrapWidth}) => logs.add(m ?? '');
      try {
        await http.runWithClient(
          () => WalletRepository(apiClient: client, sharedPreferences: prefs)
              .downloadEarningInvoice(
                  dmId: 5,
                  type: 'all',
                  startDate: '2026-01-01',
                  endDate: '2026-01-31'),
          () => MockClient((request) async {
            requests.add(request);
            return http.Response.bytes(pdfBytes, 200,
                headers: {'content-type': 'application/pdf'});
          }),
        );
      } finally {
        debugPrint = original;
      }

      final http.BaseRequest req = requests.single;
      expect(req.headers['Authorization'], 'Bearer $secret');
      expect(req.url.path,
          '${AppConstants.earningReportInvoiceUri}/5');
      expect(req.url.queryParameters.containsKey('token'), isFalse);
      expect(req.url.toString(), isNot(contains(secret)));
      expect(req.url.queryParameters['start_date'], '2026-01-01');
      expect(logs.join('\n'), contains('${pdfBytes.length} bytes'));
      for (final String line in logs) {
        expect(line, isNot(contains('%PDF')));
        expect(line, isNot(contains(secret)));
      }
    });

    test('B7 a 404 JSON error gives the server message and no bytes', () {
      final Response r = ApiClient.handleBytesResponse(http.Response(
          '{"errors":[{"code":"report","message":"nothing to export"}]}', 404,
          headers: {'content-type': 'application/json; charset=utf-8'}));
      expect(r.statusCode, 404);
      expect(r.statusText, 'nothing to export');
      expect(r.body, isA<Map>());
    });
  });
}
