import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/slider_button_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class DeliveredBottomSheet extends StatelessWidget {
  final String beneficiaryName;

  const DeliveredBottomSheet({super.key, required this.beneficiaryName});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                ManagerAssets.checkIcon,
                color: ManagerColors.greenLightMode,
              ),
              SizedBox(width: Dimensions.w4),
              Text(
                'confirmation_of_delivery'.tr,
                style: textBold().copyWith(
                  fontSize: Dimensions.fs20,
                  color: ManagerColors.greenLightMode,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.h16),
          CustomCard(
            padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'are_you_sure_package_delivered'.tr,
                  style: textRegular().copyWith(
                    fontSize: Dimensions.fs16,
                  ),
                ),
                SizedBox(height: Dimensions.h8),
                Text(
                  beneficiaryName,
                  style: textBold().copyWith(
                    fontSize: Dimensions.fs16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.h50),
          SliderButton(
            action: () async {
              print('Confirmed delivery for $beneficiaryName');
            },
            label: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.ltr,
              children: [
                Text(
                  'pull_to_confirm'.tr,
                  style: textMedium().copyWith(fontSize: Dimensions.fs16),
                ),
                SizedBox(width: 8),
                SvgPicture.asset(
                  ManagerAssets.pullArrowIcon,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
            dismissThresholds: 0.5,
            dismissible: false,
            shimmer: true,
            width: 1170,
            height: 60,
            buttonSize: 50,
            radius: 10,
            icon: Center(
              child: SvgPicture.asset(
                ManagerAssets.checkIcon,
                color: ManagerColors.white,
              ),
            ),
            buttonColor: ManagerColors.greenLightMode,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          SizedBox(height: Dimensions.h20),
          CustomButtonWidget(
            buttonText: 'cancel'.tr,
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: customColor.disabledButton,
            fontColor: Theme.of(context).disabledColor,
            radius: Dimensions.r12,
          ),
        ],
      ),
    );
  }
}
