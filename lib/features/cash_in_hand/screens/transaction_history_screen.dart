import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/empty_state_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    Get.find<CashInHandController>().getWalletPaymentList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'payment_history'.tr),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w16,
          vertical: Dimensions.h16,
        ),
        margin: EdgeInsets.only(top: Dimensions.h16),
        color: Theme.of(context).cardColor,
        height: double.maxFinite,
        child:
            GetBuilder<CashInHandController>(builder: (cashInHandController) {
          return cashInHandController.transactions != null
              ? cashInHandController.transactions!.isNotEmpty
                  ? ListView.builder(
                      itemCount: cashInHandController.transactions!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = cashInHandController.transactions![index];
                        final status = item.status ?? '';
                        final statusColor =
                            status == 'approved' || status == 'Approved'
                                ? ManagerColors.darkGreen
                                : status == 'denied'
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).primaryColor;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        PriceConverterHelper.convertPrice(
                                            item.amount),
                                        style: textSemiBold().copyWith(
                                            fontSize: Dimensions.fs15),
                                        textDirection: TextDirection.ltr,
                                      ),
                                      SizedBox(height: Dimensions.h8),
                                      Text(
                                        '${'paid_via'.tr} ${_capitalize(item.method?.replaceAll('_', ' '))}',
                                        style: textRegular().copyWith(
                                          fontSize: Dimensions.fs12,
                                          color:
                                              Theme.of(context).disabledColor,
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
                                      _capitalize(status),
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
                    )
                  : Container(
                      margin: EdgeInsets.only(top: Dimensions.h16),
                      color: Theme.of(context).cardColor,
                      child: EmptyStateWidget(
                        image: ManagerAssets.noTransactionImage,
                        title: 'no_transaction_found'.tr,
                        description:
                            'get_ready_receive_first_order_track_earnings'.tr,
                        spacing: Dimensions.h4,
                      ),
                    )
              : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}

String _capitalize(String? value) {
  if (value == null || value.isEmpty) return '';
  return value[0].toUpperCase() + value.substring(1);
}
