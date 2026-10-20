import 'package:get/get.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_payment_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';


abstract class CashInHandServiceInterface {
  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName);
  Future<List<Transactions>?> getWalletPaymentList();
  Future<List<Transactions>?> getWalletProvidedEarningList();
  Future<ResponseModel> makeWalletAdjustment();
  Future<EarningReportModel?> getEarningReport({String? offset, String? type, String? startDate, String? endDate});
  Future<Response> downloadEarningInvoice({required int dmId});
  Future<WalletModel?> getWallet();
  Future<ResponseModel> saveWalletAccount(
    {required int methodId,
    required Map<String, String> fields,
    bool isDefault = false});
Future<ResponseModel> deleteWalletAccount(int id);
Future<ResponseModel> requestWithdraw(
    {required double amount, int? accountId, String? note});
Future<List<WalletWithdrawal>?> getWithdrawals({int offset = 1});
}