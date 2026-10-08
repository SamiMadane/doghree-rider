import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/styles.dart';

class ConditionCheckBoxWidget extends StatelessWidget {
  final AuthController authController;
  final bool fromSignUp;
  const ConditionCheckBoxWidget({super.key, required this.authController, this.fromSignUp = false});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: fromSignUp ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

      fromSignUp ? Checkbox(
        activeColor: Theme.of(context).primaryColor,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        value: authController.acceptTerms,
        onChanged: (bool? isChecked) => authController.toggleTerms(),
      ) : const SizedBox(),

      fromSignUp ? const SizedBox() :  Text( '*', style: textRegular()),

      Flexible(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'i_agree_to_the'.tr,
              style: textRegular().copyWith(color: fromSignUp ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).hintColor),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.getTermsRoute()),
              text: 'terms_conditions'.tr,
              style: textMedium().copyWith(color: Theme.of(context).primaryColor),
            ),
          ]),
        ),
      ),

    ]);
  }
}
