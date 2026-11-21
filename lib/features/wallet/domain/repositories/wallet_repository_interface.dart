import 'package:doghree_rider/features/wallet/domain/models/earning_report_model.dart';
import 'package:doghree_rider/interface/repository_interface.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/wallet/domain/models/invoice_download.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_action_result.dart';
import 'package:doghree_rider/features/wallet/domain/models/withdrawals_page.dart';

abstract class WalletRepositoryInterface implements RepositoryInterface {
  Future<EarningReportModel?> getEarningReport(
      {String? offset, String? type, String? startDate, String? endDate});
  Future<InvoiceDownload> downloadEarningInvoice({
    required int dmId,
    String? type,
    String? startDate,
    String? endDate,
  });
  Future<WalletModel?> getWallet();
  Future<ResponseModel> saveWalletAccount(
      {required int methodId,
      required Map<String, String> fields,
      bool isDefault = false});
  Future<DeleteAccountResult> deleteWalletAccount(int id);
  Future<WithdrawResult> requestWithdraw(
      {required double amount, int? accountId, String? note});
  Future<WithdrawalsPage?> getWithdrawals({int page = 1});
}
