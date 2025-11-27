import 'package:wefrh_rider/common/widgets/widget_with_label.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/auth/widgets/pass_view_widget.dart';
import 'package:wefrh_rider/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';

import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPassScreen extends StatefulWidget {
  final String? resetToken;
  final String? number;
  final bool fromPasswordChange;

  const NewPassScreen({
    super.key,
    required this.resetToken,
    required this.number,
    required this.fromPasswordChange,
  });

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode currentPasswordNode = FocusNode();
  final FocusNode newPasswordNode = FocusNode();
  final FocusNode confirmPasswordNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().showPassView) {
      Get.find<AuthController>().showHidePass();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: widget.fromPasswordChange
            ? 'change_password'.tr
            : 'reset_password'.tr,
      ),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.p16),
                  margin:
                      const EdgeInsets.only(top: Dimensions.p16),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      // Current Password (لو من تغيير كلمة المرور فقط)
                      if (widget.fromPasswordChange)
                        WidgetWithLabel(
                          label: 'current_password'.tr,
                          textField: CustomTextFieldWidget(
                            labelText: 'enter_password'.tr,
                            controller: currentPasswordController,
                            focusNode: currentPasswordNode,
                            nextFocus: newPasswordNode,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                          ),
                        ),
                      if (widget.fromPasswordChange)
                        const SizedBox(height: Dimensions.p16),

                      // New Password
                      WidgetWithLabel(
                        label: 'new_password'.tr,
                        textField: CustomTextFieldWidget(
                          labelText: 'enter_password'.tr,
                          controller: newPasswordController,
                          focusNode: newPasswordNode,
                          nextFocus: confirmPasswordNode,
                          inputType: TextInputType.visiblePassword,
                          isPassword: true,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
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
                      if (authController.showPassView)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: PassViewWidget(),
                        ),
                      const SizedBox(height: Dimensions.p16),

                      // Confirm Password
                      WidgetWithLabel(
                        label: 'confirm_password'.tr,
                        textField: CustomTextFieldWidget(
                          labelText: 'enter_password'.tr,
                          controller: confirmPasswordController,
                          focusNode: confirmPasswordNode,
                          inputAction: TextInputAction.done,
                          inputType: TextInputType.visiblePassword,
                          isPassword: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // زر الحفظ / إعادة التعيين
              GetBuilder<ForgotPasswordController>(
                builder: (forgotPasswordController) {
                  return SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(
                        Dimensions.p16,

                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow:  [
                         BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: const Offset(0, -3),
                                  )
                        ],
                      ),
                      child: !forgotPasswordController.isLoading
                          ? CustomButtonWidget(
                              buttonText: 'save_changes'.tr,
                              backgroundColor: Theme.of(context).primaryColor,
                              onPressed: () => _resetPassword(authController),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _resetPassword(AuthController authController) {
    String password = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String currentPassword = currentPasswordController.text.trim();

    if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 8) {
      showCustomSnackBar('password_should_be'.tr);
    } else if (password != confirmPassword) {
      showCustomSnackBar('password_does_not_matched'.tr);
    } else if (!authController.spatialCheck ||
        !authController.lowercaseCheck ||
        !authController.uppercaseCheck ||
        !authController.numberCheck ||
        !authController.lengthCheck) {
      showCustomSnackBar('provide_valid_password'.tr);
    } else {
      if (widget.fromPasswordChange) {
        Get.find<ForgotPasswordController>().changePassword(
            Get.find<ProfileController>().profileModel!, currentPassword ,password);
      } else {
        Get.find<ForgotPasswordController>()
            .resetPassword(widget.resetToken, '+${widget.number!.trim()}',
                password, confirmPassword)
            .then((value) {
          if (value.isSuccess) {
            Get.find<AuthController>()
                .login('+${widget.number!.trim()}', password)
                .then(
                    (value) => Get.offAllNamed(RouteHelper.getInitialRoute()));
          } else {
            showCustomSnackBar(value.message);
          }
        });
      }
    }
  }
}
