import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? fontColor;
  final bool isLoading;
  final bool isBold;
  final bool isBorder;
  final Color? borderColor;
  const CustomButtonWidget(
      {super.key,
      this.onPressed,
      required this.buttonText,
      this.transparent = false,
      this.margin,
      this.width,
      this.height,
      this.fontSize,
      this.radius = Dimensions.radiusLarge,
      this.icon,
      this.backgroundColor,
      this.fontColor,
      this.isLoading = false,
      this.isBold = true,
      this.isBorder = false,
      this.borderColor
      });

  @override
  Widget build(BuildContext context) {
    final customColor = Theme.of(context).extension<CustomColorsExtension>()!;

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null
          ? Theme.of(context).disabledColor
          : transparent
              ? Colors.transparent
              : backgroundColor ?? Theme.of(context).primaryColor,
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth,
          height != null ? height! : 50),
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side:
            isBorder ? BorderSide(color: borderColor ?? customColor.strock2) : BorderSide.none,
      ),
    );

    return Center(
        child: SizedBox(
            width: width ?? Dimensions.webMaxWidth,
            child: Padding(
              padding: margin == null ? const EdgeInsets.all(0) : margin!,
              child: TextButton(
                onPressed: isLoading ? null : onPressed as void Function()?,
                style: flatButtonStyle,
                child: isLoading
                    ? Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Text('loading'.tr,
                                  style: robotoMedium.copyWith(
                                      color: Colors.white)),
                            ]),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            icon != null
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        right:
                                            Dimensions.paddingSizeExtraSmall),
                                    child: icon
                                  )
                                : const SizedBox(),
                            Text(buttonText,
                                textAlign: TextAlign.center,
                                style: isBold
                                    ? robotoSemiBold.copyWith(
                                        color: fontColor ??
                                            (transparent
                                                ? Theme.of(context).primaryColor
                                                : Colors.white),
                                        fontSize: fontSize ??
                                            Dimensions.fontSizeLarge,
                                      )
                                    : robotoRegular.copyWith(
                                        color: fontColor ??
                                            (transparent
                                                ? Theme.of(context).primaryColor
                                                : Colors.white),
                                        fontSize: fontSize ??
                                            Dimensions.fontSizeLarge,
                                      )),
                          ]),
              ),
            )));
  }
}
