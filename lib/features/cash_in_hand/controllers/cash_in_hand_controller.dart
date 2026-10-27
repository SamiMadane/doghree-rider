import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'dart:async';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_payment_model.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/services/cash_in_hand_service_interface.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';

class CashInHandController extends GetxController implements GetxService {
  final CashInHandServiceInterface cashInHandServiceInterface;
  CashInHandController({required this.cashInHandServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Transactions>? _transactions;
  List<Transactions>? get transactions => _transactions;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  List<Transactions>? _walletProvidedTransactions;
  List<Transactions>? get walletProvidedTransactions =>
      _walletProvidedTransactions;

  late DateTimeRange _selectedDateRange;

  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  String? _from;
  String? get from => _from;

  String? _to;
  String? get to => _to;

  int? _pageSize;
  int? get pageSize => _pageSize;

  List<String> _offsetList = [];

  int _offset = 1;
  int get offset => _offset;

  EarningReportModel? _earningReportModel;
  EarningReportModel? get earningReportModel => _earningReportModel;

  List<Data>? _earningList;
  List<Data>? get earningList => _earningList;

  final List<String> _earningTypes = [
    'all_types_earning',
    'delivery_fee',
    'delivery_tips'
  ];
  List<String> get earningTypes => _earningTypes;

  String? _selectedEarningType = 'all_types_earning';
  String? get selectedEarningType => _selectedEarningType;

  final List<String> _dateTypes = ['all_time', 'custom_date_range'];
  List<String> get dateTypes => _dateTypes;

  String? _selectedDateType = 'all_time';
  String? get selectedDateType => _selectedDateType;

  bool? _downloadLoading = false;
  bool? get downloadLoading => _downloadLoading;
  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;

  bool _walletLoading = false;
  bool get walletLoading => _walletLoading;

  bool _accountBusy = false;
  bool get accountBusy => _accountBusy;
  List<WalletWithdrawal>? _withdrawals;
  List<WalletWithdrawal>? get withdrawals => _withdrawals;

  bool _withdrawalsFailed = false;
  bool get withdrawalsFailed => _withdrawalsFailed;

  bool _withdrawBusy = false;
  bool get withdrawBusy => _withdrawBusy;
  String? _withdrawError;
  String? get withdrawError => _withdrawError;

  String? _accountError;
  String? get accountError => _accountError;

  void clearAccountError() {
    if (_accountError != null) {
      _accountError = null;
      update();
    }
  }

  void clearWithdrawError() {
    if (_withdrawError != null) {
      _withdrawError = null;
      update();
    }
  }

  Future<void> getWithdrawals() async {
    try {
      final list = await cashInHandServiceInterface.getWithdrawals();
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

  Future<bool> requestWithdraw(
      {required double amount, int? accountId, String? note}) async {
    if (_withdrawBusy) return false; // يمنع الضغط المزدوج
    _withdrawBusy = true;
    _withdrawError = null;
    update();
    bool ok = false;
    try {
      final ResponseModel r = await cashInHandServiceInterface.requestWithdraw(
          amount: amount, accountId: accountId, note: note);
      ok = r.isSuccess;
      if (ok) {
        showCustomSnackBar('wallet_withdraw_success'.tr, isError: false);
      } else {
        final String? msg = r.message;
        _withdrawError =
            (msg != null && msg.trim().isNotEmpty) ? msg : 'error_occurred'.tr;
      }
    } catch (e) {
      debugPrint('WITHDRAW error: $e');
      _withdrawError = 'error_occurred'.tr;
    }
    // الحالة الحقيقية دائماً من السيرفر (نجاح أو رفض)
    await getWallet();
    await getWithdrawals();
    _withdrawBusy = false;
    update();
    return ok;
  }

  Future<ResponseModel> makeCollectCashPayment(
      double amount, String paymentGatewayName) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await cashInHandServiceInterface
        .makeCollectCashPayment(amount, paymentGatewayName);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> getWallet() async {
    _walletLoading = true;
    update();
    final WalletModel? wallet = await cashInHandServiceInterface.getWallet();
    if (wallet != null) _wallet = wallet;
    _walletLoading = false;
    update();
  }
Future<bool> saveWalletAccount(
    {required int methodId,
    required Map<String, String> fields,
    bool isDefault = false}) async {
  if (_accountBusy) return false; // يمنع الضغط المزدوج
  _accountBusy = true;
  _accountError = null;
  update();
  bool ok = false;
  try {
    final ResponseModel r = await cashInHandServiceInterface.saveWalletAccount(
        methodId: methodId, fields: fields, isDefault: isDefault);
    ok = r.isSuccess;
    if (ok) {
      await getWallet();
      showCustomSnackBar('wallet_account_saved'.tr, isError: false);
    } else {
      final String? m = r.message;
      _accountError =
          (m != null && m.trim().isNotEmpty) ? m : 'error_occurred'.tr;
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
        await cashInHandServiceInterface.deleteWalletAccount(id);
    if (r.isSuccess) await getWallet();
    _accountBusy = false;
    update();
    showCustomSnackBar(r.isSuccess ? 'wallet_account_deleted'.tr : r.message,
        isError: !r.isSuccess); // الحذف
    return r.isSuccess;
  }

  Future<void> getWalletPaymentList() async {
    _transactions = null;
    List<Transactions>? transactions =
        await cashInHandServiceInterface.getWalletPaymentList();
    if (transactions != null) {
      _transactions = [];
      _transactions!.addAll(transactions);
    }
    update();
  }

  Future<void> getWalletProvidedEarningList() async {
    _walletProvidedTransactions = null;
    List<Transactions>? walletProvidedTransactions =
        await cashInHandServiceInterface.getWalletProvidedEarningList();
    if (walletProvidedTransactions != null) {
      _walletProvidedTransactions = [];
      _walletProvidedTransactions!.addAll(walletProvidedTransactions);
    }
    update();
  }

  Future<void> makeWalletAdjustment() async {
    _isLoading = true;
    update();
    ResponseModel responseModel =
        await cashInHandServiceInterface.makeWalletAdjustment();
    if (responseModel.isSuccess) {
      Get.find<ProfileController>().getProfile();
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      Get.back();
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
  }

  void setPaymentIndex(int index) {
    _paymentIndex = index;
    update();
  }

  void changeDigitalPaymentName(String? name, {bool canUpdate = true}) {
    _digitalPaymentName = name;
    if (canUpdate) {
      update();
    }
  }

  void setIndex(int index) {
    _selectedIndex = index;
    update();
  }

  /*void initSetDate(){
    _from = DateConverterHelper.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 365)));
    _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
    _searchText = '';
  }*/

  void showDatePicker(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      _selectedDateRange = result;

      _from = _selectedDateRange.start.toString().split(' ')[0];
      _to = _selectedDateRange.end.toString().split(' ')[0];
      update();
      //getExpenseList(offset: '1', from: _from, to: _to, searchText: searchText);
      debugPrint('===$from / ===$to');
    }
  }

  Future<void> getEarningReport(
      {required String offset,
      required String? type,
      required String? startDate,
      required String? endDate,
      bool fromFilter = false}) async {
    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _earningList = null;
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      EarningReportModel? earningReportModel =
          await cashInHandServiceInterface.getEarningReport(
              offset: offset,
              type: type == 'all_types_earning' ? 'all' : type,
              startDate: startDate,
              endDate: endDate);
      if (earningReportModel != null) {
        if (offset == '1') {
          _earningList = [];
        }
        _earningReportModel = earningReportModel;
        _earningList!.addAll(earningReportModel.earning!.data!);
        _pageSize = earningReportModel.earning!.total;
        _isLoading = false;
        _isFiltered = fromFilter;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setEarningType(String? type) {
    _selectedEarningType = type;
    update();
  }

  void setDateType(String? type) {
    _selectedDateType = type;
    update();
  }

  void resetEarningFilter({bool isUpdate = true}) {
    _selectedEarningType = 'all_types_earning';
    _selectedDateType = 'all_time';
    _from = null;
    _to = null;
    _isFiltered = false;
    if (isUpdate) {
      update();
    }
  }

  Future<void> downloadEarningInvoice({required int dmId}) async {
    _downloadLoading = true;
    update();

    final response =
        await cashInHandServiceInterface.downloadEarningInvoice(dmId: dmId);

    if (response.statusCode == 200) {
      try {
        // Get the document directory path
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/earning_invoice_$dmId.pdf';

        // Save the PDF file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyString!.codeUnits);

        // Open the PDF file
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
}
