import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/invoice_download.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_action_result.dart';
import 'package:doghree_rider/features/wallet/domain/models/withdrawals_page.dart';

class WalletService implements WalletServiceInterface {
  final WalletRepositoryInterface walletRepositoryInterface;
  WalletService({required this.walletRepositoryInterface});

  @override
  Future<EarningReportModel?> getEarningReport(
      {String? offset,
      String? type,
      String? startDate,
      String? endDate}) async {
    return await walletRepositoryInterface.getEarningReport(
        offset: offset, type: type, startDate: startDate, endDate: endDate);
  }

  @override
  Future<InvoiceDownload> downloadEarningInvoice({
    required int dmId,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    return await walletRepositoryInterface.downloadEarningInvoice(
        dmId: dmId, type: type, startDate: startDate, endDate: endDate);
  }

  @override
  Future<WalletModel?> getWallet() async {
    return await walletRepositoryInterface.getWallet();
  }

  @override
  Future<ResponseModel> saveWalletAccount(
      {required int methodId,
      required Map<String, String> fields,
      bool isDefault = false}) async {
    return await walletRepositoryInterface.saveWalletAccount(
        methodId: methodId, fields: fields, isDefault: isDefault);
  }

  @override
  Future<DeleteAccountResult> deleteWalletAccount(int id) async {
    return await walletRepositoryInterface.deleteWalletAccount(id);
  }

  @override
  Future<WithdrawResult> requestWithdraw(
      {required double amount, int? accountId, String? note}) async {
    return await walletRepositoryInterface.requestWithdraw(
        amount: amount, accountId: accountId, note: note);
  }

  @override
  Future<WithdrawalsPage?> getWithdrawals({int page = 1}) async {
    return await walletRepositoryInterface.getWithdrawals(page: page);
  }
}
