import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

/// Small edit badge shown on the corner of a profile avatar.
class AvatarEditBadge extends StatelessWidget {
  final VoidCallback onTap;

  const AvatarEditBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Light: soft black shadow. Dark: soft yellow glow (black is invisible there).
    final Color shadowColor = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.12);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: Dimensions.w32,
        height: Dimensions.w32,
        decoration: BoxDecoration(
          color: theme.cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            ManagerAssets.editIcon,
            width: Dimensions.w16,
            height: Dimensions.w16,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.tertiary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
