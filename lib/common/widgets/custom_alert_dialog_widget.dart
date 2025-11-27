import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlertDialogWidget extends StatelessWidget {
  final String description;
  final Function onOkPressed;
  const CustomAlertDialogWidget({super.key, required this.description, required this.onOkPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.r4)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.p20, vertical: Dimensions.p10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Icon(Icons.info, size: 80, color: Theme.of(context).primaryColor),

          Padding(
            padding: const EdgeInsets.all(Dimensions.p20),
            child: Text(
              description, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fs16),
            ),
          ),

          CustomButtonWidget(
            buttonText: 'ok'.tr,
            onPressed: onOkPressed,
            height: 40,
          ),

        ]),
      ),
    );
  }
}
