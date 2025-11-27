import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/features/profile/widgets/profile_button_widget.dart';
import 'package:wefrh_rider/features/splash/controllers/splash_controller.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class EarningsSection extends StatelessWidget {
  final ProfileController profileController;

  const EarningsSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final profile = profileController.profileModel;
    final navController = Get.find<SplashController>();

    // نتأكد أن المستخدم لديه أرباح
    if (profile == null || profile.earnings == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'earnings'.tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fs16),
        ),
        SizedBox(height: Dimensions.p16),
        CustomCard(
          padding: EdgeInsets.all(Dimensions.p16),
          isBorder: false,
          child: Column(
            children: [
              // زر الأرباح الشخصية
              if (profile.earnings == 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.p10),
                  child: ProfileButtonWidget(
                    iconData: Icons.monetization_on,
                    title: 'my_earning'.tr,
                    onTap: () {
                      Get.toNamed(RouteHelper.getMyEarningRoute());
                    },
                  ),
                ),

              // أزرار المدفوعات وطرق السحب
              if (navController.configModel?.disbursementType == 'automated' &&
                  profile.type != 'store_wise' &&
                  profile.earnings != 0)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.p10),
                      child: ProfileButtonWidget(
                        iconData: Icons.payments,
                        title: 'disbursement'.tr,
                        onTap: () {
                          Get.toNamed(RouteHelper.getDisbursementRoute());
                        },
                      ),
                    ),
                    ProfileButtonWidget(
                      iconData: Icons.money,
                      title: 'disbursement_methods'.tr,
                      onTap: () {
                        Get.toNamed(RouteHelper.getWithdrawMethodRoute());
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
