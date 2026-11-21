import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/invoice_download.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_action_result.dart';
import 'package:doghree_rider/features/wallet/domain/models/withdrawals_page.dart';
import 'package:doghree_rider/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';

class WalletRepository implements WalletRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  WalletRepository(
      {required this.apiClient, required this.sharedPreferences});

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future<EarningReportModel?> getEarningReport(
      {String? offset,
      String? type,
      String? startDate,
      String? endDate}) async {
    EarningReportModel? earningReportModel;
    final bool hasRange = startDate != null && endDate != null;
    final Response response = await apiClient.getData(
      AppConstants.earningReportUri,
      query: {
        'limit': 10,
        'offset': offset,
        'type': type,
        'start_date': hasRange ? startDate : '',
        'end_date': hasRange ? endDate : '',
      },
    );

    if (response.statusCode == 200) {
      earningReportModel = EarningReportModel.fromJson(response.body);
    }
    return earningReportModel;
  }

  /// Invoice PDF as raw bytes (audit row 41). All filters are optional:
  /// without them the backend returns the full statement. The dates are sent
  /// together or not at all. Silent; a 401 still ends the session.
  @override
  Future<InvoiceDownload> downloadEarningInvoice({
    required int dmId,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> query = {
      if (startDate != null && endDate != null) ...{
        'start_date': startDate,
        'end_date': endDate,
      },
      if (type != null && type.isNotEmpty) 'type': type,
    };

    final Response response = await apiClient.getBytes(
      '${AppConstants.earningReportInvoiceUri}/$dmId',
      query: query,
    );
    ApiChecker.checkSession(response);
    final dynamic body = response.body;
    return InvoiceDownload(
      statusCode: response.statusCode,
      bytes: body is Uint8List ? body : null,
      message: response.statusCode == 200 ? null : response.statusText,
    );
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
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<WalletModel?> getWallet() async {
    final Response response =
        await apiClient.getData(AppConstants.walletUri, handleError: false);
    ApiChecker.checkSession(response);
    if (response.statusCode == 200 && response.body is Map) {
      return WalletModel.fromJson(Map<String, dynamic>.from(response.body));
    }
    return null;
  }

  @override
  Future<ResponseModel> saveWalletAccount(
      {required int methodId,
      required Map<String, String> fields,
      bool isDefault = false}) async {
    final Response response = await apiClient.postData(
      AppConstants.walletAccountsUri,
      {
        'withdrawal_method_id': methodId,
        'fields': fields,
        'is_default': isDefault,
      },
      handleError: false,
    );
    return _walletResult(response);
  }

  @override
  Future<DeleteAccountResult> deleteWalletAccount(int id) async {
    final Response response = await apiClient.deleteData(
        '${AppConstants.walletAccountsUri}/$id',
        handleError: false);
    ApiChecker.checkSession(response);
    final DeleteAccountOutcome outcome =
        classifyDeleteAccount(response.statusCode, errorCodes(response.body));
    final dynamic body = response.body;
    final String? message = outcome == DeleteAccountOutcome.deleted
        ? (body is Map ? body['message']?.toString() : null)
        : response.statusText;
    return DeleteAccountResult(outcome, message);
  }

  ResponseModel _walletResult(Response response) {
    if (response.statusCode == 401) {
      ApiChecker.checkApi(response); // انتهاء الجلسة
    }
    if (response.statusCode == 200) {
      final body = response.body;
      return ResponseModel(
          true, body is Map ? body['message']?.toString() : null);
    }
    return ResponseModel(false, response.statusText,
        statusCode: response.statusCode);
  }

  @override
  Future<WithdrawResult> requestWithdraw(
      {required double amount, int? accountId, String? note}) async {
    final Map<String, dynamic> body = {'amount': amount};
    if (accountId != null) body['account_id'] = accountId;
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
    final Response response = await apiClient
        .postData(AppConstants.walletWithdrawUri, body, handleError: false);
    ApiChecker.checkSession(response);
    final WithdrawDecision decision =
        classifyWithdraw(response.statusCode, errorCodes(response.body));
    final dynamic resBody = response.body;
    final String? message = decision.outcome == WithdrawOutcome.sent
        ? (resBody is Map ? resBody['message']?.toString() : null)
        : response.statusText;
    return WithdrawResult(decision, message);
  }

  /// One page of withdrawal requests (audit row 42). Silent; a 401 still
  /// ends the session. Null on any failure.
  @override
  Future<WithdrawalsPage?> getWithdrawals({int page = 1}) async {
    final Response response = await apiClient.getData(
      AppConstants.walletWithdrawalsUri,
      query: {'limit': WithdrawalsPage.limit, 'offset': page},
      handleError: false,
    );
    ApiChecker.checkSession(response);
    if (response.statusCode != 200) return null;
    return WithdrawalsPage.fromBody(response.body);
  }
}
