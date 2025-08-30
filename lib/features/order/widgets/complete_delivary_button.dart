import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/order/widgets/collect_money_delivery_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/order/widgets/verify_delivery_sheet_widget.dart';

class CompleteDeliveryButton extends StatelessWidget {
  final dynamic order;
  final bool orderVerificationActive;
  final bool cod;
  final bool partialPay;

  const CompleteDeliveryButton({
    super.key,
    required this.order,
    required this.orderVerificationActive,
    required this.cod,
    required this.partialPay,
  });

  @override
  Widget build(BuildContext context) {

    return CustomButtonWidget(
      buttonText: 'complete_delivery'.tr,
      onPressed: () {
        if (orderVerificationActive) {
          Get.find<NotificationController>()
              .sendDeliveredNotification(order.id);

          Get.bottomSheet(
            VerifyDeliverySheetWidget(
              currentOrderModel: order,
              verify: orderVerificationActive,
              orderAmount: partialPay
                  ? order.payments![1].amount!.toDouble()
                  : order.orderAmount,
              cod: cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'),
            ),
            isScrollControlled: true,
          ).then((isSuccess) {
            if (isSuccess &&
                (cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'))) {
              Get.bottomSheet(
                CollectMoneyDeliverySheetWidget(
                  currentOrderModel: order,
                  verify: orderVerificationActive,
                  orderAmount: partialPay
                      ? order.payments![1].amount!.toDouble()
                      : order.orderAmount,
                  cod: cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'),
                ),
                isScrollControlled: true,
                isDismissible: false,
              );
            }
          });
        } else {
          Get.bottomSheet(
            CollectMoneyDeliverySheetWidget(
              currentOrderModel: order,
              verify: orderVerificationActive,
              orderAmount: partialPay
                  ? order.payments![1].amount!.toDouble()
                  : order.orderAmount,
              cod: cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'),
            ),
            isScrollControlled: true,
          );
        }
      },
    );
  }
}
