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
    this.description,
    this.icon,
    this.iconSize,
    required this.acceptText,
    this.acceptColor,
    this.cancelText = 'no', // يمكن تعيين قيمة افتراضية
    required this.onAccept,
    this.onCancel,
    this.hasCancel = true,
    this.titleStyle,
    this.descriptionStyle,
    this.topPaddingIfNoIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.w16,
        icon != null ? Dimensions.h10 : topPaddingIfNoIcon ?? Dimensions.h30,
        Dimensions.w16,
        Dimensions.h20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.r20),
          topRight: Radius.circular(Dimensions.r20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: Dimensions.h20, horizontal: Dimensions.w20),
              child: Image.asset(icon!, width: iconSize, height: iconSize ?? Dimensions.r70),
            ),

          // العنوان
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.66,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle ??
                  textSemiBold().copyWith(
                    fontSize: Dimensions.fs17,
                  ),
            ),
          ),
          SizedBox(height: Dimensions.h10),

          // الوصف
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: descriptionStyle ??
                  textRegular().copyWith(
                      fontSize: Dimensions.fs15,
                      color: Theme.of(context).disabledColor),
            ),
          SizedBox(height: Dimensions.h25),

          // الأزرار
          Row(
            children: [
              if (hasCancel)
                Expanded(
                  child: CustomButtonWidget(
                    onPressed: onCancel ?? () => Get.back(),
                    buttonText: cancelText,
                    isBorder: true,
                    autoWidth: true,
                    transparent: true,
                    fontColor: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              if (hasCancel) SizedBox(width: Dimensions.w10),
              Expanded(
                child: CustomButtonWidget(
                  onPressed: onAccept,
                  autoWidth: true,
                  backgroundColor:
                      acceptColor ?? Theme.of(context).primaryColor,
                  buttonText: acceptText,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.h20),
        ],
      ),
    );
  }
}
