import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

Future<T?> showCustomBottomSheet<T>({
  required Widget child,
  double? maxHeight,
  VoidCallback? onClose,
  bool showCloseButton = true,
}) {
  return showModalBottomSheet<T>(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // مهم عشان نشوف الضبابية
    barrierColor: Colors.transparent, // نخلي التحكم بإيدنا
    builder: (context) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.1)),
            ),
          ),

          // ✅ البوتوم شيت نفسه
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                      if (!showCloseButton)
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.p12),
                          child: Container(
                            height: 5,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.r16),
                              color: Theme.of(context).disabledColor,
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
                            color: Theme.of(context).cardColor,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border:
                                  Border.all(color:(Theme.of(context).textTheme.bodyMedium?.color)! , width: 1.5),
                            ),
                            padding: EdgeInsets.all(Dimensions.p4),
                            child: Icon(Icons.close,
                                size: 20,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
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
