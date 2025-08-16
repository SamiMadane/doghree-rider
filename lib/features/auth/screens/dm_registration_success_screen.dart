import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';

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
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
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
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                'application_submitted'.tr,
                style: robotoSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'application_received_message'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
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
