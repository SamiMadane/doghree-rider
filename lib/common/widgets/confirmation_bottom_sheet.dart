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
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double topPaddingIfNoIcon;

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
    this.titleStyle,
    this.descriptionStyle,
    this.topPaddingIfNoIcon = Dimensions.p50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeLarge,
        icon != null ? Dimensions.paddingSizeLarge : topPaddingIfNoIcon,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
      ),
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
            style: titleStyle ??
                robotoSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // الوصف
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: descriptionStyle ??
                  robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).disabledColor),
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
              if (hasCancel) const SizedBox(width: Dimensions.paddingSizeSmall),
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
    );
  }
}
