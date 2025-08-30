import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
void showCustomBottomSheet({
  required Widget child,
  double? maxHeight,
  VoidCallback? onClose,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    useRootNavigator: true,
    context: Get.context!,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimensions.radiusExtraLarge),
        topRight: Radius.circular(Dimensions.radiusExtraLarge),
      ),
    ),
    builder: (context) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  maxHeight ?? MediaQuery.of(context).size.height * 0.8,
            ),
            child: child,
          ),
          // زر الإغلاق X
          Positioned(
            top: -16,
            right: 16,
            child: GestureDetector(
              onTap: onClose ?? () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: const Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
