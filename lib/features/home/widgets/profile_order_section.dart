import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/home/widgets/profile_order_card_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';

class ProfileOrdersSection extends StatelessWidget {
  final ProfileController profileController;
  const ProfileOrdersSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Container(
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
      child: Column(
        children: [
          ProfileOrderCardWidget(
            title: 'total_orders'.tr,
            value: profileController.profileModel?.orderCount.toString(),
            imagePath: ManagerAssets.greenCardImage,
            isTopCard: true,
            height: orientation==Orientation.landscape?300:150,
          ),
          SizedBox(
            height:orientation==Orientation.landscape?Dimensions.paddingSizeDefault:0),
          Row(
            children: [
              Expanded(
                child: ProfileOrderCardWidget(
                  title: 'week_orders'.tr,
                  value: profileController.profileModel?.thisWeekOrderCount
                      .toString(),
                  imagePath: ManagerAssets.orangeCardImage,
            height: orientation==Orientation.landscape?250:150,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: ProfileOrderCardWidget(
                  title: 'todays_orders'.tr,
                  value:
                      profileController.profileModel?.todaysOrderCount.toString(),
                  imagePath: ManagerAssets.blueCardImage,
            height: orientation==Orientation.landscape?250:150,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
