import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/wallet/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/features/wallet/widgets/withdrawal_details_sheet.dart';
import 'package:doghree_rider/features/wallet/widgets/withdrawal_status_helper.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// Preview block on the balance screen: header + the latest requests.
class WithdrawalHistorySection extends StatelessWidget {
  const WithdrawalHistorySection({super.key});

  static const int _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetBuilder<WalletController>(builder: (c) {
          final bool hasMore = (c.withdrawals?.length ?? 0) > _previewCount;
          return WalletSectionHeader(
            title: 'wallet_withdraw_requests'.tr,
            onSeeAll: hasMore
                ? () => Get.toNamed(RouteHelper.getWithdrawalsRoute())
                : null,
          );
        }),
        SizedBox(height: Dimensions.h12),
        const WithdrawalsBody(limit: _previewCount),
      ],
    );
  }
}

/// Loading / failed / empty / list states. [limit] null = show everything.
class WithdrawalsBody extends StatelessWidget {
  final int? limit;

  const WithdrawalsBody({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return GetBuilder<WalletController>(builder: (c) {
      final List<WalletWithdrawal>? list = c.withdrawals;

      if (list == null) {
        return _StateView(
          child: c.withdrawalsFailed
              ? IconButton(
                  icon: Icon(Icons.refresh, color: cs.onSurfaceVariant),
                  onPressed: () => c.getWithdrawals(),
                )
              : const CircularProgressIndicator(),
        );
      }

      if (list.isEmpty) {
        return _StateView(
          child: Text(
            'wallet_no_withdrawals'.tr,
            style: textRegular().copyWith(color: cs.onSurfaceVariant),
          ),
        );
      }

      return WithdrawalsList(
        items: limit == null ? list : list.take(limit!).toList(),
      );
    });
  }
}

class _StateView extends StatelessWidget {
  final Widget child;

  const _StateView({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.h25),
      child: Center(child: child),
    );
  }
}

/// Rows straight on the page, separated by hairlines.
class WithdrawalsList extends StatelessWidget {
  final List<WalletWithdrawal> items;

  const WithdrawalsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return WalletActivityList(
      rows: [for (final WalletWithdrawal item in items) WithdrawalTile(item: item)],
    );
  }
}

class WithdrawalTile extends StatelessWidget {
  final WalletWithdrawal item;

  const WithdrawalTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return WalletActivityRow(
      avatarName: item.methodName,
      color: item.statusColor,
      title: item.methodName,
      subtitle: item.requestedAtText,
      logoUrl: item.logoUrl,
      amount: PriceConverterHelper.convertPrice(item.amount),
      statusLabel: item.statusText,
      onTap: () => showWithdrawalDetails(item),
    );
  }
}