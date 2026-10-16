import 'package:get/get.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/models/earning_report_model.dart';
import 'package:wefrh_rider/interface/repository_interface.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:wefrh_rider/common/models/response_model.dart';

abstract class CashInHandRepositoryInterface implements RepositoryInterface {
  Future<dynamic> makeCollectCashPayment(double amount, String paymentGatewayName);
  Future<dynamic> getWalletProvidedEarningList();
  Future<dynamic> makeWalletAdjustment();
  Future<EarningReportModel?> getEarningReport({String? offset, String? type, String? startDate, String? endDate});
  Future<Response> downloadEarningInvoice({required int dmId});
  Future<WalletModel?> getWallet();
  Future<ResponseModel> saveWalletAccount(
    {required int methodId,
    required Map<String, String> fields,
    bool isDefault = false});
Future<ResponseModel> deleteWalletAccount(int id);
}