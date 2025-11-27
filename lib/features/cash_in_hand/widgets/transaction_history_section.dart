import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';

class TransactionHistorySection extends StatelessWidget {
  final CashInHandController cashInHandController;

  const TransactionHistorySection(
      {Key? key, required this.cashInHandController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // زرّين التبديل
        Row(
          children: [
            Expanded(
              child: _TransactionToggleButton(
                text: 'payment_history'.tr,
                isSelected: cashInHandController.selectedIndex == 0,
                onTap: () {
                  if (cashInHandController.selectedIndex != 0) {
                    cashInHandController.setIndex(0);
                  }
                },
              ),
            ),
            const SizedBox(width: Dimensions.p10),
            Expanded(
              child: _TransactionToggleButton(
                text: 'wallet_provided_earning'.tr,
                isSelected: cashInHandController.selectedIndex == 1,
                onTap: () {
                  if (cashInHandController.selectedIndex != 1) {
                    cashInHandController.setIndex(1);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.p25),

        // Transaction History + View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "transaction_history".tr,
              style: robotoSemiBold.copyWith(fontSize: Dimensions.fs16),
            ),
            (cashInHandController.selectedIndex == 0 &&
                        cashInHandController.transactions!.isEmpty) ||
                    (cashInHandController.selectedIndex == 1 &&
                        cashInHandController
                            .walletProvidedTransactions!.isEmpty)
                ? const SizedBox()
                : InkWell(
                    onTap: () {
                      if (cashInHandController.selectedIndex == 0) {
                        Get.toNamed(RouteHelper.getTransactionHistoryRoute());
                      } else {
                        Get.toNamed(
                            RouteHelper.getWalletProvidedEarningRoute());
                      }
                    },
                    child: Text(
                      'view_all'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fs16,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: Dimensions.p16),

        // القوائم
        if (cashInHandController.selectedIndex == 0)
          _TransactionList(
            transactions: cashInHandController.transactions,
            isWallet: false,
          ),
        if (cashInHandController.selectedIndex == 1)
          _TransactionList(
            transactions: cashInHandController.walletProvidedTransactions,
            isWallet: true,
          ),
      ],
    );
  }
}

// ويدجت للزر الواحد
class _TransactionToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransactionToggleButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButtonWidget(
      buttonText: text,
      fontSize: Dimensions.fs14,
      backgroundColor: isSelected
          ? Theme.of(context).textTheme.bodyMedium!.color
          : Theme.of(context).cardColor,
      fontColor: isSelected
          ? Theme.of(context).cardColor
          : Theme.of(context).disabledColor,
      isBold: isSelected,
      isBorder: !isSelected,
      onPressed: onTap,
    );
  }
}

// ويدجت للقائمة
class _TransactionList extends StatelessWidget {
  final List? transactions;
  final bool isWallet;

  const _TransactionList(
      {Key? key, required this.transactions, required this.isWallet})
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
      return Center(child: Text('no_transaction_found'.tr));
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
                            robotoSemiBold.copyWith(fontSize: Dimensions.fs15),
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(height: Dimensions.p8),
                      Text(
                        isWallet
                            ? '${'wallet'.tr} ${_capitalize(item.method?.replaceAll('_', ' '))}'
                            : '${'paid_via'.tr} ${_capitalize(item.method?.replaceAll('_', ' '))}',
                        style: robotoRegular.copyWith(
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
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fs12,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.p8),
                    Text(
                      _capitalize(status.toString().tr),
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
    );
  }
}

String _capitalize(String? value) {
  if (value == null || value.isEmpty) return '';
  return value[0].toUpperCase() + value.substring(1);
}
