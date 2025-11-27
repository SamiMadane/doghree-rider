import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class CustomConfirmationBottomSheet extends StatelessWidget {
  final String? image;
  final String title;
  final String? description;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final Function? onConfirm;
  final Widget? buttonWidget;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? buttonColor;

  const CustomConfirmationBottomSheet({
    super.key,
    this.image,
    required this.title,
    this.description,
    this.confirmButtonText,
    this.cancelButtonText,
    this.onConfirm,
    this.buttonWidget,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedBg = backgroundColor ?? Theme.of(context).cardColor;
    final Color resolvedText =
        textColor ?? Theme.of(context).textTheme.bodyMedium!.color!;
    final Color resolvedBorder =
        borderColor ?? Theme.of(context).textTheme.bodyMedium!.color!;

    return GetBuilder<OrderController>(builder: (orderController) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        return GetBuilder<AuthController>(builder: (authController) {
          return Container(
            width: context.width,
            padding: const EdgeInsets.all(Dimensions.p10),
            decoration: BoxDecoration(
              color: resolvedBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.r20),
                topRight: Radius.circular(Dimensions.r20),
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              image != null
                  ? Image.asset(image!, height: 60, width: 60)
                  : SizedBox(),
              const SizedBox(height: Dimensions.p20),
              Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fs18,
                  color: resolvedText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.p16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Text(
                  description ?? '',
                  style: robotoRegular.copyWith(
                      color: resolvedText.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: description == null ? 0 : 30),
              buttonWidget ??
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Dimensions.p10),
                    child: Row(children: [
                      Expanded(
                        child: CustomButtonWidget(
                          onPressed: () => Get.back(),
                          buttonText: cancelButtonText ?? 'cancel'.tr,
                          backgroundColor: resolvedBg,
                          fontColor: resolvedText,
                          borderColor: resolvedBorder,
                          transparent: true,
                          isBorder: true,
                        ),
                      ),
                      const SizedBox(width: Dimensions.p16),
                      Expanded(
                        child: CustomButtonWidget(
                          onPressed: () => onConfirm?.call(),
                          isLoading: orderController.isLoading ||
                              authController.isLoading ||
                              profileController.isLoading,
                          buttonText: confirmButtonText ?? 'accept'.tr,
                          backgroundColor: buttonColor ?? Theme.of(context).primaryColor,
                        ),
                      ),
                    ]),
                  ),
              SizedBox(height: Dimensions.p20),
            ]),
          );
        });
      });
    });
  }
}
