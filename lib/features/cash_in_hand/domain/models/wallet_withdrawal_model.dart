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

  /// Account the rider asked to be paid on, as sent by the server:
  /// field key -> value (e.g. account_name, bank_name, account_number).
  final Map<String, String> accountFields;
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
    this.accountFields = const <String, String>{},
    this.note,
    this.payoutMethodLabel,
    this.payoutReference,
    this.payoutProofUrl,
    this.adminNote,
    this.rejectionReason,
  });

  /// Account values on one line, e.g. `sami madane · palestine · 41179854`.
  String get accountSummary => accountFields.values.join(' · ');

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
      accountFields: account is Map
          ? <String, String>{
              for (final MapEntry e in account.entries)
                if ('${e.value ?? ''}'.trim().isNotEmpty)
                  '${e.key}': '${e.value}'.trim(),
            }
          : <String, String>{},
      note: _s(j['note']),
      payoutMethodLabel: _s(j['payout_method_label']),
      payoutReference: _s(j['payout_reference']),
      payoutProofUrl: _s(j['payout_proof_url']),
      adminNote: _s(j['admin_note']),
      rejectionReason: _s(j['rejection_reason']),
    );
  }
}