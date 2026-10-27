import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_text_field_widget.dart';
import 'package:doghree_rider/common/widgets/widget_with_label.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/auth/widgets/pass_view_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

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
          height: Dimensions.h10,
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
                onTap: () {
                  authController.clearFieldError('image');
                  authController.pickDmImageWithCrop(context);
                },
                child: Material(
                  elevation: 4,
                  shape: const CircleBorder(),
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                          child: SvgPicture.asset(
                        ManagerAssets.editIcon,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      )),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (authController.fieldError('image') != null) ...[
          SizedBox(height: Dimensions.h8),
          Text(
            authController.fieldError('image')!,
            textAlign: TextAlign.center,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs12,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: Dimensions.h25),
        WidgetWithLabel(
          label: 'first_name'.tr,
          textField: CustomTextFieldWidget(
            controller: fNameController,
            labelText: 'first_name'.tr,
            hintText: 'enter_your_first_name'.tr,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            isRequired: true,
            focusNode: fNameNode,
            nextFocus: lNameNode,
            errorText: authController.fieldError('f_name'),
            onChanged: (_) => authController.clearFieldError('f_name'),
          ),
        ),
        SizedBox(height: Dimensions.h16),
        WidgetWithLabel(
          label: 'last_name'.tr,
          textField: CustomTextFieldWidget(
            controller: lNameController,
            labelText: 'last_name'.tr,
            hintText: 'enter_your_last_name'.tr,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            isRequired: true,
            focusNode: lNameNode,
            nextFocus: phoneNode,
            errorText: authController.fieldError('l_name'),
            onChanged: (_) => authController.clearFieldError('l_name'),
          ),
        ),
        SizedBox(height: Dimensions.h16),
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
            errorText: authController.fieldError('phone'),
            onChanged: (_) => authController.clearFieldError('phone'),
          ),
        ),
        SizedBox(height: Dimensions.h16),
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
            errorText: authController.fieldError('email'),
            onChanged: (_) => authController.clearFieldError('email'),
          ),
        ),
        SizedBox(height: Dimensions.h16),
        Column(
          children: [
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
                errorText: authController.fieldError('password'),
                onChanged: (value) {
                  authController.clearFieldError('password');
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
            authController.showPassView ? const PassViewWidget() : SizedBox(),
          ],
        ),
        SizedBox(height: Dimensions.h16),
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
            errorText: authController.fieldError('confirm_password'),
            onChanged: (_) =>
                authController.clearFieldError('confirm_password'),
          ),
        ),
        SizedBox(height: Dimensions.h25),
      ]),
    );
  }
}
