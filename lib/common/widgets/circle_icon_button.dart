import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:doghree_rider/util/dimensions.dart';

/// Round outlined button with a line SVG icon. Used in app bars
/// (earnings: download + filter, balance: earnings details).
/// The badge is brand yellow with an asphalt stroke.
class CircleIconButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback onTap;
  final String? tooltip;
  final bool isLoading;
  final bool showBadge;

  const CircleIconButton({
    super.key,
    required this.iconAsset,
    required this.onTap,
    this.tooltip,
    this.isLoading = false,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    Widget button = Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          shape: CircleBorder(side: BorderSide(color: cs.outline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: Dimensions.w40,
              height: Dimensions.w40,
              child: Center(
                child: SizedBox(
                  width: Dimensions.w20,
                  height: Dimensions.w20,
                  child: isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: Dimensions.w2,
                          color: cs.onSurface,
                        )
                      : SvgPicture.asset(
                          iconAsset,
                          colorFilter: ColorFilter.mode(
                            cs.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        if (showBadge)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Container(
              width: Dimensions.w12,
              height: Dimensions.w12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary,
                border: Border.all(color: cs.onPrimary, width: Dimensions.w2),
              ),
            ),
          ),
      ],
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}