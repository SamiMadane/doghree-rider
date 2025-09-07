import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/field_with_label.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';

class DmRegistrationStep1 extends StatelessWidget {
  final TextEditingController fNameController;
  final TextEditingController lNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final FocusNode fNameNode;
  final FocusNode lNameNode;
  final FocusNode emailNode;
  final FocusNode phoneNode;
  final FocusNode passwordNode;
  final FocusNode confirmPasswordNode;

  final String? countryDialCode;
  final Function(CountryCode)? onCountryChanged;

  const DmRegistrationStep1({
    super.key,
    required this.fNameController,
    required this.lNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.fNameNode,
    required this.lNameNode,
    required this.emailNode,
    required this.phoneNode,
    required this.passwordNode,
    required this.confirmPasswordNode,
    this.countryDialCode,
    this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Visibility(
      visible: authController.dmStatus == 0.4,
      child: Column(children: [
        SizedBox(
          height: Dimensions.p10,
        ),
        Stack(
          children: [
            CircleAvatar(
              radius: 62,
              backgroundColor: Theme.of(context).disabledColor.withAlpha(50),
              backgroundImage: authController.pickedImage != null
                  ? (GetPlatform.isWeb
                      ? NetworkImage(authController.pickedImage!.path)
                      : FileImage(File(authController.pickedImage!.path))
                          as ImageProvider)
                  : null,
              child: authController.pickedImage == null
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).hintColor,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () =>
                    authController.pickDmImageForRegistration(true, false),
                child: Material(
                  elevation: 4,
                  shape: const CircleBorder(),
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                          child: SvgPicture.asset(
                        ManagerAssets.editIcon,
                        color: ManagerColors.orangeLightMode,
                      )),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.p25),
        WidgetWithLabel(
          label: 'first_name'.tr,
          textField: CustomTextFieldWidget(
            controller: fNameController,
            labelText: 'first_name'.tr,
            hintText: 'ex_jhon'.tr,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            isRequired: true,
            focusNode: fNameNode,
            nextFocus: lNameNode,
          ),
        ),
        const SizedBox(height: Dimensions.p16),
        WidgetWithLabel(
          label: 'last_name'.tr,
          textField: CustomTextFieldWidget(
            controller: lNameController,
            labelText: 'last_name'.tr,

            hintText: 'ex_doe'.tr,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            isRequired: true,
            focusNode: lNameNode,
            nextFocus: phoneNode,
          ),
        ),
        const SizedBox(height: Dimensions.p16),
        WidgetWithLabel(
          label: 'mobile_number'.tr,
          textField: CustomTextFieldWidget(
            labelText: 'phone_number'.tr,

            hintText: 'xxx-xxx-xxxxx'.tr,
            isRequired: true,
            controller: phoneController,
            focusNode: phoneNode,
            nextFocus: emailNode,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode: countryDialCode,
          ),
        ),
        const SizedBox(height: Dimensions.p16),
        WidgetWithLabel(
          label: 'email'.tr,
          textField: CustomTextFieldWidget(
            labelText: 'email'.tr,

            controller: emailController,
            hintText: 'enter_email'.tr,
            inputType: TextInputType.emailAddress,
            isRequired: true,
            focusNode: emailNode,
            nextFocus: passwordNode,
          ),
        ),
        const SizedBox(height: Dimensions.p16),
        WidgetWithLabel(
          label: 'password'.tr,
          textField: CustomTextFieldWidget(
            hintText: 'eight_characters'.tr,
            labelText: 'password'.tr,

            isRequired: true,
            controller: passwordController,
            focusNode: passwordNode,
            nextFocus: confirmPasswordNode,
            inputType: TextInputType.visiblePassword,
            isPassword: true,
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                if (!authController.showPassView) {
                  authController.showHidePass();
                }
                authController.validPassCheck(value);
              } else {
                if (authController.showPassView) {
                  authController.showHidePass();
                }
              }
            },
          ),
        ),
        const SizedBox(height: Dimensions.p16),
        WidgetWithLabel(
          label: 'confirm_password'.tr,
          textField: CustomTextFieldWidget(
            controller: confirmPasswordController,
            labelText: 'confirm_password'.tr,

            hintText: 're_enter_your_password'.tr,
            inputType: TextInputType.visiblePassword,
            isRequired: true,
            isPassword: true,
            focusNode: confirmPasswordNode,
            inputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: Dimensions.p25),
      ]),
    );
  }
}
