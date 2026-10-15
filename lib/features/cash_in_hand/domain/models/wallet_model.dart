double _num(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

class WalletModel {
  final double availableBalance;
  final double totalEarning;
  final double totalWithdrawn;
  final double pendingWithdraw;
  final double cashInHand;
  final double riderSharePercent;
  final String? weekStart;
  final String? weekEnd;
  final bool canRequestWithdraw;
  final WithdrawBlock? withdrawBlock;

  WalletModel({
    required this.availableBalance,
    required this.totalEarning,
    required this.totalWithdrawn,
    required this.pendingWithdraw,
    required this.cashInHand,
    required this.riderSharePercent,
    this.weekStart,
    this.weekEnd,
    required this.canRequestWithdraw,
    this.withdrawBlock,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final block = json['withdraw_block'];
    return WalletModel(
      availableBalance: _num(json['available_balance']),
      totalEarning: _num(json['total_earning']),
      totalWithdrawn: _num(json['total_withdrawn']),
      pendingWithdraw: _num(json['pending_withdraw']),
      cashInHand: _num(json['cash_in_hand']),
      riderSharePercent: _num(json['rider_share_percent']),
      weekStart: json['week_start']?.toString(),
      weekEnd: json['week_end']?.toString(),
      canRequestWithdraw:
          json['can_request_withdraw'] == true || json['can_request_withdraw'] == 1,
      withdrawBlock: block is Map
          ? WithdrawBlock(
              code: block['code']?.toString(),
              message: block['message']?.toString())
          : null,
    );
  }
}

class WithdrawBlock {
  final String? code;
  final String? message;
  WithdrawBlock({this.code, this.message});
}