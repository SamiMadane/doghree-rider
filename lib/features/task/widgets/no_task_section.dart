import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/features/task/widgets/tip_card_widget.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

class NoTaskSection extends StatelessWidget {
  const NoTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Column(
      children: [
        CustomCard(
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'hello'.tr,
                style: textBold().copyWith(fontSize: Dimensions.fs24),
              ),
              SizedBox(height: Dimensions.h12),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Image.asset(
                      ManagerAssets.deliveryBoyOnScooterImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.h12),
              Text(
                'no_tasks_message'.tr,
                style: textRegular().copyWith(fontSize: Dimensions.fs17),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Dimensions.h20),
              CustomButtonWidget(
                buttonText: 'contact_admin'.tr,
                backgroundColor: ManagerColors.darkGreen,
                radius: Dimensions.r8,
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.h16),
        TipCardWidget(
          title: 'tips_getting_ready'.tr,
          titleColor: customColor.darkBlue,
          backgroundColor: customColor.blueBg, // اختياري
          tips: [
            Tip(text: 'tip_phone_charged'.tr, color: customColor.blue),
            Tip(text: 'tip_check_map'.tr, color: customColor.blue),
            Tip(text: 'tip_contact_supervisor'.tr, color: customColor.blue),
          ],
        ),
        SizedBox(height: Dimensions.h16),
        TipCardWidget(
          title: 'tips_getting_ready'.tr,
          titleColor: customColor.orange,
          backgroundColor: customColor.orangeBg,
          tips: [
            Tip(
              text: 'tip_phone_charged'.tr,
              color: customColor.orange,
            ),
            Tip(
              text: 'tip_check_map'.tr,
              color: customColor.orange,
            ),
            Tip(
              text: 'tip_contact_supervisor'.tr,
              color: customColor.orange,
            ),
          ],
        ),
      ],
    );
  }
}
