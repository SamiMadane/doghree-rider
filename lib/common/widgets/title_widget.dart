import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/theme_extension.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final bool showOrderCount;
  final int? orderCount;
  final TextStyle? titleStyle;
  final TextStyle? countStyle;
  final Color? backGroundColorOfCount;

  const TitleWidget({
    super.key,
    required this.title,
    this.onTap,
    this.showOrderCount = false,
    this.orderCount,
    this.titleStyle,
    this.countStyle,
    this.backGroundColorOfCount,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.w4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showOrderCount
              ? Row(
                  children: [
                    Text(title,
                        style: titleStyle ??
                            textSemiBold().copyWith(fontSize: Dimensions.fs16)),
                    SizedBox(width: Dimensions.w8),
                    CircleAvatar(
                      radius: Dimensions.r8,
                      backgroundColor:
                          backGroundColorOfCount ?? Theme.of(context).colorScheme.primary,
                      child: Text(
                        '$orderCount',
                        style: countStyle ??
                            textSemiBold().copyWith(
                              fontSize: Dimensions.fs12,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ],
                )
              : Text(title, style: titleStyle ?? textMedium()),
          onTap != null
              ? InkWell(
                  onTap: onTap as void Function()?,
                  child: Text(
                    'view_all'.tr,
                    style: textRegular().copyWith(
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
