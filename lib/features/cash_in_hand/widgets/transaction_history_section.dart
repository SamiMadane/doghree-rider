import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';

/// Preview block on the balance screen. Hidden while empty or loading.
class TransactionHistorySection extends StatelessWidget {
  const TransactionHistorySection({super.key});

  static const int _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashInHandController>(builder: (c) {
      final list = c.walletProvidedTransactions;
      if (list == null || list.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: Dimensions.h25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WalletSectionHeader(
              title: 'transaction_history'.tr,
              onSeeAll: () =>
                  Get.toNamed(RouteHelper.getWalletProvidedEarningRoute()),
            ),
            SizedBox(height: Dimensions.h12),
            TransactionsList(transactions: list.take(_previewCount).toList()),
          ],
        ),
      );
    });
  }
}

/// Rows straight on the page, separated by hairlines.
class TransactionsList extends StatelessWidget {
  final List transactions;

  const TransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return WalletActivityList(
      rows: [
        for (final item in transactions)
          _TransactionTile(
            amount: item.amount,
            method: item.method,
            time: item.paymentTime.toString(),
            status: item.status ?? '',
          ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final num? amount;
  final String? method;
  final String time;
  final String status;

  const _TransactionTile({
    required this.amount,
    required this.method,
    required this.time,
    required this.status,
  });

  bool get _approved => status.toLowerCase() == 'approved';
  bool get _denied => status.toLowerCase() == 'denied';

  Color get _color => _approved
      ? ManagerColors.success
      : _denied
          ? ManagerColors.error
          : ManagerColors.warning;

  @override
  Widget build(BuildContext context) {
    return WalletActivityRow(
      avatarName: method?.replaceAll('_', ' ') ?? '',
      color: _color,
      title: '${'wallet'.tr} ${_capitalize(method?.replaceAll('_', ' '))}'.trim(),
      subtitle: time,
      amount: PriceConverterHelper.convertPrice(amount?.toDouble()),
      statusLabel: _capitalize(status.tr),
    );
  }
}

String _capitalize(String? value) {
  if (value == null || value.isEmpty) return '';
  return value[0].toUpperCase() + value.substring(1);
}