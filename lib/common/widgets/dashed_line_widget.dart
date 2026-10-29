import 'package:flutter/material.dart';

/// خط منقط (شحطات) قابل لإعادة الاستخدام، أفقي أو عمودي.
class DashedLine extends StatelessWidget {
  final Color color;
  final double dashLength;
  final double gap;
  final double thickness;
  final double radius;
  final Axis axis;

  const DashedLine({
    super.key,
    required this.color,
    this.dashLength = 7,
    this.gap = 7,
    this.thickness = 2,
    this.radius = 1,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isHorizontal = axis == Axis.horizontal;
        final double available =
            isHorizontal ? constraints.maxWidth : constraints.maxHeight;

        if (!available.isFinite) return const SizedBox.shrink();

        final int count =
            ((available + gap) / (dashLength + gap)).floor().clamp(0, 1000);

        return Flex(
          direction: axis,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (_) => SizedBox(
              width: isHorizontal ? dashLength : thickness,
              height: isHorizontal ? thickness : dashLength,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}