import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class ProfileButtonWidget extends StatelessWidget {
  final IconData? iconData;
  final String? svgPath;
  final String title;
  final bool? isButtonActive;
  final VoidCallback onTap;
  final bool showTrailing;
  final Color? titleColor;
  final Color? iconColor;
  final Widget? trailingWidget; // مكون اختياري قبل السهم

  const ProfileButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.iconData,
    this.svgPath,
    this.isButtonActive,
    this.showTrailing = true,
    this.titleColor,
    this.iconColor,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;
    var isArabic =
        Get.locale?.languageCode == AppConstants.languages[1].languageCode;

    return InkWell(
      onTap: isButtonActive == null ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            // أيقونة داخل دائرة
            CircleAvatar(
              radius: Dimensions.r16,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: SizedBox(
                width: 22,
                height: 22,
                child: iconData != null
                    ? Icon(
                        iconData,
                        size: 22,
                        color: iconColor ??
                            ((isButtonActive == null)
                                ? Theme.of(context).textTheme.bodyMedium!.color
                                : (isButtonActive!
                                    ? ManagerColors.darkGreen
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color)),
                      )
                    : SvgPicture.asset(
                        svgPath!,
                        width: 22,
                        height: 22,
                        color: iconColor ??
                            ((isButtonActive == null)
                                ? Theme.of(context).textTheme.bodyMedium!.color
                                : (isButtonActive!
                                    ? ManagerColors.darkGreen
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color)),
                      ),
              ),
            ),
            SizedBox(width: Dimensions.w10),

            // النص
            Expanded(
              child: Text(
                title,
                style: textRegular().copyWith(
                  fontSize: Dimensions.fs16,
                  color: titleColor ??
                      (isButtonActive == true
                          ? ManagerColors.darkGreen
                          : Theme.of(context).textTheme.bodyMedium!.color),
                ),
              ),
            ),

            // المكون الاختياري قبل السهم
            if (trailingWidget != null) ...[
              trailingWidget!,
              SizedBox(width: Dimensions.w10),
            ],

            // السهم أو السويتش
            if (showTrailing)
              isButtonActive != null
                  ? Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: isButtonActive!,
                        onChanged: (bool? value) => onTap(),
                        activeTrackColor: ManagerColors.darkGreen,
                        inactiveTrackColor: customColor.strock2,
                      ),
                    )
                  : isArabic
                      ? SvgPicture.asset(
                          ManagerAssets.arrowBackIcon,
                          height: 22,
                          width: 22,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        )
                      : SvgPicture.asset(
                          ManagerAssets.arrowRightIcon,
                          height: 22,
                          width: 22,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
          ],
        ),
      ),
    );
  }
}
