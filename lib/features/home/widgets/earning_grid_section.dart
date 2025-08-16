import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/home/widgets/earning_tile.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';


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
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Dimensions.paddingSizeLarge,
              crossAxisSpacing: Dimensions.paddingSizeLarge,
              childAspectRatio: 1.4,
              children: [
                EarningTile(
                  title: 'Total Earnings',
                  amount: profile.balance,
                  showAmount: showEarnings.value,
                  onEyeTap: () => showEarnings.value = !showEarnings.value,
                ),
                EarningTile(
                  title: 'Today',
                  amount: profile.todaysEarning,
                  showAmount: showEarnings.value,
                ),
                EarningTile(
                  title: 'This Week',
                  amount: profile.thisWeekEarning,
                  showAmount: showEarnings.value,
                ),
                EarningTile(
                  title: 'This Month',
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


