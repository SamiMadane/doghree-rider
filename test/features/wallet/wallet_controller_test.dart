import 'dart:async';

import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/wallet/domain/models/invoice_download.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_action_result.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/withdrawals_page.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeWalletService implements WalletServiceInterface {
  Future<WalletModel?> Function() wallet = () async => null;
  Future<WithdrawalsPage?> Function(int page) withdrawals = (_) async => null;
  Future<WithdrawResult> Function() withdraw =
      () async => const WithdrawResult(WithdrawDecision(WithdrawOutcome.sent));
  Future<DeleteAccountResult> Function() delete =
      () async => const DeleteAccountResult(DeleteAccountOutcome.deleted);
  Future<InvoiceDownload> Function() invoice =
      () async => const InvoiceDownload(statusCode: 500);

  int walletCalls = 0;
  int deleteCalls = 0;
  int invoiceCalls = 0;
  final List<int> pages = [];

  @override
  Future<WalletModel?> getWallet() {
    walletCalls++;
    return wallet();
  }

  @override
  Future<WithdrawalsPage?> getWithdrawals({int page = 1}) {
    pages.add(page);
    return withdrawals(page);
  }

  @override
  Future<WithdrawResult> requestWithdraw(
          {required double amount, int? accountId, String? note}) =>
      withdraw();

  @override
  Future<DeleteAccountResult> deleteWalletAccount(int id) {
    deleteCalls++;
    return delete();
  }

  @override
  Future<InvoiceDownload> downloadEarningInvoice(
      {required int dmId, String? type, String? startDate, String? endDate}) {
    invoiceCalls++;
    return invoice();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSaver implements InvoiceSaver {
  final List<Uint8List> saved = [];
  bool opens = true;
  bool throws = false;

  @override
  Future<bool> saveAndOpen(String fileName, Uint8List bytes) async {
    if (throws) throw Exception('disk full');
    saved.add(bytes);
    return opens;
  }
}

WalletModel _wallet(double balance) => WalletModel.fromJson({
      'available_balance': balance,
      'total_earning': 10,
      'can_request_withdraw': true,
    });

WithdrawalsPage _page(int? total, List<int> ids) => WithdrawalsPage(
      [for (final id in ids) WalletWithdrawal.fromJson({'id': id, 'amount': 1})],
      total,
    );

List<int> _ids(WalletController c) => c.withdrawals!.map((w) => w.id).toList();

WithdrawResult _fail(int status, List<String> codes, [String? msg]) =>
    WithdrawResult(classifyWithdraw(status, codes), msg);

final Uint8List _pdf = Uint8List.fromList([...'%PDF-1.4\n'.codeUnits, 0xE2]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  late _FakeWalletService service;
  late _FakeSaver saver;
  late WalletController c;
  late List<String?> toasts;
  final String noInternet = ErrorMessages.getMessage(ErrorType.noInternet);

  setUp(() {
    service = _FakeWalletService();
    saver = _FakeSaver();
    c = WalletController(walletServiceInterface: service, invoiceSaver: saver);
    toasts = [];
    c.toast = (String? m, {bool isError = true}) => toasts.add(m);
  });

  group('withdraw: one message per tap (audit row 43)', () {
    test('S3 offline: one localized inline message, no toast, no refresh',
        () async {
      service.withdraw = () async => _fail(1, const []);
      final bool ok = await c.requestWithdraw(amount: 4);

      expect(ok, isFalse);
      expect(c.withdrawError, noInternet);
      expect(c.withdrawError, isNot(ApiClient.noInternetMessage));
      expect(toasts, isEmpty);
      expect(service.walletCalls, 0);
      expect(service.pages, isEmpty);
    });

    test('W1 blocked: server text inline, one silent refresh each, no toast',
        () async {
      service.withdraw = () async =>
          _fail(403, const ['withdraw_weekly_limit'], 'weekly text');
      final bool ok = await c.requestWithdraw(amount: 4);

      expect(ok, isFalse);
      expect(c.withdrawError, 'weekly text');
      expect(service.walletCalls, 1);
      expect(service.pages, [1]);
      expect(toasts, isEmpty);
      expect(c.withdrawBusy, isFalse);
    });

    test('W2 field validation: inline text, no refresh', () async {
      service.withdraw = () async => _fail(403, const ['note'], 'note text');
      await c.requestWithdraw(amount: 4);
      expect(c.withdrawError, 'note text');
      expect(service.walletCalls, 0);
      expect(service.pages, isEmpty);
      expect(toasts, isEmpty);
    });

    test('W3 withdraw_amount: inline text and only a silent wallet refresh',
        () async {
      service.withdraw =
          () async => _fail(403, const ['withdraw_amount'], 'amount text');
      await c.requestWithdraw(amount: 4);
      expect(c.withdrawError, 'amount text');
      expect(service.walletCalls, 1);
      expect(service.pages, isEmpty);
      expect(toasts, isEmpty);
    });

    test('W4 account problem without a message falls back to a local key',
        () async {
      service.withdraw = () async =>
          _fail(403, const ['rider_withdraw_account_required'], '');
      await c.requestWithdraw(amount: 4);
      expect(c.withdrawError, 'wallet_withdraw_add_account_first');
      expect(service.walletCalls, 1);
    });

    test('W5 401: no inline text and no toast (the session sheet only)',
        () async {
      service.withdraw = () async => _fail(401, const [], 'unauth');
      await c.requestWithdraw(amount: 4);
      expect(c.withdrawError, isNull);
      expect(toasts, isEmpty);
      expect(service.walletCalls, 0);
    });

    test('W6 410: failed once, nothing refreshed or retried', () async {
      int sent = 0;
      service.withdraw = () async {
        sent++;
        return _fail(410, const ['endpoint_removed'], 'gone text');
      };
      await c.requestWithdraw(amount: 4);
      expect(sent, 1);
      expect(c.withdrawError, 'gone text');
      expect(service.walletCalls, 0);
      expect(service.pages, isEmpty);
    });

    test('W7 success: one success toast and true', () async {
      final bool ok = await c.requestWithdraw(amount: 4);
      expect(ok, isTrue);
      expect(toasts, ['wallet_withdraw_success']);
      expect(c.withdrawError, isNull);
    });

    test('GW1 guard: an exception resets withdrawBusy', () async {
      service.withdraw = () async => throw Exception('x');
      final bool ok = await c.requestWithdraw(amount: 4);
      expect(ok, isFalse);
      expect(c.withdrawBusy, isFalse);
      expect(c.withdrawError, 'error_occurred');
    });
  });

  group('a failed silent refresh keeps the last known values', () {
    test('K1 wallet: a null or a throwing refresh keeps the balance',
        () async {
      service.wallet = () async => _wallet(4.25);
      await c.getWallet();
      expect(c.wallet!.availableBalance, 4.25);

      service.wallet = () async => null;
      await c.getWallet();
      expect(c.wallet!.availableBalance, 4.25);

      service.wallet = () async => throw Exception('x');
      await c.getWallet();
      expect(c.wallet!.availableBalance, 4.25);
      expect(c.walletLoading, isFalse);
    });

    test('K2 withdrawals: a failed refresh keeps the list', () async {
      service.withdrawals = (_) async => _page(2, [5, 4]);
      await c.getWithdrawals();
      service.withdrawals = (_) async => null;
      await c.getWithdrawals();
      expect(_ids(c), [5, 4]);
      expect(c.withdrawalsFailed, isFalse);

      service.withdrawals = (_) async => throw Exception('x');
      await c.getWithdrawals();
      expect(_ids(c), [5, 4]);
    });
  });

  group('withdrawals paging (audit row 42)', () {
    test('P3 25 rows load over 2 pages, then paging ends', () async {
      service.withdrawals = (p) async => p == 1
          ? _page(25, List.generate(20, (i) => 100 - i))
          : _page(25, List.generate(5, (i) => 80 - i));
      await c.getWithdrawals();
      expect(c.hasMoreWithdrawals, isTrue);

      await c.loadNextWithdrawalsPage();
      expect(c.withdrawals!.length, 25);
      expect(c.hasMoreWithdrawals, isFalse);
      await c.loadNextWithdrawalsPage();
      expect(service.pages, [1, 2]);
    });

    test('P4 an id on two pages is shown once', () async {
      service.withdrawals = (p) async => p == 1
          ? _page(41, List.generate(20, (i) => 100 - i))
          : _page(41, [81, 80, 79]);
      await c.getWithdrawals();
      await c.loadNextWithdrawalsPage();
      expect(_ids(c).where((id) => id == 81).length, 1);
      expect(_ids(c).length, 22);
    });

    test('P5 a failed page waits for Retry', () async {
      service.withdrawals =
          (p) async => p == 1 ? _page(30, List.generate(20, (i) => i)) : null;
      await c.getWithdrawals();
      await c.loadNextWithdrawalsPage();
      expect(c.withdrawalsPageFailed, isTrue);
      expect(c.withdrawalsLoadingMore, isFalse);

      await c.loadNextWithdrawalsPage(); // a scroll does not retry
      expect(service.pages, [1, 2]);

      service.withdrawals = (p) async => _page(30, [50]);
      await c.retryWithdrawalsPage();
      expect(service.pages, [1, 2, 2]);
      expect(c.withdrawalsPageFailed, isFalse);
      expect(_ids(c).last, 50);
    });

    test('P6 pull-to-refresh drops a late page 2', () async {
      final Completer<WithdrawalsPage?> latePage = Completer();
      service.withdrawals = (p) =>
          p == 1 ? Future.value(_page(30, List.generate(20, (i) => i))) : latePage.future;
      await c.getWithdrawals();
      final Future<void> loading = c.loadNextWithdrawalsPage();

      service.withdrawals = (p) async => _page(30, [999]);
      await c.getWithdrawals(); // refresh: page 1, new generation
      latePage.complete(_page(30, [500]));
      await loading;

      expect(_ids(c), [999]);
      expect(c.withdrawalsLoadingMore, isFalse);
      expect(c.withdrawalsPageFailed, isFalse);
    });

    test('P7 an empty page ends paging even if total_size says more',
        () async {
      service.withdrawals = (p) async =>
          p == 1 ? _page(60, List.generate(20, (i) => i)) : _page(60, []);
      await c.getWithdrawals();
      await c.loadNextWithdrawalsPage();
      expect(c.hasMoreWithdrawals, isFalse);
      await c.loadNextWithdrawalsPage();
      expect(service.pages, [1, 2]);
    });

    test('P8 a missing total_size means no more pages', () async {
      service.withdrawals = (_) async => _page(null, List.generate(20, (i) => i));
      await c.getWithdrawals();
      expect(c.hasMoreWithdrawals, isFalse);
    });

    test('P9 only one page request is in flight', () async {
      final Completer<WithdrawalsPage?> hold = Completer();
      service.withdrawals = (p) =>
          p == 1 ? Future.value(_page(60, List.generate(20, (i) => i))) : hold.future;
      await c.getWithdrawals();
      final Future<void> a = c.loadNextWithdrawalsPage();
      final Future<void> b = c.loadNextWithdrawalsPage();
      hold.complete(_page(60, [77]));
      await Future.wait([a, b]);
      expect(service.pages, [1, 2]);
    });

    test('G410 guard: a page that fails (410) is not requested again by '
        'itself', () async {
      service.withdrawals =
          (p) async => p == 1 ? _page(30, List.generate(20, (i) => i)) : null;
      await c.getWithdrawals();
      await c.loadNextWithdrawalsPage();
      await c.loadNextWithdrawalsPage();
      await c.loadNextWithdrawalsPage();
      expect(service.pages, [1, 2]);
    });
  });

  group('delete payout account (audit row 44)', () {
    test('D1 a double tap sends one delete', () async {
      final Completer<DeleteAccountResult> hold = Completer();
      service.delete = () => hold.future;
      final Future<bool> first = c.deleteWalletAccount(7);
      final Future<bool> second = c.deleteWalletAccount(7);
      hold.complete(const DeleteAccountResult(DeleteAccountOutcome.deleted));
      await Future.wait([first, second]);
      expect(service.deleteCalls, 1);
      expect(toasts, ['wallet_account_deleted']);
    });

    test('D2 an exception resets accountBusy with one message', () async {
      service.delete = () async => throw Exception('x');
      final bool ok = await c.deleteWalletAccount(7);
      expect(ok, isFalse);
      expect(c.accountBusy, isFalse);
      expect(toasts, ['error_occurred']);
    });

    test('D3 401: no toast', () async {
      service.delete = () async =>
          const DeleteAccountResult(DeleteAccountOutcome.sessionEnded, 'x');
      await c.deleteWalletAccount(7);
      expect(toasts, isEmpty);
      expect(c.accountBusy, isFalse);
    });

    test('D4 404 account: one toast and a silent wallet refresh', () async {
      service.delete = () async =>
          const DeleteAccountResult(DeleteAccountOutcome.gone, 'gone text');
      await c.deleteWalletAccount(7);
      expect(toasts, ['gone text']);
      expect(service.walletCalls, 1);
    });

    test('D5 offline: one no-internet toast', () async {
      service.delete =
          () async => const DeleteAccountResult(DeleteAccountOutcome.offline);
      await c.deleteWalletAccount(7);
      expect(toasts, [noInternet]);
      expect(service.walletCalls, 0);
    });

    test('D6 success: one toast, then a silent wallet refresh that fails '
        'adds nothing', () async {
      service.wallet = () async => null;
      final bool ok = await c.deleteWalletAccount(7);
      expect(ok, isTrue);
      expect(toasts, ['wallet_account_deleted']);
      expect(service.walletCalls, 1);
    });
  });

  group('invoice download (audit row 41)', () {
    test('B8 a PDF is saved byte for byte with no message', () async {
      service.invoice =
          () async => InvoiceDownload(statusCode: 200, bytes: _pdf);
      await c.downloadEarningInvoice(dmId: 5);
      expect(saver.saved.single, _pdf);
      expect(toasts, isEmpty);
      expect(c.downloadLoading, isFalse);
    });

    test('B2 a 200 that is not a PDF is not saved; one message', () async {
      service.invoice = () async => InvoiceDownload(
          statusCode: 200,
          bytes: Uint8List.fromList('<html>login</html>'.codeUnits));
      await c.downloadEarningInvoice(dmId: 5);
      expect(saver.saved, isEmpty);
      expect(toasts, ['invoice_download_failed']);
      expect(c.downloadLoading, isFalse);
    });

    test('B3 the saver throws: the loader stops, one message', () async {
      saver.throws = true;
      service.invoice =
          () async => InvoiceDownload(statusCode: 200, bytes: _pdf);
      await c.downloadEarningInvoice(dmId: 5);
      expect(toasts, ['file_opening_failed']);
      expect(c.downloadLoading, isFalse);
    });

    test('B4 a 404 with a server message: that message once', () async {
      service.invoice = () async => const InvoiceDownload(
          statusCode: 404, message: 'nothing to export');
      await c.downloadEarningInvoice(dmId: 5);
      expect(toasts, ['nothing to export']);
      expect(c.downloadLoading, isFalse);
    });

    test('B5 a double tap sends one request', () async {
      final Completer<InvoiceDownload> hold = Completer();
      service.invoice = () => hold.future;
      final Future<void> a = c.downloadEarningInvoice(dmId: 5);
      final Future<void> b = c.downloadEarningInvoice(dmId: 5);
      hold.complete(InvoiceDownload(statusCode: 200, bytes: _pdf));
      await Future.wait([a, b]);
      expect(service.invoiceCalls, 1);
      expect(saver.saved.length, 1);
    });

    test('B9 401 shows nothing; offline shows one no-internet message; a '
        'throwing service stops the loader', () async {
      service.invoice = () async => const InvoiceDownload(statusCode: 401);
      await c.downloadEarningInvoice(dmId: 5);
      expect(toasts, isEmpty);

      service.invoice = () async => const InvoiceDownload(statusCode: 1);
      await c.downloadEarningInvoice(dmId: 5);
      expect(toasts, [noInternet]);

      service.invoice = () async => throw Exception('x');
      await c.downloadEarningInvoice(dmId: 5);
      expect(toasts.last, 'invoice_download_failed');
      expect(c.downloadLoading, isFalse);
    });
  });

  test('GM1 guard: money is read as sent and never derived', () {
    final WalletModel w = WalletModel.fromJson({
      'available_balance': 4.25,
      'total_earning': '10.50',
      'total_withdrawn': 0,
      'pending_withdraw': 0,
      'cash_in_hand': 0,
    });
    expect(w.availableBalance, 4.25);
    expect(w.totalEarning, 10.5);
    // 10.50 - 0 - 0 - 0 would be 10.50; the app keeps the server's 4.25.
    expect(w.availableBalance, isNot(w.totalEarning));
  });
}
