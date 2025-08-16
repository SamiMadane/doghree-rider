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
    return Column(
      children: [
        ProfileOrderCardWidget(
          title: 'total_orders'.tr,
          value: profileController.profileModel?.orderCount.toString(),
          imagePath: ManagerAssets.greenCardImage,
          isTopCard: true,
          height: 150,
        ),
        Row(
          children: [
            Expanded(
              child: ProfileOrderCardWidget(
                title: 'this_week_orders'.tr,
                value: profileController.profileModel?.thisWeekOrderCount
                    .toString(),
                imagePath: ManagerAssets.orangeCardImage,
                height: 150,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: ProfileOrderCardWidget(
                title: 'todays_orders'.tr,
                value:
                    profileController.profileModel?.todaysOrderCount.toString(),
                imagePath: ManagerAssets.blueCardImage,
                height: 150, // حسب التصميم بالفوغا
              ),
            ),
          ],
        ),
      ],
    );
  }
}
