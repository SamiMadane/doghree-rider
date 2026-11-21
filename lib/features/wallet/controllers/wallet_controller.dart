import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/invoice_download.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_action_result.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/withdrawals_page.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service_interface.dart';

class WalletController extends GetxController implements GetxService {
  final WalletServiceInterface walletServiceInterface;
  final InvoiceSaver invoiceSaver;
  WalletController({
    required this.walletServiceInterface,
    this.invoiceSaver = const FileInvoiceSaver(),
  });

  /// Every wallet toast goes through here, so tests can count them.
  void Function(String? message, {bool isError}) toast = showCustomSnackBar;

  static const String _allTypes = 'all_types_earning';
  static const String _allTime = 'all_time';
  static const String _customRange = 'custom_date_range';

  // ---------------------------------------------------------------------------
  // Earning report
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Data>? _earningList;
  List<Data>? get earningList => _earningList;

  EarningReportModel? _earningReportModel;
  EarningReportModel? get earningReportModel => _earningReportModel;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int _offset = 1;
  int get offset => _offset;

  List<String> _offsetList = [];

  /// True when page 1 failed to load, so the screen shows a retry state.
  bool _earningFailed = false;
  bool get earningFailed => _earningFailed;

  /// Bumped on every page-1 request so late replies of old requests are ignored.
  int _earningRequestId = 0;

  // Filter

  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  String? _from;
  String? get from => _from;

  String? _to;
  String? get to => _to;

  final List<String> _earningTypes = [
    _allTypes,
    'delivery_fee',
    'delivery_tips'
  ];
  List<String> get earningTypes => _earningTypes;

  String? _selectedEarningType = _allTypes;
  String? get selectedEarningType => _selectedEarningType;

  final List<String> _dateTypes = [_allTime, _customRange];
  List<String> get dateTypes => _dateTypes;

  String? _selectedDateType = _allTime;
  String? get selectedDateType => _selectedDateType;

  // Invoice

  bool? _downloadLoading = false;
  bool? get downloadLoading => _downloadLoading;

  Future<void> getEarningReport({
    required String offset,
    required String? type,
    required String? startDate,
    required String? endDate,
    bool fromFilter = false,
  }) async {
    final bool firstPage = offset == '1';

    if (firstPage) {
      _earningRequestId++;
      _offsetList = [];
      _offset = 1;
      _earningList = null;
      _earningFailed = false;
      _isLoading = false;
      _isFiltered = fromFilter;
      update();
    }

    if (_offsetList.contains(offset)) {
      if (_isLoading) {
        _isLoading = false;
        update();
      }
      return;
    }
    _offsetList.add(offset);

    final int requestId = _earningRequestId;
    final EarningReportModel? report = await _fetchEarningReport(
      offset: offset,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );

    if (requestId != _earningRequestId) return; // a newer request replaced it

    if (report == null) {
      _onEarningFailed(offset);
      return;
    }

    if (firstPage) _earningList = [];
    _earningReportModel = report;
    _earningList!.addAll(report.earning?.data ?? const []);
    _pageSize = report.earning?.total;
    _isLoading = false;
    update();
  }

  /// Re-runs page 1 with the filter that is currently applied.
  Future<void> retryEarningReport() => getEarningReport(
        offset: '1',
        type: _selectedEarningType,
        startDate: _from,
        endDate: _to,
        fromFilter: _isFiltered,
      );

