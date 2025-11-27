import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/dimensions.dart';

Future<T?> showCustomBottomSheet<T>({
  required Widget child,
  double? maxHeight,
  VoidCallback? onClose,
  bool isDismissible = true,
  bool showCloseButton = true,

  // الألوان الجديدة
  Color? sheetBackgroundColor,
  Color? handleColor,
  Color? closeButtonBackgroundColor,
  Color? closeIconColor,
  Color? overlayColor,
}) {
  return showModalBottomSheet<T>(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    builder: (context) {
      final Color resolvedSheetBg =
          sheetBackgroundColor ?? Theme.of(context).cardColor;

      final Color resolvedHandleColor =
          handleColor ?? Theme.of(context).disabledColor;

      final Color resolvedCloseBg =
          closeButtonBackgroundColor ?? Theme.of(context).cardColor;

      final Color resolvedCloseIcon =
          closeIconColor ?? Theme.of(context).textTheme.bodyMedium!.color!;

      final Color resolvedOverlay = overlayColor ??
          Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.1);

      return Stack(
        children: [
          GestureDetector(
            onTap: isDismissible ? () => Navigator.of(context).pop() : null,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: resolvedOverlay),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: resolvedSheetBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.r20),
                  topRight: Radius.circular(Dimensions.r20),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight:
                    maxHeight ?? MediaQuery.of(context).size.height * 0.8,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: Dimensions.p6,
                          left: Dimensions.p12,
                          right: Dimensions.p12,
                          top: Dimensions.p12,
                        ),
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.r16),
                            color: resolvedHandleColor,
                          ),
                        ),
                      ),
                      child,
                    ],
                  ),
                  if (showCloseButton)
                    Positioned(
                      top: -16,
                      right: 16,
                      child: GestureDetector(
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.p10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: resolvedCloseBg,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(Dimensions.p4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: resolvedCloseBg,
                              border: Border.all(
                                color: resolvedCloseIcon,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: resolvedCloseIcon,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
