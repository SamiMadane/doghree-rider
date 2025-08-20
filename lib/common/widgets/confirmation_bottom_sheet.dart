import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_outlined_button.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String? description;
  final String? icon;
  final double iconSize;
  final String acceptText;
  final Color acceptColor;
  final String cancelText;
  final VoidCallback onAccept;
  final VoidCallback? onCancel;
  final bool hasCancel;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconSize = 50,
    required this.acceptText,
    required this.acceptColor,
    required this.cancelText,
    required this.onAccept,
    this.onCancel,
    this.hasCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusExtraLarge),
              topRight: Radius.circular(Dimensions.radiusExtraLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(icon!, width: iconSize, height: iconSize),
                ),

              // العنوان
              Text(
                title,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // الوصف
              if (description != null)
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style:
                      robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // الأزرار
              Row(
                children: [
                  if (hasCancel)
                    Expanded(
                      child: CustomOutlinedButton(
                        onPressed: onCancel ?? () => Get.back(),
                        text: cancelText,
                      ),
                    ),
                  if (hasCancel)
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: onAccept,
                      backgroundColor: acceptColor,
                      buttonText: acceptText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          ),
        ),

        // زر X داخل دائرة بيضاء فوق الحدود
        Positioned(
          top: -16,
          left: 16,
          child: GestureDetector(
            onTap: () => Get.back(),
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
  }
}
