import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/home/widgets/profile_order_card_widget.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';

class ProfileOrdersSection extends StatelessWidget {
  final ProfileController profileController;
  const ProfileOrdersSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    var isArabic =
        Get.locale?.languageCode == AppConstants.languages[1].languageCode;

    return Container(
      margin: EdgeInsets.only(top: Dimensions.h20),
      child: Column(
        children: [
          ProfileOrderCardWidget(
            title: 'total_orders'.tr,
            value: profileController.profileModel?.orderCount.toString(),
            imagePath: isArabic
                ? ManagerAssets.greenCardArabicImage
                : ManagerAssets.greenCardImage,
            isTopCard: true,
            height: orientation == Orientation.landscape ? 320 : 150,
          ),
          SizedBox(
              height: orientation == Orientation.landscape
                  ? Dimensions.h16
                  : 0),
          Row(
            children: [
              Expanded(
                child: ProfileOrderCardWidget(
                  title: 'weeks_orders'.tr,
                  value: profileController.profileModel?.thisWeekOrderCount
                      .toString(),
                  imagePath: isArabic
                      ? ManagerAssets.orangeCardArabicImage
                      : ManagerAssets.orangeCardImage,
                  height: orientation == Orientation.landscape ? 270 : 150,
                ),
              ),
              SizedBox(width: Dimensions.w16),
              Expanded(
                child: ProfileOrderCardWidget(
                  title: 'todays_orders'.tr,
                  value: profileController.profileModel?.todaysOrderCount
                      .toString(),
                  imagePath: isArabic
                      ? ManagerAssets.blueCardArabicImage
                      : ManagerAssets.blueCardImage,
                  height: orientation == Orientation.landscape ? 270 : 150,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
