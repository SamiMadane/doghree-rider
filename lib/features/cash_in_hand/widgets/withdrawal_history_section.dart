import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/cash_in_hand/screens/withdrawals_screen.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/withdrawal_details_sheet.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class WithdrawalHistorySection extends StatelessWidget {
  const WithdrawalHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashInHandController>(builder: (c) {
      final list = c.withdrawals;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('wallet_withdraw_requests'.tr,
                style: textSemiBold().copyWith(fontSize: Dimensions.fs16)),
          ),
          if ((list?.length ?? 0) > 3)
            TextButton(
              onPressed: () => Get.toNamed(RouteHelper.getWithdrawalsRoute()),
              child: Text('wallet_see_all'.tr),
            ),
        ]),
        SizedBox(height: Dimensions.h16),
        if (list == null)
          Center(
            child: c.withdrawalsFailed
                ? IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => c.getWithdrawals())
                : const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator()),
          )
        else if (list.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.h20),
            child: Center(
              child: Text('wallet_no_withdrawals'.tr,
                  style: textRegular()
                      .copyWith(color: Theme.of(context).hintColor)),
            ),
          )
        else
          for (final w in list.take(3)) WithdrawalTile(item: w),
      ]);
    });
  }
}

class WithdrawalTile extends StatelessWidget {
  final WalletWithdrawal item;
  const WithdrawalTile({super.key, required this.item});

  String get _label {
    switch (item.status) {
      case 'pending':
        return 'wallet_status_pending'.tr;
      case 'paid':
        return 'wallet_status_paid'.tr;
      case 'rejected':
        return 'wallet_status_rejected'.tr;
      default:
        return item.statusLabel;
    }
  }

  Color get _color {
    switch (item.status) {
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String get _date {
    final d = item.requestedAt;
    if (d == null) return '';
    return '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final String account = [item.methodName, item.accountSummary]
        .where((e) => e.isNotEmpty)
        .join(' · ');

    return InkWell(
      onTap: () => showWithdrawalDetails(item),
      child: Padding(
        padding: EdgeInsets.only(bottom: Dimensions.h16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(PriceConverterHelper.convertPrice(item.amount),
                        style:
                            textSemiBold().copyWith(fontSize: Dimensions.fs15),
                        textDirection: TextDirection.ltr),
                    SizedBox(height: Dimensions.h4),
                    if (account.isNotEmpty)
                      Text(account,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textRegular().copyWith(
                              fontSize: Dimensions.fs12,
                              color: Theme.of(context).disabledColor)),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_date,
                  style: textRegular().copyWith(
                      fontSize: Dimensions.fs12,
                      color: Theme.of(context).disabledColor)),
              SizedBox(height: Dimensions.h4),
              Text(_label,
                  style: textSemiBold()
                      .copyWith(fontSize: Dimensions.fs12, color: _color)),
            ]),
            SizedBox(width: Dimensions.w8),
            Icon(Icons.chevron_right,
                size: 18, color: Theme.of(context).disabledColor),
          ]),
          SizedBox(height: Dimensions.h8),
          Divider(
              height: 1,
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
        ]),
      ),
    );
  }
}