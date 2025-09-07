import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final bool showOrderCount;
  final int? orderCount;
  final TextStyle? titleStyle;
  final TextStyle? countStyle;

  const TitleWidget({
    super.key,
    required this.title,
    this.onTap,
    this.showOrderCount = false,
    this.orderCount,
    this.titleStyle,
    this.countStyle,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.p4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showOrderCount
              ? Row(
                  children: [
                    Text(title,
                        style: titleStyle ??
                            robotoSemiBold.copyWith(fontSize: Dimensions.fs16)),
                    const SizedBox(width: Dimensions.p10),
                    CircleAvatar(
                      radius: Dimensions.r8,
                      backgroundColor: ManagerColors.darkGreen,
                      child: Text(
                        '$orderCount',
                        style: countStyle ??
                            robotoSemiBold.copyWith(
                              fontSize: Dimensions.fs12,
                              color: ManagerColors.white,
                            ),
                      ),
                    ),
                  ],
                )
              : Text(title, style: titleStyle ?? robotoMedium),
          onTap != null
              ? InkWell(
                  onTap: onTap as void Function()?,
                  child: Text(
                    'view_all'.tr,
                    style: robotoRegular.copyWith(
                      color: customColor.naturalBlue,
                       decoration: TextDecoration.underline,
                      decorationColor: customColor.naturalBlue,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
