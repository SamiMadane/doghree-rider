import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/util/manager_colors.dart';

extension WalletWithdrawalX on WalletWithdrawal {
  String get statusText {
    switch (status) {
      case 'pending':
        return 'wallet_status_pending'.tr;
      case 'paid':
        return 'wallet_status_paid'.tr;
      case 'rejected':
        return 'wallet_status_rejected'.tr;
      default:
        return statusLabel;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'paid':
        return ManagerColors.success;
      case 'rejected':
        return ManagerColors.error;
      default:
        return ManagerColors.warning;
    }
  }

  String get accountText =>
      [methodName, accountSummary].where((e) => e.isNotEmpty).join(' · ');

  String get requestedAtText {
    final d = requestedAt;
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}