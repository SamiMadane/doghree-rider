import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/empty_state_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class TransactionBottomSheet extends StatelessWidget {
  const TransactionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    final bool showAdjust = profileController.profileModel!.adjustable!;
    final bool showPayNow = true;

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buttons.length > 1
              ? Text(
                  'choose_type'.tr,
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                  ),
                )
              : SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // الأزرار
          buttons.length == 1
              ? SizedBox(
                  width: double.infinity,
                  child: buttons.first,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buttons,
                ),
        ],
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
        final cashInHandController = Get.find<CashInHandController>();

        showCustomBottomSheet(
          child: ConfirmationBottomSheet(
            title: 'cash_adjustment'.tr,
            description: 'cash_adjustment_description'.tr,
            acceptText: 'yes_adjust'.tr,
            acceptColor: Theme.of(context).primaryColor,
            cancelText: 'no_cancel'.tr,
            hasCancel: true,
            onAccept: () {
              cashInHandController.makeWalletAdjustment();
            },
            onCancel: () => Get.back(),
          ),
        );
      },
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: Theme.of(context).dividerTheme.color!,
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
              Center(
                child: Image.asset(
                  ManagerAssets.adjustPaymentImage,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Center(
                child: Text(
                  'adjust_payments'.tr,
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).disabledColor),
                ),
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
          showCustomBottomSheet(child: PaymentMethodBottomSheetWidget());
        } else {
          if (Get.find<NavigationHandlerController>()
                  .configModel!
                  .activePaymentMethodList!
                  .isEmpty ||
              !Get.find<NavigationHandlerController>()
                  .configModel!
                  .digitalPayment!) {
            showCustomBottomSheet(
              child: EmptyStateBottomSheet(
                noPaymentMethod: true,
              ),
            );
          } else if (Get.find<NavigationHandlerController>()
                  .configModel!
                  .minAmountToPayDm! >
              profileController.profileModel!.payableBalance!) {
            showCustomBottomSheet(child: EmptyStateBottomSheet());
          }
        }
      },
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: Theme.of(context).dividerTheme.color!,
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
              Center(
                child: Image.asset(
                  ManagerAssets.payNowImage,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Center(
                child: Text(
                  'pay_now'.tr,
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).disabledColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
