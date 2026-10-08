import 'package:flutter/material.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool iconOnRight;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? borderRadius;
  final double? fontSize;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
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
    this.borderRadius ,
    this.fontSize,
    this.iconSize = 20,
    this.padding,
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
        SizedBox(width: 8),
      Text(
        text,
        style: textMedium().copyWith(
          fontSize: fontSize ?? Dimensions.fs16,
          fontWeight: fontWeight,
          color: textColor ?? Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
      if (icon != null && iconOnRight)
        SizedBox(width: 8),
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
          padding: padding ?? EdgeInsets.symmetric(horizontal: Dimensions.w16, vertical: Dimensions.h12),
          side: BorderSide(
            color: borderColor ?? Theme.of(context).disabledColor,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ??Dimensions.r16,),
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
