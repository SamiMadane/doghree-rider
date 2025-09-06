import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/task/widgets/tip_card_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class NoTaskSection extends StatelessWidget {
  const NoTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Column(
      children: [
        CustomCard(
          padding: const EdgeInsets.all(Dimensions.p16),
          child: Column(
            children: [
              Text(
                'hello'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fs24),
              ),
              const SizedBox(height: Dimensions.p12),
              Image.asset(ManagerAssets.deliveryBoyOnScooterImage),
              const SizedBox(height: Dimensions.p12),
              Text(
                'no_tasks_message'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fs17),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.p20),
              CustomButtonWidget(
                buttonText: 'contact_admin'.tr,
                backgroundColor: ManagerColors.darkGreen,
                radius: Dimensions.r8,
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.p16),
        TipCardWidget(
          title: 'tips_getting_ready'.tr,
          titleColor: ManagerColors.darkBlueLightMode,
          backgroundColor: customColor.blueBg, // اختياري
          tips: [
            Tip(text: 'tip_phone_charged'.tr, color: ManagerColors.blueLightMode),
            Tip(text: 'tip_check_map'.tr, color: ManagerColors.blueLightMode),
            Tip(text: 'tip_contact_supervisor'.tr, color: ManagerColors.blueLightMode),
          ],
        ),
        const SizedBox(height: Dimensions.p16),
        TipCardWidget(
          title: 'tips_getting_ready'.tr,
          titleColor: ManagerColors.yallow,
          backgroundColor: ManagerColors.yallowBg,
          tips: [
            Tip(text: 'tip_phone_charged'.tr, color: ManagerColors.yallow),
            Tip(text: 'tip_check_map'.tr, color: ManagerColors.yallow),
            Tip(text: 'tip_contact_supervisor'.tr, color: ManagerColors.yallow),
          ],
        ),
      ],
    );
  }
}
