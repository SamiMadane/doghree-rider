import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;
  final bool isBorder;
  const CustomCard(
      {super.key,
      this.child,
      this.width,
      this.height,
      this.borderRadius,
      this.margin,
      this.padding,
      this.isBorder = true,
      this.fillColor});

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor ?? Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(borderRadius ?? Dimensions.r20),
        border:
            isBorder ? Border.all(color: customColor.strock2, width: 1) : null,
      ),
      child: child,
    );
  }
}
