import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool iconOnRight;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final FontWeight fontWeight;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconOnRight = false,
    this.borderColor,
    this.textColor,
    this.borderRadius = Dimensions.r16,
    this.fontSize = Dimensions.fs16,
    this.iconSize = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.width,
    this.height,
    this.margin,
    this.fontWeight = FontWeight.w500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = [
      if (icon != null && !iconOnRight)
        Icon(icon, size: iconSize, color: textColor ?? Theme.of(context).primaryColor),
      if (icon != null && !iconOnRight)
        const SizedBox(width: 8),
      Text(
        text,
        style: robotoMedium.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor ?? Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
      if (icon != null && iconOnRight)
        const SizedBox(width: 8),
      if (icon != null && iconOnRight)
        Icon(icon, size: iconSize, color: textColor ?? Theme.of(context).primaryColor),
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding,
          side: BorderSide(
            color: borderColor ?? Theme.of(context).disabledColor,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: content,
        ),
      ),
    );
  }
}
