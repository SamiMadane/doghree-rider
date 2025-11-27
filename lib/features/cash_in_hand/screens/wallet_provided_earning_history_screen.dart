import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';

class WalletProvidedHistoryScreen extends StatefulWidget {
  const WalletProvidedHistoryScreen({super.key});

  @override
  State<WalletProvidedHistoryScreen> createState() =>
      _WalletProvidedHistoryScreenState();
}

class _WalletProvidedHistoryScreenState
    extends State<WalletProvidedHistoryScreen> {
  @override
  void initState() {
    Get.find<CashInHandController>().getWalletProvidedEarningList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'wallet_provided_earning_history'.tr),
      body: Container(
        padding: const EdgeInsets.all(Dimensions.p16),
        margin: const EdgeInsets.only(top: Dimensions.p16),
        color: Theme.of(context).cardColor,
        height: double.maxFinite,
        child:
            GetBuilder<CashInHandController>(builder: (cashInHandController) {
          return cashInHandController.walletProvidedTransactions != null
              ? cashInHandController.walletProvidedTransactions!.isNotEmpty
                  ? ListView.builder(
                      itemCount: cashInHandController.transactions!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = cashInHandController.transactions![index];
                        final status = item.status ?? '';
                        final statusColor = status == 'approved' || status == 'Approved'
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
                                        style: robotoSemiBold.copyWith(
                                            fontSize: Dimensions.fs15),
                                        textDirection: TextDirection.ltr,
                                      ),
                                      const SizedBox(height: Dimensions.p8),
                                      Text(
                                        '${'wallet'.tr} ${_capitalize(item.method?.replaceAll('_', ' '))}',
                                        style: robotoRegular.copyWith(
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
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fs12,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.p8),
                                    Text(
                                      _capitalize(status),
                                      style: robotoSemiBold.copyWith(
                                        fontSize: Dimensions.fs12,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.p16),
                          ],
                        );
                      },
                    )
                  : Center(child: Text('no_transaction_found'.tr))
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
