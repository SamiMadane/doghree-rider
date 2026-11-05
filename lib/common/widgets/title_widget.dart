import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final bool showOrderCount;
  final Object? orderCount;
  final TextStyle? titleStyle;
  final TextStyle? countStyle;
  final Color? backGroundColorOfCount;
  final EdgeInsetsGeometry? padding;

  const TitleWidget({
    super.key,
    required this.title,
    this.onTap,
    this.showOrderCount = false,
    this.orderCount,
    this.titleStyle,
    this.countStyle,
    this.backGroundColorOfCount,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme cs = theme.colorScheme;

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: Dimensions.w4),
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
                    Container(
                      constraints: BoxConstraints(
                        minWidth: Dimensions.r8 * 2,
                        minHeight: Dimensions.r8 * 2,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.w6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: backGroundColorOfCount ?? cs.primary,
                        borderRadius: BorderRadius.circular(Dimensions.r50),
                      ),
                      child: Text(
                        '$orderCount',
                        style: countStyle ??
                            textBold().copyWith(
                              fontSize: Dimensions.fs12,
                              color: cs.onPrimary,
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
                      color: cs.tertiary,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
