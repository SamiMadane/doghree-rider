import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_asset_image_widget.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';

class DmRegistrationSuccessScreen extends StatelessWidget {
  const DmRegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'join_as_a_delivery_man'.tr,
        isBackButtonExist: false,
     
      ),
      body: Padding(
        padding: EdgeInsets.only(top: Dimensions.h16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               CustomAssetImageWidget(
                image: ManagerAssets.applicationSubmittedImage,
                fit: BoxFit.contain,
                height: Dimensions.h300,  
                width: Dimensions.w300,
              ),
              SizedBox(height: Dimensions.h20),
              Text(
                'application_submitted'.tr,
                style: textSemiBold().copyWith(
                  fontSize: Dimensions.fs24,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Dimensions.h10),
              Text(
                'application_received_message'.tr,
                style: textRegular().copyWith(
                  fontSize: Dimensions.fs16,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Dimensions.h50),
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
