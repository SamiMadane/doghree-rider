import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';

class TransactionHistorySection extends StatelessWidget {
  final CashInHandController cashInHandController;

  const TransactionHistorySection(
      {Key? key, required this.cashInHandController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactions = cashInHandController.walletProvidedTransactions;

    return Column(
      children: [
        // Transaction History + View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "transaction_history".tr,
              style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
            ),
            (transactions?.isEmpty ?? true)
                ? const SizedBox()
                : InkWell(
                    onTap: () =>
                        Get.toNamed(RouteHelper.getWalletProvidedEarningRoute()),
                    child: Text(
                      'view_all'.tr,
                      style: textMedium().copyWith(
                        fontSize: Dimensions.fs16,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
          ],
        ),
        SizedBox(height: Dimensions.h16),

        _TransactionList(transactions: transactions),
      ],
    );
  }
}

// ويدجت للقائمة
class _TransactionList extends StatelessWidget {
  final List? transactions;

  const _TransactionList({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 250),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (transactions!.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: Dimensions.h16),
        color: Theme.of(context).cardColor,
        child: EmptyStateWidget(
          image: ManagerAssets.noTransactionImage,
          title: 'no_transaction_found'.tr,
          description: 'get_ready_receive_first_order_track_earnings'.tr,
          spacing: Dimensions.h4,
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions!.length > 25 ? 25 : transactions!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = transactions![index];
        final status = item.status ?? '';
        final statusColor = status == 'approved' || status == 'Approved'
            ? ManagerColors.darkGreen
            : status == 'denied' ||
                    status == 'Denied' ||
                    status == 'pending' ||
                    status == 'Pending'
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).primaryColor;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PriceConverterHelper.convertPrice(item.amount),
                        style:
                            textSemiBold().copyWith(fontSize: Dimensions.fs15),
                        textDirection: TextDirection.ltr,
                      ),
                      SizedBox(height: Dimensions.h8),
                      Text(
                        '${'wallet'.tr} ${_capitalize(item.method?.replaceAll('_', ' '))}',
                        style: textRegular().copyWith(
                          fontSize: Dimensions.fs12,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.paymentTime.toString(),
                      style: textRegular().copyWith(
                        fontSize: Dimensions.fs12,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    SizedBox(height: Dimensions.h8),
                    Text(
                      _capitalize(status.toString().tr),
                      style: textSemiBold().copyWith(
                        fontSize: Dimensions.fs12,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: Dimensions.h16),
          ],
        );
      },
    );
  }
}

String _capitalize(String? value) {
  if (value == null || value.isEmpty) return '';
  return value[0].toUpperCase() + value.substring(1);
}