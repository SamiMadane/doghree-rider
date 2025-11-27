import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_asset_image_widget.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';

class DmRegistrationSuccessScreen extends StatelessWidget {
  const DmRegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'join_delivery_partner'.tr,
        isBackButtonExist: false,
     
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: Dimensions.p16),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.p16),
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomAssetImageWidget(
                image: ManagerAssets.applicationSubmittedImage,
                height: 200,
                width: 200,
              ),
              const SizedBox(height: Dimensions.p20),
              Text(
                'application_submitted'.tr,
                style: robotoSemiBold.copyWith(
                  fontSize: Dimensions.fs24,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.p10),
              Text(
                'application_received_message'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fs16,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              CustomButtonWidget(
                buttonText: 'go_back_to_login_page'.tr,
                onPressed: () {
                  Get.offAllNamed(RouteHelper.getSignInRoute());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
