import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';

class PaymentMethodBottomSheetWidget extends StatefulWidget {
  const PaymentMethodBottomSheetWidget({super.key});

  @override
  State<PaymentMethodBottomSheetWidget> createState() => _PaymentMethodBottomSheetWidgetState();
}

class _PaymentMethodBottomSheetWidgetState extends State<PaymentMethodBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: Dimensions.p10, left: Dimensions.p16, right: Dimensions.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.r20),
          topRight: Radius.circular(Dimensions.r20),
        ),
      ),
      child: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            height: 5, width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.r4),
            ),
          ),
          const SizedBox(height: Dimensions.p16),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Align(alignment: Alignment.center, child: Text('payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fs16))),
            const SizedBox(height: Dimensions.p16),

            Row(children: [

              Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fs14)),

              Flexible(
                child: Text(
                  '(${'faster_and_secure_way_to_pay_bill'.tr})',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fs12, color: Theme.of(context).hintColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),

            ]),

          ]),
          const SizedBox(height: Dimensions.p16),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ListView.builder(
                itemCount: Get.find<NavigationHandlerController>().configModel!.activePaymentMethodList!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){

                  bool isSelected = cashInHandController.paymentIndex == 1 && Get.find<NavigationHandlerController>().configModel!.activePaymentMethodList![index].getWay! == cashInHandController.digitalPaymentName;

                  return InkWell(
                    onTap: (){
                      cashInHandController.setPaymentIndex(1);
                      cashInHandController.changeDigitalPaymentName(Get.find<NavigationHandlerController>().configModel!.activePaymentMethodList![index].getWay!);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: Dimensions.p10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.r10),
                        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.4)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.p16, vertical: Dimensions.p20),
                      child: Row(children: [
                        Container(
                          height: 20, width: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: isSelected ? Colors.green : Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).disabledColor),
                          ),
                          child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                        ),
                        const SizedBox(width: Dimensions.p16),

                        Text(
                          Get.find<NavigationHandlerController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fs14),
                        ),
                        const Spacer(),

                        CustomImageWidget(
                          height: 20, fit: BoxFit.contain,
                          image: '${Get.find<NavigationHandlerController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl}',
                        ),

                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.p16),
              child: CustomButtonWidget(
                radius: Dimensions.r10,
                buttonText: 'select'.tr,
                onPressed: () {
                  double amount = Get.find<ProfileController>().profileModel!.payableBalance!;
                  cashInHandController.makeCollectCashPayment(amount, cashInHandController.digitalPaymentName!);
                }
              ),
            ),
          ),

        ]);
      }),
    );
  }
}
