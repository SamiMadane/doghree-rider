import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String icon;
  final double iconSize;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final bool hasCancel;
  const ConfirmationDialogWidget({super.key, required this.icon, this.iconSize = 50, this.title, required this.description, required this.onYesPressed,
    this.isLogOut = false, this.hasCancel = true});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r4)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.p20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.p20),
            child: Image.asset(icon, width: iconSize, height: iconSize),
          ),

          title != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.p20),
            child: Text(
              title!, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fs18, color: Colors.red),
            ),
          ) : const SizedBox(),

          Padding(
            padding: const EdgeInsets.all(Dimensions.p10),
            child: Text(description, style: robotoMedium.copyWith(fontSize: Dimensions.fs16), textAlign: TextAlign.center),
          ),
          const SizedBox(height: Dimensions.p20),

          GetBuilder<OrderController>(builder: (orderController) {
            return !orderController.isLoading ? Row(children: [

              hasCancel ? Expanded(child: TextButton(
                onPressed: () => isLogOut ? onYesPressed() : Get.back(),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3), minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r4)),
                ),
                child: Text(
                  isLogOut ? 'yes'.tr : 'no'.tr, textAlign: TextAlign.center,
                  style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              )) : const SizedBox(),
              SizedBox(width: hasCancel ? Dimensions.p20 : 0),

              Expanded(child: CustomButtonWidget(
                buttonText: isLogOut ? 'no'.tr : hasCancel ? 'yes'.tr : 'ok'.tr,
                onPressed: () => isLogOut ? Get.back() : onYesPressed(),
                height: 40,
              )),

            ]) : const Center(child: CircularProgressIndicator());
          }),

        ]),
      ),
    );
  }
}