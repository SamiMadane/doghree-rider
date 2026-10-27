import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/payment_method_bottom_sheet_widget.dart';

class WalletAttentionAlertWidget extends StatelessWidget {
  final bool isOverFlowBlockWarning;
  const WalletAttentionAlertWidget({super.key, required this.isOverFlowBlockWarning});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GetBuilder<ProfileController>(
      builder: (profileController) {
        return Container(
          width: context.width * 0.95,
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.10),  
            borderRadius: BorderRadius.circular(Dimensions.r10),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [

              Image.asset(ManagerAssets.attentionWarningIcon, width: 20, height: 20),
              SizedBox(width: Dimensions.w10),

              Text('attention_please'.tr, style: textBold().copyWith(fontSize: Dimensions.fs12, color: cs.onSurface,  )),

            ]),
            SizedBox(height: Dimensions.h10),

            isOverFlowBlockWarning ? RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                text: '${'over_flow_block_warning_message'.tr}  ',
                style: textRegular().copyWith(fontSize: Dimensions.fs12, color: cs.onSurface),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = () {
                      if(profileController.profileModel!.showPayNowButton!) {
                        showModalBottomSheet(
                          isScrollControlled: true, useRootNavigator: true, context: context,
                          backgroundColor: Theme.of(context).cardColor, 
                          shape:  RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.r20), topRight: Radius.circular(Dimensions.r20)),
                          ),
                          builder: (context) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                              child: const PaymentMethodBottomSheetWidget(),
                            );
                          },
                        );
                      } else {
                        if(Get.find<SplashController>().configModel!.activePaymentMethodList!.isEmpty || !Get.find<SplashController>().configModel!.digitalPayment!){
                          showCustomSnackBar('currently_there_are_no_payment_options_available_please_contact_admin_regarding_any_payment_process_or_queries'.tr);
                        }else if(Get.find<SplashController>().configModel!.minAmountToPayDm! > profileController.profileModel!.payableBalance!){
                          showCustomSnackBar('${'you_do_not_have_sufficient_balance_to_pay_the_minimum_payable_balance_is'.tr} ${PriceConverterHelper.convertPrice(Get.find<SplashController>().configModel!.minAmountToPayDm)}');
                        }
                      }
                    },
                    text: 'pay_the_due'.tr,
                    style: textRegular().copyWith(fontSize: Dimensions.fs12, color: cs.tertiary, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ) : Text('over_flow_warning_message'.tr, style: textRegular().copyWith(fontSize: Dimensions.fs12, color: cs.onSurface)),
          ]),
        );
      }
    );
  }
}