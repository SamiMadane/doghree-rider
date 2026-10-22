import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';

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
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color effectiveBgColor = onPressed == null
        ? theme.disabledColor
        : transparent
            ? Colors.transparent
            : backgroundColor ?? color ?? theme.primaryColor;

    // Text/icon ON a filled background: asphalt on light backgrounds
    // (yellow included), white on dark ones. Never white on yellow.
    final Color onBgColor =
        ThemeData.estimateBrightnessForColor(effectiveBgColor) ==
                Brightness.light
            ? ManagerColors.onPrimary
            : Colors.white;

    // Text/icon on a transparent button (sits on the page background):
    // yellow text on white is forbidden, so light mode uses textAccent.
    final Color accentColor =
        isDark ? ManagerColors.primaryDark : ManagerColors.textButtonLight;

    final Color effectiveTextColor = textColor ??
        fontColor ??
        (transparent || isViewReply
            ? accentColor
            : onPressed == null
                ? theme.cardColor
                : onBgColor);

    // Check if there's an icon
    final bool hasIcon = icon != null || iconData != null || isLoading;

    /// ----------------- CONTENT -----------------
    Widget buildText() {
      return Text(
        buttonText,
        softWrap: autoWidth ? false : true,
        overflow: autoWidth ? TextOverflow.visible : TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: effectiveTextColor,
          fontSize: fontSize ?? 16,
          fontWeight:
              fontWeight ?? (isBold ? FontWeight.w600 : FontWeight.normal),
        ),
      );
    }

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
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'loading'.tr,
            style: TextStyle(
                color: effectiveTextColor, fontWeight: FontWeight.w500),
          ),
        ],
      );
    } else if (icon == null && iconData == null) {
      buttonContent = buildText();
    } else {
      buttonContent = Row(
        mainAxisSize: autoWidth ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsetsDirectional.only(end: Dimensions.w8),
              child: IconTheme(
                data: IconThemeData(
                  color: iconColor ?? (transparent ? accentColor : onBgColor),
                ),
                child: icon!,
              ),
            ),
          if (icon == null && iconData != null)
            Padding(
              padding: EdgeInsetsDirectional.only(end: Dimensions.w8),
              child: Icon(
                iconData,
                color: iconColor ?? (transparent ? accentColor : onBgColor),
              ),
            ),
          buildText(),
        ],
      );
    }

    /// ----------------- BUTTON -----------------
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: autoWidth ? null : width ?? double.infinity,
        height: height ?? (autoWidth ? Dimensions.h40 : Dimensions.h50),
        child: TextButton(
          onPressed: isLoading ? null : onPressed as void Function()?,
          style: TextButton.styleFrom(
            backgroundColor: effectiveBgColor,
            // إذا في icon، استخدم padding عادي، وإلا استخدم padding صفر
            padding: autoWidth && !hasIcon
                ? EdgeInsets.symmetric(horizontal: 12)
                : EdgeInsets.symmetric(horizontal: 16),
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