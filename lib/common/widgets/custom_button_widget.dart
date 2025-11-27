import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/dimensions.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final bool isBorder;
  final bool isBold;
  final bool isViewReply;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? fontColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? color;
  final IconData? iconData;
  final Widget? icon;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final FontWeight? fontWeight;
  final bool autoWidth;

  const CustomButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.fontSize,
    this.radius = 16,
    this.backgroundColor,
    this.fontColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.color,
    this.icon,
    this.iconData,
    this.isLoading = false,
    this.isBold = true,
    this.isBorder = false,
    this.isViewReply = false,
    this.fontWeight,
    this.autoWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor = onPressed == null
        ? Theme.of(context).disabledColor
        : transparent
            ? Colors.transparent
            : backgroundColor ?? color ?? Theme.of(context).primaryColor;

    final Color effectiveTextColor = textColor ??
        fontColor ??
        (transparent || isViewReply
            ? Theme.of(context).primaryColor
            : onPressed == null
                ? Theme.of(context).cardColor
                : Colors.white);

    Widget buttonContent;

    if (isLoading) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? Colors.white),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'loading'.tr,
            style: TextStyle(
                color: textColor ?? Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      );
    } else {
      buttonContent = Row(
        mainAxisSize: autoWidth ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.p8),
              child: icon!,
            ),
          if (icon == null && iconData != null)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.p8),
              child: Icon(
                iconData,
                color: iconColor ??
                    (transparent ? Theme.of(context).primaryColor : Colors.white),
              ),
            ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              buttonText,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: effectiveTextColor,
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? (isBold ? FontWeight.w600 : FontWeight.normal),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: autoWidth ? null : width ?? double.infinity,
        height: height ?? 50,
        child: TextButton(
          onPressed: isLoading ? null : onPressed as void Function()?,
          style: TextButton.styleFrom(
            backgroundColor: effectiveBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: isBorder
                  ? BorderSide(color: borderColor ?? Colors.grey, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: buttonContent,
        ),
      ),
    );
  }
}
