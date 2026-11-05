import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_withdrawal_model.dart';
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

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<EarningReportModel?> getEarningReport(
      {String? offset,
      String? type,
      String? startDate,
      String? endDate}) async {
    EarningReportModel? earningReportModel;
    Response response;

    if (startDate != null && endDate != null) {
      response = await apiClient.getData(
          '${AppConstants.earningReportUri}?limit=10&offset=$offset&type=$type&start_date=$startDate&end_date=$endDate&token=${_getUserToken()}');
    } else {
      response = await apiClient.getData(
          '${AppConstants.earningReportUri}?limit=10&offset=$offset&type=$type&start_date=&end_date=&token=${_getUserToken()}');
    }

    if (response.statusCode == 200) {
      earningReportModel = EarningReportModel.fromJson(response.body);
    }
    return earningReportModel;
  }

  /// Invoice PDF. All filters are optional: without them the backend returns
  /// the full statement. The dates are sent together or not at all.
  @override
  Future<Response> downloadEarningInvoice({
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

    return apiClient.getData(
      '${AppConstants.earningReportInvoiceUri}/$dmId',
      query: query,
      handleError: false,
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
    final Response response = await apiClient.getData(AppConstants.walletUri);
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
  Future<ResponseModel> deleteWalletAccount(int id) async {
    final Response response = await apiClient.deleteData(
        '${AppConstants.walletAccountsUri}/$id',
        handleError: false);
    return _walletResult(response);
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
  Future<ResponseModel> requestWithdraw(
      {required double amount, int? accountId, String? note}) async {
    final Map<String, dynamic> body = {'amount': amount};
    if (accountId != null) body['account_id'] = accountId;
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
    final Response response = await apiClient
        .postData(AppConstants.walletWithdrawUri, body, handleError: false);
    return _walletResult(response);
  }

  @override
  Future<List<WalletWithdrawal>?> getWithdrawals({int offset = 1}) async {
    final Response response = await apiClient.getData(
        '${AppConstants.walletWithdrawalsUri}?limit=20&offset=$offset');
    if (response.statusCode == 200 && response.body is Map) {
      final raw = (response.body as Map)['withdrawals'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => WalletWithdrawal.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return null;
  }
}