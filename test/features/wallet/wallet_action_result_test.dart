import 'package:doghree_rider/features/wallet/domain/models/wallet_action_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Audit row 43: `POST wallet/withdraw` is decided from the status and the
/// `errors[].code` values only (Doghri-App-Screens R6).
void main() {
  group('classifyWithdraw: 403 field-name codes', () {
    for (final String code in [
      'amount',
      'fields',
      'withdrawal_method_id',
      'note',
    ]) {
      test('C-$code is invalidInput with no refresh', () {
        final d = classifyWithdraw(403, [code]);
        expect(d.outcome, WithdrawOutcome.invalidInput);
        expect(d.refreshWallet, isFalse);
        expect(d.refreshWithdrawals, isFalse);
      });
    }
  });

  group('classifyWithdraw: 403 domain codes', () {
    for (final String code in [
      'withdraw_weekly_limit',
      'withdraw_no_balance',
      'withdraw_minimum',
      'withdraw_insufficient_balance',
    ]) {
      test('C-$code is blocked and refreshes wallet and withdrawals', () {
        final d = classifyWithdraw(403, [code]);
        expect(d.outcome, WithdrawOutcome.blocked);
        expect(d.refreshWallet, isTrue);
        expect(d.refreshWithdrawals, isTrue);
      });
    }

    test('C-withdraw_amount is invalidInput with a silent wallet refresh', () {
      final d = classifyWithdraw(403, ['withdraw_amount']);
      expect(d.outcome, WithdrawOutcome.invalidInput);
      expect(d.refreshWallet, isTrue);
      expect(d.refreshWithdrawals, isFalse);
    });

    for (final String code in ['withdraw', 'rider_withdraw_account_required']) {
      test('C-$code is accountProblem and refreshes the wallet', () {
        final d = classifyWithdraw(403, [code]);
        expect(d.outcome, WithdrawOutcome.accountProblem);
        expect(d.refreshWallet, isTrue);
        expect(d.refreshWithdrawals, isFalse);
      });
    }

    test('C-unknown 403 code is failed and refreshes both', () {
      final d = classifyWithdraw(403, ['something_new']);
      expect(d.outcome, WithdrawOutcome.failed);
      expect(d.refreshWallet, isTrue);
      expect(d.refreshWithdrawals, isTrue);
    });
  });

  group('classifyWithdraw: statuses', () {
    test('C-200 is sent and refreshes both', () {
      final d = classifyWithdraw(200, const []);
      expect(d.outcome, WithdrawOutcome.sent);
      expect(d.refreshWallet, isTrue);
      expect(d.refreshWithdrawals, isTrue);
    });

    test('C-401 ends the session with no refresh', () {
      final d = classifyWithdraw(401, const ['auth-001']);
      expect(d.outcome, WithdrawOutcome.sessionEnded);
      expect(d.refreshWallet || d.refreshWithdrawals, isFalse);
    });

    test('C-offline (1) has no refresh', () {
      final d = classifyWithdraw(1, const []);
      expect(d.outcome, WithdrawOutcome.offline);
      expect(d.refreshWallet || d.refreshWithdrawals, isFalse);
    });

    test('C-410 is final: failed, nothing refreshed or retried', () {
      final d = classifyWithdraw(410, const ['endpoint_removed']);
      expect(d.outcome, WithdrawOutcome.failed);
      expect(d.refreshWallet || d.refreshWithdrawals, isFalse);
    });

    test('C-500 is failed with no refresh', () {
      final d = classifyWithdraw(500, const []);
      expect(d.outcome, WithdrawOutcome.failed);
      expect(d.refreshWallet || d.refreshWithdrawals, isFalse);
    });
  });

  group('several codes in errors[]', () {
    test('C-multi the first recognized code in list order wins', () {
      expect(classifyWithdraw(403, ['x_unknown', 'withdraw_minimum', 'amount'])
          .outcome, WithdrawOutcome.blocked);
      expect(classifyWithdraw(403, ['amount', 'withdraw_minimum']).outcome,
          WithdrawOutcome.invalidInput);
      expect(
          classifyWithdraw(403, ['withdraw', 'withdraw_weekly_limit']).outcome,
          WithdrawOutcome.accountProblem);
    });

    test('C-codes errorCodes keeps every code in order and ignores bad items',
        () {
      expect(
          errorCodes({
            'errors': [
              {'code': 'amount', 'message': 'a'},
              'junk',
              {'message': 'no code'},
              {'code': 'withdraw_minimum'},
            ]
          }),
          ['amount', 'withdraw_minimum']);
      expect(errorCodes('not a map'), isEmpty);
      expect(errorCodes({'errors': 'x'}), isEmpty);
    });
  });

  group('classifyDeleteAccount', () {
    test('C-delete outcomes', () {
      expect(classifyDeleteAccount(200, const []), DeleteAccountOutcome.deleted);
      expect(classifyDeleteAccount(404, const ['account']),
          DeleteAccountOutcome.gone);
      expect(classifyDeleteAccount(404, const []), DeleteAccountOutcome.failed);
      expect(classifyDeleteAccount(401, const []),
          DeleteAccountOutcome.sessionEnded);
      expect(classifyDeleteAccount(1, const []), DeleteAccountOutcome.offline);
      expect(classifyDeleteAccount(410, const []), DeleteAccountOutcome.failed);
    });
  });
}
