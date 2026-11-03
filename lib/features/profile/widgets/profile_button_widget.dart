import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:doghree_rider/common/widgets/custom_switch.dart';
import 'package:doghree_rider/util/dimensions.dart';
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    final Color ink = cs.onSurface;
    final Color resolvedIcon = iconColor ?? ink;
    final Color resolvedTitle = titleColor ?? ink;
    // Brand tint for normal rows, soft tint of the icon color otherwise (logout).
    final Color tileBg = iconColor == null
        ? cs.primaryContainer
        : iconColor!.withValues(alpha: 0.12);

    return InkWell(
      onTap: isButtonActive == null ? onTap : null,
      child: Row(
        children: [
          CircleAvatar(
            radius: Dimensions.r20,
            backgroundColor: tileBg,
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
          SizedBox(width: Dimensions.w12),
          Expanded(
            child: Text(
              title,
              style: textMedium().copyWith(
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
                : Icon(
                    rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: Dimensions.w24,
                    color: cs.onSurfaceVariant,
                  ),
        ],
      ),
    );
  }
}