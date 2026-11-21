// Decisions for wallet actions (audit rows 43, 44). Every decision uses the
// HTTP status and the `errors[].code` values only, never the message text
// (Doghri-App-Screens R6).

/// Error codes of `POST wallet/withdraw`, 403. Two families share the status.
class WithdrawCodes {
  WithdrawCodes._();

  /// Validation failures: `code` is the field name.
  static const Set<String> fields = {
    'amount',
    'fields',
    'withdrawal_method_id',
    'note',
    'account_id',
  };

  /// Business rules that depend on the wallet state.
  static const Set<String> blocked = {
    'withdraw_weekly_limit',
    'withdraw_no_balance',
    'withdraw_minimum',
    'withdraw_insufficient_balance',
  };

  /// "Write an amount greater than zero."
  static const String amount = 'withdraw_amount';

  /// Any account or method problem.
  static const Set<String> account = {
    'withdraw',
    'rider_withdraw_account_required',
  };

  static bool isKnown(String code) =>
      fields.contains(code) ||
      blocked.contains(code) ||
      code == amount ||
      account.contains(code);
}

enum WithdrawOutcome {
  sent,
  invalidInput,
  blocked,
  accountProblem,
  sessionEnded,
  offline,
  failed,
}

class WithdrawDecision {
  final WithdrawOutcome outcome;
  final bool refreshWallet;
  final bool refreshWithdrawals;

  const WithdrawDecision(
    this.outcome, {
    this.refreshWallet = false,
    this.refreshWithdrawals = false,
  });
}

/// The first code in [codes] that is recognized, in list order.
String? firstKnownWithdrawCode(List<String> codes) {
  for (final String code in codes) {
    if (WithdrawCodes.isKnown(code)) return code;
  }
  return null;
}

/// [status] 1 is the ApiClient "no internet" status. A 410 or any other
/// failure is final: nothing is retried and nothing is refreshed.
WithdrawDecision classifyWithdraw(int? status, List<String> codes) {
  if (status == 200) {
    return const WithdrawDecision(WithdrawOutcome.sent,
        refreshWallet: true, refreshWithdrawals: true);
  }
  if (status == 401) return const WithdrawDecision(WithdrawOutcome.sessionEnded);
  if (status == 1) return const WithdrawDecision(WithdrawOutcome.offline);
  if (status != 403) return const WithdrawDecision(WithdrawOutcome.failed);

  final String? code = firstKnownWithdrawCode(codes);
  if (code == null) {
    // A 403 with a code the app does not know: the server state may differ.
    return const WithdrawDecision(WithdrawOutcome.failed,
        refreshWallet: true, refreshWithdrawals: true);
  }
  if (WithdrawCodes.fields.contains(code)) {
    return const WithdrawDecision(WithdrawOutcome.invalidInput);
  }
  if (code == WithdrawCodes.amount) {
    // The docs only say "amount must be above zero"; they do not state that
    // the balance is unaffected, so the wallet is refreshed silently too.
    return const WithdrawDecision(WithdrawOutcome.invalidInput,
        refreshWallet: true);
  }
  if (WithdrawCodes.blocked.contains(code)) {
    return const WithdrawDecision(WithdrawOutcome.blocked,
        refreshWallet: true, refreshWithdrawals: true);
  }
  return const WithdrawDecision(WithdrawOutcome.accountProblem,
      refreshWallet: true);
}

/// Result of `POST wallet/withdraw` as the controller needs it.
class WithdrawResult {
  final WithdrawDecision decision;

  /// The server message, if any. Shown as is; never used to decide.
  final String? message;

  const WithdrawResult(this.decision, [this.message]);
}

enum DeleteAccountOutcome { deleted, gone, sessionEnded, offline, failed }

/// `DELETE wallet/accounts/{id}`: 404 `account` means it is already gone.
DeleteAccountOutcome classifyDeleteAccount(int? status, List<String> codes) {
  if (status == 200) return DeleteAccountOutcome.deleted;
  if (status == 401) return DeleteAccountOutcome.sessionEnded;
  if (status == 1) return DeleteAccountOutcome.offline;
  if (status == 404 && codes.contains('account')) {
    return DeleteAccountOutcome.gone;
  }
  return DeleteAccountOutcome.failed;
}

class DeleteAccountResult {
  final DeleteAccountOutcome outcome;
  final String? message;
  const DeleteAccountResult(this.outcome, [this.message]);
}

/// Every `errors[].code` of a response body, in list order.
List<String> errorCodes(dynamic body) {
  if (body is! Map) return const [];
  final dynamic errors = body['errors'];
  if (errors is! List) return const [];
  return [
    for (final dynamic e in errors)
      if (e is Map && e['code'] != null) '${e['code']}',
  ];
}
