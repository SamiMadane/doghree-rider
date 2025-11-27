import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';

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
      padding: const EdgeInsets.all(Dimensions.p20),
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
            style: robotoBold.copyWith(
              fontSize: 22,
              color: ManagerColors.error,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // الوصف
          Text(
            'new_device_logged_in'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fs15,
              color: Theme.of(context).disabledColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Dimensions.p25),

          // زر مخصص
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'ok'.tr,
          style: robotoBold.copyWith(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
