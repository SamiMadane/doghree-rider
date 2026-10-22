import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

/// Dialog احترافي لانتهاء الجلسة
class SessionExpiredBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const SessionExpiredBottomSheet({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w20, vertical: Dimensions.h20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            ManagerAssets.sessionExpiredImage,
          ),

          const SizedBox(height: 20),

          // العنوان
          Text(
            'weve_logged_you_out'.tr,
            style: textBold().copyWith(
              fontSize: 22,
              color: Theme.of(context).textTheme.bodyMedium?.color
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // الوصف
          Text(
            'new_device_logged_in'.tr,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs15,
              color: Theme.of(context).hintColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Dimensions.h25),

          // زر مخصص
          CustomButtonWidget(
            onPressed: onConfirm,
            buttonText: 'ok'.tr,
          )
        ],
      ),
    );
  }
}
