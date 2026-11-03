import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String? description;
  final String? icon;
  final double? iconSize;
  final String acceptText;
  final Color? acceptColor;
  final String cancelText;
  final VoidCallback onAccept;
  final VoidCallback? onCancel;
  final bool hasCancel;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double? topPaddingIfNoIcon;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.acceptText,
    required this.onAccept,
    this.description,
    this.icon,
    this.iconSize,
    this.acceptColor,
    this.cancelText = 'no',
    this.onCancel,
    this.hasCancel = true,
    this.titleStyle,
    this.descriptionStyle,
    this.topPaddingIfNoIcon,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimensions.w20,
        icon != null ? Dimensions.h10 : topPaddingIfNoIcon ?? Dimensions.h20,
        Dimensions.w20,
        Dimensions.h24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.h20),
              child: Image.asset(
                icon!,
                width: iconSize,
                height: iconSize ?? Dimensions.r70,
              ),
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle ??
                textBold().copyWith(
                  fontSize: Dimensions.fs18,
                  color: cs.onSurface,
                ),
          ),
          if (description != null) ...[
            SizedBox(height: Dimensions.h8),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: descriptionStyle ??
                  textRegular().copyWith(
                    fontSize: Dimensions.fs14,
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
          SizedBox(height: Dimensions.h24),
          Row(
            children: [
              if (hasCancel) ...[
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: cancelText,
                    transparent: true,
                    isBorder: true,
                    borderColor: cs.onSurface,
                    textColor: cs.onSurface,
                    onPressed: onCancel ?? Get.back,
                  ),
                ),
                SizedBox(width: Dimensions.w10),
              ],
              Expanded(
                child: CustomButtonWidget(
                  buttonText: acceptText,
                  backgroundColor: acceptColor,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}