import 'package:doghree_rider/features/wallet/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/helper/json_helper.dart';

/// One page of `GET wallet/withdrawals` (audit row 42). `offset` is a page
/// number from 1, `limit` clamps to 1-50, newest first (Screens R6).
class WithdrawalsPage {
  static const int limit = 20;

  final List<WalletWithdrawal> items;

  /// Server count of all requests. Null when the field is missing.
  final int? totalSize;

  const WithdrawalsPage(this.items, this.totalSize);

  /// Null when the body is not a Map or `withdrawals` is not a List.
  static WithdrawalsPage? fromBody(dynamic body) {
    if (body is! Map) return null;
    final List<WalletWithdrawal>? items = JsonHelper.mapList(
      body['withdrawals'],
      WalletWithdrawal.fromJson,
      name: 'withdrawals',
    );
    if (items == null) return null;
    return WithdrawalsPage(items, JsonHelper.asInt(body['total_size']));
  }
}
