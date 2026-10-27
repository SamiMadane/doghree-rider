import 'package:doghree_rider/common/widgets/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

class ProfileButtonWidget extends StatelessWidget {
  final IconData? iconData;
  final String? svgPath;
  final String title;
  final bool? isButtonActive;
  final VoidCallback onTap;
  final bool showTrailing;
  final Color? titleColor;
  final Color? iconColor;
  final Widget? trailingWidget;

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
    final theme = Theme.of(context);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    final Color ink = theme.textTheme.bodyMedium!.color!;
    final Color resolvedIcon = iconColor ?? ink;
    final Color resolvedTitle = titleColor ?? ink;

    return InkWell(
      onTap: isButtonActive == null ? onTap : null,
      child: Container(
        decoration: BoxDecoration(color: theme.cardColor),
        child: Row(
          children: [
            CircleAvatar(
              radius: Dimensions.r16,
              backgroundColor: theme.scaffoldBackgroundColor,
              child: SizedBox(
                width: Dimensions.w22,
                height: Dimensions.w22,
                child: iconData != null
                    ? Icon(iconData, size: Dimensions.w22, color: resolvedIcon)
                    : SvgPicture.asset(
                        svgPath!,
                        width: Dimensions.w22,
                        height: Dimensions.w22,
                        colorFilter:
                            ColorFilter.mode(resolvedIcon, BlendMode.srcIn),
                      ),
              ),
            ),
            SizedBox(width: Dimensions.w10),
            Expanded(
              child: Text(
                title,
                style: textRegular().copyWith(
                  fontSize: Dimensions.fs16,
                  color: resolvedTitle,
                ),
              ),
            ),
            if (trailingWidget != null) ...[
              trailingWidget!,
              SizedBox(width: Dimensions.w10),
            ],
            if (showTrailing)
              isButtonActive != null
                  ? Transform.scale(
                      scale: 0.8,
                      child: CustomSwitch(
                        value: isButtonActive!,
                        onChanged: (_) => onTap(),
                      ),
                    )
                  : SvgPicture.asset(
                      rtl
                          ? ManagerAssets.arrowBackIcon
                          : ManagerAssets.arrowRightIcon,
                      height: Dimensions.w22,
                      width: Dimensions.w22,
                      colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
                    ),
          ],
        ),
      ),
    );
  }
}
