double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

String? _s(dynamic v) {
  final t = v?.toString().trim();
  return (t == null || t.isEmpty) ? null : t;
}

class WalletWithdrawal {
  final int id;
  final double amount;
  final String status; // pending | paid | rejected
  final String statusLabel;
  final DateTime? requestedAt;
  final String methodName;
  final String accountSummary;
  final String? payoutReference;
  final String? rejectionReason;

  WalletWithdrawal({
    required this.id,
    required this.amount,
    required this.status,
    required this.statusLabel,
    this.requestedAt,
    required this.methodName,
    required this.accountSummary,
    this.payoutReference,
    this.rejectionReason,
  });

  factory WalletWithdrawal.fromJson(Map<String, dynamic> j) {
    final account = j['account'];
    return WalletWithdrawal(
      id: int.tryParse('${j['id']}') ?? 0,
      amount: _toDouble(j['amount']),
      status: _s(j['status']) ?? 'pending',
      statusLabel: _s(j['status_label']) ?? '',
      requestedAt: DateTime.tryParse('${j['requested_at'] ?? ''}')?.toLocal(),
      methodName: _s(j['method']) ?? '',
      accountSummary: account is Map
          ? account.values
              .map((v) => '${v ?? ''}')
              .where((v) => v.isNotEmpty)
              .join(' · ')
          : '',
      payoutReference: _s(j['payout_reference']),
      rejectionReason: _s(j['rejection_reason']),
    );
  }
}