import 'package:flutter/material.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;
  final bool isBorder;
  final Color? borderColor;
  final double? borderwidth;

  final bool autoWidth;

  final bool hasInnerBottomShadow;

  const CustomCard({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.padding,
    this.fillColor,
    this.isBorder = true,
    this.borderColor,
    this.borderwidth,
    this.autoWidth = false,
    this.hasInnerBottomShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    Widget content = child ?? const SizedBox();

    // 👇 في حال autoWidth مفعّل والنص هو الـ child، نخليه سطر واحد فقط
    if (autoWidth && child is Text) {
      final textWidget = child as Text;
      content = Text(
        textWidget.data ?? '',
        style: textWidget.style,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        textAlign: textWidget.textAlign,
      );
    }

    // 👇 الكارد الأساسي
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.r20),
      child: Stack(
        children: [
          Container(
            width: autoWidth ? null : (width ?? double.infinity),
            height: height,
            margin: margin,
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor ?? Theme.of(context).cardColor,
              borderRadius:
                  BorderRadius.circular(borderRadius ?? Dimensions.r20),
              border: isBorder
                  ? Border.all(
                      color: borderColor ?? customColor.strock2,
                      width: borderwidth ?? 1,
                    )
                  : null,
            ),
            child: content,
          ),
          if (hasInnerBottomShadow)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: Dimensions.h6,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromARGB(40, 0, 0, 0),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return autoWidth ? IntrinsicWidth(child: card) : card;
  }
}