  Future<EarningReportModel?> _fetchEarningReport({
    required String offset,
    required String? type,
    required String? startDate,
    required String? endDate,
  }) async {
    try {
      return await walletServiceInterface.getEarningReport(
        offset: offset,
        type: type == _allTypes ? 'all' : type,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return null;
    }
  }

  /// Page 1 shows the error state; later pages roll back so the next scroll
  /// retries the same page.
  void _onEarningFailed(String offset) {
    _offsetList.remove(offset);
    _isLoading = false;
    if (offset == '1') {
      _earningFailed = true;
    } else {
      _offset = int.parse(offset) - 1;
    }
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<void> applyEarningFilter({
    required String type,
    required String dateType,
    DateTimeRange? range,
  }) async {
    final DateTimeRange? r = dateType == _customRange ? range : null;
    _selectedEarningType = type;
    _selectedDateType = dateType;
    _from = r?.start.toIso8601String().substring(0, 10);
    _to = r?.end.toIso8601String().substring(0, 10);

    await getEarningReport(
      offset: '1',
      type: type,
      startDate: _from,
      endDate: _to,
      fromFilter: type != _allTypes || r != null,
    );
  }

  void resetEarningFilter({bool isUpdate = true}) {
    _selectedEarningType = _allTypes;
    _selectedDateType = _allTime;
    _from = null;
    _to = null;
    _isFiltered = false;
    if (isUpdate) update();
  }

  // --- Applied-filter helpers (used by the filter chips) ---

  bool get hasTypeFilter =>
      _selectedEarningType != null && _selectedEarningType != _allTypes;

  bool get hasDateFilter => _from != null && _to != null;

  DateTimeRange? get _appliedRange {
    final DateTime? start = DateTime.tryParse(_from ?? '');
    final DateTime? end = DateTime.tryParse(_to ?? '');
    if (start == null || end == null) return null;
    return DateTimeRange(start: start, end: end);
  }

  /// Removes only the earning-type part and keeps the date range.
  Future<void> removeEarningTypeFilter() => applyEarningFilter(
        type: _allTypes,
        dateType: _selectedDateType ?? _allTime,
        range: _appliedRange,
      );

  /// Removes only the date range and keeps the earning type.
  Future<void> removeEarningDateFilter() => applyEarningFilter(
        type: _selectedEarningType ?? _allTypes,
        dateType: _allTime,
      );

  /// Removes the whole filter and reloads page 1.
  Future<void> clearEarningFilter() =>
      applyEarningFilter(type: _allTypes, dateType: _allTime);

  /// Downloads the earnings statement PDF (audit row 41). It follows the
  /// filter that is currently applied on the screen; with no filter the
  /// backend returns the full statement. The raw bytes are written only when
  /// they are a PDF. At most one message per tap; the loader always stops.
  Future<void> downloadEarningInvoice({required int dmId}) async {
    if (_downloadLoading == true) return; // double tap
    _downloadLoading = true;
    update();

    try {
      final InvoiceDownload download =
          await walletServiceInterface.downloadEarningInvoice(
        dmId: dmId,
        type: _selectedEarningType == _allTypes ? 'all' : _selectedEarningType,
        startDate: hasDateFilter ? _from : null,
        endDate: hasDateFilter ? _to : null,
      );

      if (download.isPdf) {
        bool opened = false;
        try {
          opened = await invoiceSaver.saveAndOpen(
              _invoiceFileName(dmId), download.bytes!);
        } catch (_) {
          opened = false;
        }
        if (!opened) toast('file_opening_failed'.tr);
      } else if (download.statusCode == 401) {
        // ApiChecker already ended the session.
      } else if (download.statusCode == 1) {
        toast(_noInternetText);
      } else if (download.statusCode == 200) {
        toast('invoice_download_failed'.tr); // 200 but not a PDF
      } else {
        // 422 (bad filter) / 404 (nothing to export) carry a JSON message.
        toast(_messageOrDefault(download.message,
            fallback: 'invoice_download_failed'.tr));
      }
    } catch (_) {
      toast('invoice_download_failed'.tr);
    } finally {
      _downloadLoading = false;
      update();
    }
  }

  /// One file per filter combination, so a viewer never shows a stale copy of
  /// a different filter, and repeated downloads of the same filter overwrite.
  String _invoiceFileName(int dmId) {
    final String suffix = [
      if (hasDateFilter) '${_from}_$_to',
      if (hasTypeFilter) _selectedEarningType,
    ].join('_');
    return 'earning_invoice_$dmId${suffix.isEmpty ? '' : '_$suffix'}.pdf';
  }

  // ---------------------------------------------------------------------------
  // Wallet
  // ---------------------------------------------------------------------------

  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;

  bool _walletLoading = false;
  bool get walletLoading => _walletLoading;

  /// Silent (audit row 43). A failure keeps the last known wallet.
  Future<void> getWallet() async {
    _walletLoading = true;
    update();
    try {
      final WalletModel? wallet = await walletServiceInterface.getWallet();
      if (wallet != null) _wallet = wallet;
    } catch (_) {
      // keep the last known values
    } finally {
      _walletLoading = false;
      update();
    }
  }

  // ---------------------------------------------------------------------------
  // Wallet accounts
  // ---------------------------------------------------------------------------

  bool _accountBusy = false;
  bool get accountBusy => _accountBusy;

  String? _accountError;
  String? get accountError => _accountError;

  void clearAccountError() {
    if (_accountError == null) return;
    _accountError = null;
    update();
  }

  Future<bool> saveWalletAccount({
    required int methodId,
    required Map<String, String> fields,
    bool isDefault = false,
  }) async {
    if (_accountBusy) return false; // يمنع الضغط المزدوج
    _accountBusy = true;
    _accountError = null;
    update();

    bool ok = false;
    try {
      final ResponseModel r =
          await walletServiceInterface.saveWalletAccount(
        methodId: methodId,
        fields: fields,
        isDefault: isDefault,
      );
      ok = r.isSuccess;
      if (ok) {
        await getWallet();
        showCustomSnackBar('wallet_account_saved'.tr, isError: false);
      } else {
        _accountError = _messageOrDefault(r.message);
      }
    } catch (e) {
      _accountError = 'error_occurred'.tr;
    }

    _accountBusy = false;
    update();
    return ok;
  }

  /// Audit row 44: one request per tap, one message, and the busy flag
  /// always resets.
  Future<bool> deleteWalletAccount(int id) async {
    if (_accountBusy) return false; // double tap
    _accountBusy = true;
    update();

    bool deleted = false;
    try {
      final DeleteAccountResult r =
          await walletServiceInterface.deleteWalletAccount(id);
      switch (r.outcome) {
        case DeleteAccountOutcome.deleted:
          deleted = true;
          toast('wallet_account_deleted'.tr, isError: false);
          await getWallet();
          break;
        case DeleteAccountOutcome.gone:
          toast(_messageOrDefault(r.message));
          await getWallet();
          break;
        case DeleteAccountOutcome.sessionEnded:
          break; // ApiChecker already showed the session sheet
        case DeleteAccountOutcome.offline:
          toast(_noInternetText);
          break;
        case DeleteAccountOutcome.failed:
          toast(_messageOrDefault(r.message));
          break;
      }
    } catch (_) {
      toast('error_occurred'.tr);
    } finally {
      _accountBusy = false;
      update();
    }
    return deleted;
  }

  // ---------------------------------------------------------------------------
  // Withdrawals
  // ---------------------------------------------------------------------------

  List<WalletWithdrawal>? _withdrawals;
  List<WalletWithdrawal>? get withdrawals => _withdrawals;

  /// True when page 1 failed and there is no list to show.
  bool _withdrawalsFailed = false;
  bool get withdrawalsFailed => _withdrawalsFailed;

  // Paging (audit row 42). `offset` is a page number from 1.
  int _withdrawalsPage = 0;
  int? _withdrawalsTotal;
  int? get withdrawalsTotal => _withdrawalsTotal;
  bool _withdrawalsLastEmpty = false;
  int _withdrawalsGen = 0;

  bool _withdrawalsLoadingMore = false;
  bool get withdrawalsLoadingMore => _withdrawalsLoadingMore;

  bool _withdrawalsPageFailed = false;
  bool get withdrawalsPageFailed => _withdrawalsPageFailed;

  /// More pages exist while the loaded pages cover fewer rows than the
  /// server count and no page came back empty.
  bool get hasMoreWithdrawals =>
      _withdrawals != null &&
      !_withdrawalsLastEmpty &&
      _withdrawalsTotal != null &&
      _withdrawalsPage * WithdrawalsPage.limit < _withdrawalsTotal!;

  bool _withdrawBusy = false;
  bool get withdrawBusy => _withdrawBusy;

  String? _withdrawError;
  String? get withdrawError => _withdrawError;

  void clearWithdrawError() {
    if (_withdrawError == null) return;
    _withdrawError = null;
    update();
  }

  /// Loads page 1 again (first load and pull-to-refresh) and bumps the
  /// generation, so a next page still in flight is dropped. Silent; a
  /// failure keeps the last known list.
  Future<void> getWithdrawals() async {
    final int gen = ++_withdrawalsGen;
    WithdrawalsPage? page;
    try {
      page = await walletServiceInterface.getWithdrawals(page: 1);
    } catch (_) {
      page = null;
    }
    if (gen != _withdrawalsGen) return; // a newer refresh replaced it

    if (page != null) {
      _withdrawals = _unique(page.items);
      _withdrawalsTotal = page.totalSize;
      _withdrawalsPage = 1;
      _withdrawalsLastEmpty = page.items.isEmpty;
      _withdrawalsPageFailed = false;
      _withdrawalsFailed = false;
    } else if (_withdrawals == null) {
      _withdrawalsFailed = true;
    }
    update();
  }

  /// Loads the next page. At most one request is in flight, and after a
  /// failed page only [retryWithdrawalsPage] continues: nothing retries by
  /// itself, a 410 included.
  Future<void> loadNextWithdrawalsPage() async {
    if (_withdrawalsLoadingMore ||
        _withdrawalsPageFailed ||
        !hasMoreWithdrawals) {
      return;
    }
    final int gen = _withdrawalsGen;
    final int next = _withdrawalsPage + 1;
    _withdrawalsLoadingMore = true;
    update();

    try {
      final WithdrawalsPage? page =
          await walletServiceInterface.getWithdrawals(page: next);
      if (gen != _withdrawalsGen) return; // a refresh replaced the list
      if (page == null) {
        _withdrawalsPageFailed = true;
      } else {
        final Set<int> seen = {for (final w in _withdrawals!) w.id};
        _withdrawals = [
          ..._withdrawals!,
          for (final w in page.items)
            if (seen.add(w.id)) w,
        ];
        _withdrawalsPage = next;
        _withdrawalsLastEmpty = page.items.isEmpty;
        if (page.totalSize != null) _withdrawalsTotal = page.totalSize;
      }
    } catch (_) {
      if (gen == _withdrawalsGen) _withdrawalsPageFailed = true;
    } finally {
      _withdrawalsLoadingMore = false;
      update();
    }
  }

  Future<void> retryWithdrawalsPage() {
    _withdrawalsPageFailed = false;
    return loadNextWithdrawalsPage();
  }

  static List<WalletWithdrawal> _unique(List<WalletWithdrawal> items) {
    final Set<int> seen = {};
    return [
      for (final w in items)
        if (seen.add(w.id)) w,
    ];
  }

  /// Audit row 43: one message per tap (inline in the sheet, or the success
  /// toast). Refreshes afterwards are silent and follow [classifyWithdraw].
  Future<bool> requestWithdraw({
    required double amount,
    int? accountId,
    String? note,
  }) async {
    if (_withdrawBusy) return false; // يمنع الضغط المزدوج
    _withdrawBusy = true;
    _withdrawError = null;
    update();

    WithdrawDecision decision = const WithdrawDecision(WithdrawOutcome.failed);
    try {
      final WithdrawResult r = await walletServiceInterface.requestWithdraw(
        amount: amount,
        accountId: accountId,
        note: note,
      );
      decision = r.decision;
      _withdrawError = _withdrawMessage(decision.outcome, r.message);
      if (decision.outcome == WithdrawOutcome.sent) {
        toast('wallet_withdraw_success'.tr, isError: false);
      }
    } catch (e) {
      _withdrawError = 'error_occurred'.tr;
    } finally {
      _withdrawBusy = false;
      update();
    }

    final Future<void> refreshes = Future.wait([
      if (decision.refreshWallet) getWallet(),
      if (decision.refreshWithdrawals) getWithdrawals(),
    ]);
    if (decision.outcome == WithdrawOutcome.sent) {
      // نجح الطلب: ارجع فوراً (الـ sheet بتتسكّر) وحدّث الرصيد والسجل بالخلفية.
      unawaited(refreshes);
      return true;
    }
    await refreshes;
    return false;
  }

  /// The inline text of a failed withdraw. Null when nothing is shown.
  String? _withdrawMessage(WithdrawOutcome outcome, String? server) {
    switch (outcome) {
      case WithdrawOutcome.sent:
      case WithdrawOutcome.sessionEnded:
        return null;
      case WithdrawOutcome.offline:
        return _noInternetText;
      case WithdrawOutcome.invalidInput:
        return _messageOrDefault(server,
            fallback: 'wallet_withdraw_invalid_amount'.tr);
      case WithdrawOutcome.blocked:
        return _messageOrDefault(server,
            fallback: 'wallet_withdraw_unavailable'.tr);
      case WithdrawOutcome.accountProblem:
        return _messageOrDefault(server,
            fallback: 'wallet_withdraw_add_account_first'.tr);
      case WithdrawOutcome.failed:
        return _messageOrDefault(server);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _messageOrDefault(String? message, {String? fallback}) =>
      (message != null && message.trim().isNotEmpty)
          ? message
          : (fallback ?? 'error_occurred'.tr);

  String get _noInternetText => ErrorMessages.getMessage(ErrorType.noInternet);
}