import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_asset_image_widget.dart';
import 'package:wefrh_rider/features/splash/controllers/splash_controller.dart';
import 'package:wefrh_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';

class EmptyStateBottomSheet extends StatelessWidget {
  final bool noPaymentMethod;
  const EmptyStateBottomSheet({super.key, this.noPaymentMethod = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: const EdgeInsets.all(Dimensions.p20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.r20),
          topRight: Radius.circular(Dimensions.r20),
        ),
      ),
      child: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [

         

          Text(noPaymentMethod ? 'payment_method'.tr : 'insufficient_balance'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fs16)),
          const SizedBox(height: Dimensions.p20),

          Container(
            padding: const EdgeInsets.all(40),
            width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.r10),
            ),
            child: Column(children: [

              const CustomAssetImageWidget(
                image: ManagerAssets.emptyPaymentIcon,
                height: 50, width: 50,
              ),
              const SizedBox(height: Dimensions.p10),

              Text(
                noPaymentMethod ? 'no_payment_method_is_available'.tr : '${'you_do_not_have_sufficient_balance_to_pay_the_minimum_payable_balance_is'.tr} ${PriceConverterHelper.convertPrice(Get.find<SplashController>().configModel!.minAmountToPayDm)}',
                style: robotoRegular.copyWith(fontSize: Dimensions.fs14, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: noPaymentMethod ? Dimensions.p4 : 0),

              noPaymentMethod ? Text(
                'please_contact_the_admin'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fs12, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5)),
                textAlign: TextAlign.center,
              ) : const SizedBox(),

            ]),
          ),

        ]);
      }),
    );
  }
}
