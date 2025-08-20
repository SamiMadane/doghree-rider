import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/empty_state_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class TransactionBottomSheet extends StatelessWidget {
  const TransactionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    final bool showAdjust = profileController.profileModel!.adjustable!;
    final bool showPayNow = true; // دايمًا موجود حسب منطقك

    final buttons = <Widget>[];

    if (showAdjust) {
      buttons.add(const Expanded(child: AdjustPaymentButton()));
    }

    if (showPayNow) {
      if (showAdjust) {
        buttons.add(const SizedBox(width: Dimensions.paddingSizeLarge));
      }
      buttons.add(const Expanded(child: PayNowButton()));
    }

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: buttons.length == 1
          ? SizedBox(
              width: double.infinity,
              child: buttons.first) // زر واحد ياخد العرض كامل
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons,
            ),
    );
  }
}

class AdjustPaymentButton extends StatelessWidget {
  const AdjustPaymentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return GetBuilder<CashInHandController>(
              builder: (cashInHandController) {
                return AlertDialog(
                  title: Center(child: Text('cash_adjustment'.tr)),
                  content: Text(
                    'cash_adjustment_description'.tr,
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: CustomButtonWidget(
                                onPressed: () => Get.back(),
                                backgroundColor: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.5),
                                buttonText: 'cancel'.tr,
                              ),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                cashInHandController.makeWalletAdjustment();
                              },
                              child: Container(
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: !cashInHandController.isLoading
                                    ? Text(
                                        'ok'.tr,
                                        style: robotoBold.copyWith(
                                          color: Theme.of(context).cardColor,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: const Color(0xFFE5E5E5),
          strokeWidth: 1,
          strokeCap: StrokeCap.butt,
          dashPattern: const [8, 5],
          padding: const EdgeInsets.all(5),
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomImageWidget(
                image: 'assets/images/adjust_payment.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'adjust_payments'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PayNowButton extends StatelessWidget {
  const PayNowButton({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return InkWell(
      onTap: () {
        if (profileController.profileModel!.showPayNowButton!) {
          Get.bottomSheet(const PaymentMethodBottomSheetWidget());
        } else {
          if (Get.find<NavigationHandlerController>()
                  .configModel!
                  .activePaymentMethodList!
                  .isEmpty ||
              !Get.find<NavigationHandlerController>()
                  .configModel!
                  .digitalPayment!) {
            Get.bottomSheet(
              EmptyStateBottomSheet(
                noPaymentMethod: true,
              ),
            );
          } else if (Get.find<NavigationHandlerController>()
                  .configModel!
                  .minAmountToPayDm! >
              profileController.profileModel!.payableBalance!) {
            Get.bottomSheet(const EmptyStateBottomSheet());
          }
        }
      },
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: const Color(0xFFE5E5E5),
          strokeWidth: 1,
          strokeCap: StrokeCap.butt,
          dashPattern: const [8, 5],
          padding: const EdgeInsets.all(5),
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomImageWidget(
                image: 'assets/images/pay_now.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'pay_now'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
