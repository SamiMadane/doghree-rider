import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';

class PaymentSuccessfulWidget extends StatelessWidget {
  final bool success;
  const PaymentSuccessfulWidget({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(title: '', isBackButtonExist: false),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.w20, vertical: Dimensions.h20),
        margin: EdgeInsets.only(top: Dimensions.h16),
        color: Theme.of(context).cardColor,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(success ? ManagerAssets.checked : ManagerAssets.warning,
              width: 80,
              height: 80,
              color: success ? Colors.green : Colors.red),
          SizedBox(height: Dimensions.h20),
          Text(
            success ? 'payment_success_title'.tr : 'payment_failed_title'.tr,
            style: textSemiBold().copyWith(fontSize: Dimensions.fs20),
          ),
          SizedBox(height: Dimensions.h10),
          Text(
            success
                ? 'payment_success_description'.tr
                : 'payment_failed_description'.tr,
            textAlign: TextAlign.center,
            style: textRegular().copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          SizedBox(height: Dimensions.h30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:Dimensions.w10 ,vertical: Dimensions.h10,),
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
