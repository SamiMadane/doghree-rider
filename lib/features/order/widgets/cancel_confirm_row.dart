import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:wefrh_rider/common/widgets/confirmation_dialog_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/order/widgets/cancellation_dialogue_widget.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';

class CancelConfirmRow extends StatelessWidget {
  final dynamic order;
  final bool parcel;
  final bool orderVerificationActive;

  const CancelConfirmRow({
    super.key,
    required this.order,
    required this.parcel,
    required this.orderVerificationActive,
  });

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              orderController.setOrderCancelReason('');
              Get.dialog(CancellationDialogueWidget(orderId: order.id));
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(1170, 40),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.r4),
                side: BorderSide(
                  width: 1,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
            ),
            child: Text(
              'cancel'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fs16,
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.p10),
        Expanded(
          child: CustomButtonWidget(
            buttonText: 'confirm'.tr,
            height: 40,
            onPressed: () {
              Get.dialog(
                ConfirmationDialogWidget(
                  icon: ManagerAssets.warning,
                  title: 'are_you_sure_to_confirm'.tr,
                  description: parcel
                      ? 'you_want_to_confirm_this_delivery'.tr
                      : 'you_want_to_confirm_this_order'.tr,
                  onYesPressed: () {
                    orderController.updateOrderStatus(
                      order,
                      parcel ? AppConstants.handover : AppConstants.confirmed,
                      back: true,
                      gotoDashboard: false,
                    );
                  },
                ),
                barrierDismissible: false,
              );
            },
          ),
        ),
      ],
    );
  }
}