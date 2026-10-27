import 'package:flutter/material.dart';
import 'package:doghree_rider/util/theme_extension.dart';


class DashedDivider extends StatelessWidget {
  final Color? color;
  final double dash;
  final double gap;
  final double thickness;

  const DashedDivider({
    super.key,
    this.color,
    this.dash = 7,
    this.gap = 7,
    this.thickness = 2,
  });

  @override
  Widget build(BuildContext context) {
    final Color c = color ??
        Theme.of(context).extension<CustomColorsExtension>()!.strock1;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = ((constraints.maxWidth + gap) / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (_) => SizedBox(
              width: dash,
              height: thickness,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(thickness / 2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}