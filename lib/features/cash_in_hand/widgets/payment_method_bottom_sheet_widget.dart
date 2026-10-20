import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class PaymentMethodBottomSheetWidget extends StatefulWidget {
  const PaymentMethodBottomSheetWidget({super.key});

  @override
  State<PaymentMethodBottomSheetWidget> createState() =>
      _PaymentMethodBottomSheetWidgetState();
}

class _PaymentMethodBottomSheetWidgetState
    extends State<PaymentMethodBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Container(
      padding: EdgeInsets.only(
          top: Dimensions.h10, left: Dimensions.w16, right: Dimensions.w16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.r20),
          topRight: Radius.circular(Dimensions.r20),
        ),
      ),
      child: GetBuilder<CashInHandController>(builder: (cashInHandController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(
                alignment: Alignment.center,
                child: Text('payment_method'.tr,
                    style: textBold().copyWith(fontSize: Dimensions.fs16))),
            SizedBox(height: Dimensions.h16),
            Row(children: [
              Text('pay_via_online'.tr,
                  style: textBold().copyWith(fontSize: Dimensions.fs14)),
              Flexible(
                child: Text(
                  ' (${'faster_and_secure_way_to_pay_bill'.tr})',
                  style: textMedium().copyWith(
                      fontSize: Dimensions.fs12,
                      color: Theme.of(context).hintColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ]),
          SizedBox(height: Dimensions.h16),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ListView.builder(
                itemCount: Get.find<SplashController>()
                    .configModel!
                    .activePaymentMethodList!
                    .length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isSelected = cashInHandController.paymentIndex == 1 &&
                      Get.find<SplashController>()
                              .configModel!
                              .activePaymentMethodList![index]
                              .getWay! ==
                          cashInHandController.digitalPaymentName;

                  return InkWell(
                    onTap: () {
                      cashInHandController.setPaymentIndex(1);
                      cashInHandController.changeDigitalPaymentName(
                          Get.find<SplashController>()
                              .configModel!
                              .activePaymentMethodList![index]
                              .getWay!);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: Dimensions.h10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.r10),
                        border: Border.all(
                          color: customColor.strock1,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.w16, vertical: Dimensions.h20),
                      child: Row(children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? ManagerColors.darkGreen
                                : Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).disabledColor),
                          ),
                          child: Icon(Icons.check,
                              color: Theme.of(context).cardColor, size: 16),
                        ),
                        SizedBox(width: Dimensions.w16),
                        Text(
                          Get.find<SplashController>()
                              .configModel!
                              .activePaymentMethodList![index]
                              .getWayTitle!,
                          style:
                              textMedium().copyWith(fontSize: Dimensions.fs14),
                        ),
                        const Spacer(),
                        CustomImageWidget(
                          height: 20,
                          fit: BoxFit.contain,
                          image:
                              '${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl}',
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
              padding: EdgeInsets.symmetric(vertical: Dimensions.h16),
              child: CustomButtonWidget(
                  radius: Dimensions.r10,
                  buttonText: 'select'.tr,
                  onPressed: () async {
                    double amount = Get.find<ProfileController>()
                        .profileModel!
                        .payableBalance!;
                    cashInHandController.makeCollectCashPayment(
                        amount, cashInHandController.digitalPaymentName!);
                  }),
            ),
          ),
        ]);
      }),
    );
  }
}
