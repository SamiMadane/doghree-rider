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
  final DateTime? paidAt;
  final String methodName;
  final String accountSummary;
  final String? note;
  final String? payoutMethodLabel;
  final String? payoutReference;
  final String? payoutProofUrl;
  final String? adminNote;
  final String? rejectionReason;

  WalletWithdrawal({
    required this.id,
    required this.amount,
    required this.status,
    required this.statusLabel,
    this.requestedAt,
    this.paidAt,
    required this.methodName,
    required this.accountSummary,
    this.note,
    this.payoutMethodLabel,
    this.payoutReference,
    this.payoutProofUrl,
    this.adminNote,
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
      paidAt: DateTime.tryParse('${j['paid_at'] ?? ''}')?.toLocal(),
      methodName: _s(j['method']) ?? '',
      accountSummary: account is Map
          ? account.values
              .map((v) => '${v ?? ''}')
              .where((v) => v.isNotEmpty)
              .join(' · ')
          : '',
      note: _s(j['note']),
      payoutMethodLabel: _s(j['payout_method_label']),
      payoutReference: _s(j['payout_reference']),
      payoutProofUrl: _s(j['payout_proof_url']),
      adminNote: _s(j['admin_note']),
      rejectionReason: _s(j['rejection_reason']),
    );
  }
}