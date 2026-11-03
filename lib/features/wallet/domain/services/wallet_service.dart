import 'package:get/get.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_withdrawal_model.dart';

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
  Future<Response> downloadEarningInvoice({required int dmId}) async {
    return await walletRepositoryInterface.downloadEarningInvoice(
        dmId: dmId);
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
  Future<ResponseModel> deleteWalletAccount(int id) async {
    return await walletRepositoryInterface.deleteWalletAccount(id);
  }

  @override
  Future<ResponseModel> requestWithdraw(
      {required double amount, int? accountId, String? note}) async {
    return await walletRepositoryInterface.requestWithdraw(
        amount: amount, accountId: accountId, note: note);
  }

  @override
  Future<List<WalletWithdrawal>?> getWithdrawals({int offset = 1}) async {
    return await walletRepositoryInterface.getWithdrawals(offset: offset);
  }
}
