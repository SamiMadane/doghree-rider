import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service_interface.dart';

class WalletController extends GetxController implements GetxService {
  final WalletServiceInterface walletServiceInterface;
  WalletController({required this.walletServiceInterface});

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
      debugPrint('EARNING REPORT error: $e');
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

  Future<void> downloadEarningInvoice({required int dmId}) async {
    _downloadLoading = true;
    update();

    final response =
        await walletServiceInterface.downloadEarningInvoice(dmId: dmId);

    if (response.statusCode == 200) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/earning_invoice_$dmId.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyString!.codeUnits);

        OpenFilex.open(filePath);
      } catch (e) {
        showCustomSnackBar('file_opening_failed'.tr);
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _downloadLoading = false;
    update();
  }

  // ---------------------------------------------------------------------------
  // Wallet
  // ---------------------------------------------------------------------------

  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;

  bool _walletLoading = false;
  bool get walletLoading => _walletLoading;

  Future<void> getWallet() async {
    _walletLoading = true;
    update();
    final WalletModel? wallet = await walletServiceInterface.getWallet();
    if (wallet != null) _wallet = wallet;
    _walletLoading = false;
    update();
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
      debugPrint('SAVE ACCOUNT error: $e');
      _accountError = 'error_occurred'.tr;
    }

    _accountBusy = false;
    update();
    return ok;
  }

  Future<bool> deleteWalletAccount(int id) async {
    _accountBusy = true;
    update();

    final ResponseModel r =
        await walletServiceInterface.deleteWalletAccount(id);
    if (r.isSuccess) await getWallet();

    _accountBusy = false;
    update();
    showCustomSnackBar(
      r.isSuccess ? 'wallet_account_deleted'.tr : r.message,
      isError: !r.isSuccess,
    );
    return r.isSuccess;
  }

  // ---------------------------------------------------------------------------
  // Withdrawals
  // ---------------------------------------------------------------------------

  List<WalletWithdrawal>? _withdrawals;
  List<WalletWithdrawal>? get withdrawals => _withdrawals;

  bool _withdrawalsFailed = false;
  bool get withdrawalsFailed => _withdrawalsFailed;

  bool _withdrawBusy = false;
  bool get withdrawBusy => _withdrawBusy;

  String? _withdrawError;
  String? get withdrawError => _withdrawError;

  void clearWithdrawError() {
    if (_withdrawError == null) return;
    _withdrawError = null;
    update();
  }

  Future<void> getWithdrawals() async {
    try {
      final List<WalletWithdrawal>? list =
          await walletServiceInterface.getWithdrawals();
      if (list != null) {
        _withdrawals = list;
        _withdrawalsFailed = false;
      } else {
        _withdrawalsFailed = true;
      }
    } catch (e) {
      _withdrawalsFailed = true;
      debugPrint('WITHDRAWALS parse error: $e');
    }
    update();
  }

  Future<bool> requestWithdraw({
    required double amount,
    int? accountId,
    String? note,
  }) async {
    if (_withdrawBusy) return false; // يمنع الضغط المزدوج
    _withdrawBusy = true;
    _withdrawError = null;
    update();

    bool ok = false;
    try {
      final ResponseModel r = await walletServiceInterface.requestWithdraw(
        amount: amount,
        accountId: accountId,
        note: note,
      );
      ok = r.isSuccess;
      if (ok) {
        showCustomSnackBar('wallet_withdraw_success'.tr, isError: false);
      } else {
        _withdrawError = _messageOrDefault(r.message);
      }
    } catch (e) {
      debugPrint('WITHDRAW error: $e');
      _withdrawError = 'error_occurred'.tr;
    }
    _withdrawBusy = false;

    if (ok) {
      // نجح الطلب: ارجع فوراً (الـ sheet بتتسكّر) وحدّث الرصيد والسجل بالخلفية.
      unawaited(Future.wait([getWallet(), getWithdrawals()]));
      return true;
    }

    // فشل: الحالة الحقيقية من السيرفر.
    await getWallet();
    await getWithdrawals();
    update();
    return false;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _messageOrDefault(String? message) =>
      (message != null && message.trim().isNotEmpty)
          ? message
          : 'error_occurred'.tr;
}
