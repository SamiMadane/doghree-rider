import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';

class PaymentSuccessfulWidget extends StatelessWidget {
  final bool success;
  const PaymentSuccessfulWidget({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(title: '', isBackButtonExist: false),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(Dimensions.p20),
        margin: const EdgeInsets.only(top: Dimensions.p16),
        color: Theme.of(context).cardColor,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(success ? ManagerAssets.checked : ManagerAssets.warning,
              width: 100,
              height: 100,
              color: success ? Colors.green : Colors.red),
          const SizedBox(height: Dimensions.p20),
          Text(
            success ? 'payment_success_title'.tr : 'payment_failed_title'.tr,
            style: robotoSemiBold.copyWith(fontSize: Dimensions.fs28),
          ),
          SizedBox(height: Dimensions.p10),
          Text(
            success
                ? 'payment_success_description'.tr
                : 'payment_failed_description'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fs18,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: Dimensions.p30),
          Padding(
            padding: const EdgeInsets.all(Dimensions.p10),
            child: CustomButtonWidget(
                buttonText: 'okay'.tr,
                onPressed: () =>
                    Get.offAllNamed(RouteHelper.getInitialRoute())),
          ),
        ]),
      )),
    );
  }
}
