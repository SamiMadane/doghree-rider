import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/withdrawal_details_sheet.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/withdrawal_status_helper.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class WithdrawalHistorySection extends StatelessWidget {
  const WithdrawalHistorySection({super.key});

  static const int _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return GetBuilder<CashInHandController>(builder: (c) {
      final list = c.withdrawals;
      final items =
          list?.take(_previewCount).toList() ?? const <WalletWithdrawal>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'wallet_withdraw_requests'.tr,
                  style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
                ),
              ),
              if ((list?.length ?? 0) > _previewCount)
                TextButton(
                  onPressed: () =>
                      Get.toNamed(RouteHelper.getWithdrawalsRoute()),
                  child: Text('wallet_see_all'.tr),
                ),
            ],
          ),
          SizedBox(height: Dimensions.h8),
          if (list == null)
            Center(
              child: c.withdrawalsFailed
                  ? IconButton(
                      icon: Icon(Icons.refresh, color: scheme.onSurfaceVariant),
                      onPressed: () => c.getWithdrawals(),
                    )
                  : Padding(
                      padding: EdgeInsets.all(Dimensions.w24),
                      child: const CircularProgressIndicator(),
                    ),
            )
          else if (list.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.h20),
              child: Center(
                child: Text(
                  'wallet_no_withdrawals'.tr,
                  style:
                      textRegular().copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else
            for (int i = 0; i < items.length; i++)
              WithdrawalTile(
                item: items[i],
                showDivider: i < items.length - 1,
              ),
        ],
      );
    });
  }
}

class WithdrawalTile extends StatelessWidget {
  final WalletWithdrawal item;
  final bool showDivider;

  const WithdrawalTile({
    super.key,
    required this.item,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle muted = textRegular().copyWith(
      fontSize: Dimensions.fs12,
      color: scheme.onSurfaceVariant,
    );

    return Column(
      children: [
        InkWell(
          onTap: () => showWithdrawalDetails(item),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.h12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Line 1: amount + status badge
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                PriceConverterHelper.convertPrice(item.amount),
                                textDirection: TextDirection.ltr,
                                style: textSemiBold().copyWith(
                                  fontSize: Dimensions.fs16,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Dimensions.w8),
                          _StatusBadge(item: item),
                        ],
                      ),
                      SizedBox(height: Dimensions.h6),
                      // Line 2: account + date
                      Row(
                        children: [
                          Expanded(
                            child: item.accountText.isEmpty
                                ? const SizedBox()
                                : Text(
                                    item.accountText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: muted,
                                  ),
                          ),
                          SizedBox(width: Dimensions.w8),
                          Text(
                            item.requestedAtText,
                            textDirection: TextDirection.ltr,
                            style: muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Dimensions.w8),
                // chevron_right mirrors itself automatically in RTL.
                Icon(
                  Icons.chevron_right,
                  size: Dimensions.w18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: scheme.outline),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final WalletWithdrawal item;

  const _StatusBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w10,
        vertical: Dimensions.h4,
      ),
      decoration: BoxDecoration(
        color: item.statusColor,
        borderRadius: BorderRadius.circular(Dimensions.r50),
      ),
      child: Text(
        item.statusText,
        style: textSemiBold().copyWith(
          fontSize: Dimensions.fs12,
          color: item.onStatusColor,
        ),
      ),
    );
  }
}