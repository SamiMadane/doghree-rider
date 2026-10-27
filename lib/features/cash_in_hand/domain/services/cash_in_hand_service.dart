import 'package:get/get.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_payment_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/repositories/cash_in_hand_repository_interface.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/services/cash_in_hand_service_interface.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';



class CashInHandService implements CashInHandServiceInterface {
  final CashInHandRepositoryInterface cashInHandRepositoryInterface;
  CashInHandService({required this.cashInHandRepositoryInterface});

  @override
  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName) async {
    return await cashInHandRepositoryInterface.makeCollectCashPayment(amount, paymentGatewayName);
  }

  @override
  Future<List<Transactions>?> getWalletPaymentList() async {
    return await cashInHandRepositoryInterface.getList();
  }

  @override
  Future<List<Transactions>?> getWalletProvidedEarningList() async {
    return await cashInHandRepositoryInterface.getWalletProvidedEarningList();
  }

  @override
  Future<ResponseModel> makeWalletAdjustment() async {
    return await cashInHandRepositoryInterface.makeWalletAdjustment();
  }

  @override
  Future<EarningReportModel?> getEarningReport({String? offset, String? type, String? startDate, String? endDate}) async {
    return await cashInHandRepositoryInterface.getEarningReport(offset: offset, type: type, startDate: startDate, endDate: endDate);
  }

  @override
  Future<Response> downloadEarningInvoice({required int dmId}) async {
    return await cashInHandRepositoryInterface.downloadEarningInvoice(dmId: dmId);
  }
  @override
  Future<WalletModel?> getWallet() async {
    return await cashInHandRepositoryInterface.getWallet();
  }

  @override
  Future<ResponseModel> saveWalletAccount(
      {required int methodId,
      required Map<String, String> fields,
      bool isDefault = false}) async {
    return await cashInHandRepositoryInterface.saveWalletAccount(
        methodId: methodId, fields: fields, isDefault: isDefault);
  }

  @override
  Future<ResponseModel> deleteWalletAccount(int id) async {
    return await cashInHandRepositoryInterface.deleteWalletAccount(id);
  }
    @override
  Future<ResponseModel> requestWithdraw(
      {required double amount, int? accountId, String? note}) async {
    return await cashInHandRepositoryInterface.requestWithdraw(
        amount: amount, accountId: accountId, note: note);
  }

  @override
  Future<List<WalletWithdrawal>?> getWithdrawals({int offset = 1}) async {
    return await cashInHandRepositoryInterface.getWithdrawals(offset: offset);
  }
}