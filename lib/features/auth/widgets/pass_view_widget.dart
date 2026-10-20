import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class PassViewWidget extends StatelessWidget {
  const PassViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.only(top: Dimensions.h10),
        child:
            Wrap(spacing: Dimensions.w12, runSpacing: Dimensions.h6, children: [
          _item('8_or_more_character'.tr, authController.lengthCheck),
          _item('1_number'.tr, authController.numberCheck),
          _item('1_upper_case'.tr, authController.uppercaseCheck),
          _item('1_lower_case'.tr, authController.lowercaseCheck),
          _item('1_special_character'.tr, authController.spatialCheck),
        ]),
      );
    });
  }

  Widget _item(String title, bool done) {
    final Color activeColor = Colors.green;
    final Color inactiveColor = Colors.grey.shade500;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 14,
          color: done ? activeColor : inactiveColor,
        ),
        SizedBox(width: 5),
        Text(
          title,
          style: textRegular().copyWith(
            fontSize: 12,
            color: done ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}
