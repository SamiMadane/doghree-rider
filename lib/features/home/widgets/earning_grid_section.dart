import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/home/widgets/earning_tile.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';


class EarningsGridSection extends StatelessWidget {
  final ProfileController profileController;
  final RxBool showEarnings; // الآن تتحكم بجميع المربعات

  const EarningsGridSection({
    super.key,
    required this.profileController,
    required this.showEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final profile = profileController.profileModel;

    if (profile == null || profile.earnings != 1) return const SizedBox();

    return Obx(
      () => Container(
        margin: EdgeInsets.only(top: Dimensions.h20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Dimensions.h16,
              crossAxisSpacing: Dimensions.w16,
              childAspectRatio: 1.4,
              children: [
                EarningTile(
                  title: 'total_earnings'.tr,
                  amount: profile.balance,
                  showAmount: showEarnings.value,
                  onEyeTap: () => showEarnings.value = !showEarnings.value,
                ),
                EarningTile(
                  title: 'today'.tr,
                  amount: profile.todaysEarning,
                  showAmount: showEarnings.value,
                ),
                EarningTile(
                  title: 'this_week'.tr,
                  amount: profile.thisWeekEarning,
                  showAmount: showEarnings.value,
                ),
                EarningTile(
                  title: 'this_month'.tr,
                  amount: profile.thisMonthEarning,
                  showAmount: showEarnings.value,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


