import 'package:doghree_rider/common/widgets/custom_image_widget.dart';
import 'package:doghree_rider/common/widgets/widget_with_label.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/auth/widgets/pass_view_widget.dart';
import 'package:doghree_rider/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/util/manager_assets.dart';

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
  // Field error keys live in the controller.
  static const String _kCurrent = AuthController.currentPasswordKey;
  static const String _kNew = AuthController.newPasswordKey;
  static const String _kConfirm = AuthController.confirmPasswordKey;

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
    final AuthController auth = Get.find<AuthController>();
    if (auth.showPassView) {
      auth.showHidePass();
    }
    // Drop stale errors left by other screens (login/registration).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) auth.setFieldErrors({});
    });
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordNode.dispose();
    newPasswordNode.dispose();
    confirmPasswordNode.dispose();
    super.dispose();
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
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.w16,
                    vertical: Dimensions.h16,
                  ),
                  margin: EdgeInsets.only(top: Dimensions.h16),
                  color: Theme.of(context).cardColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Current Password (only when changing password)
                        if (widget.fromPasswordChange) ...[
                          WidgetWithLabel(
                            label: 'current_password'.tr,
                            textField: CustomTextFieldWidget(
                              labelText: 'enter_password'.tr,
                              hintText: 'enter_your_current_password'.tr,
                              controller: currentPasswordController,
                              focusNode: currentPasswordNode,
                              nextFocus: newPasswordNode,
                              inputType: TextInputType.visiblePassword,
                              isPassword: true,
                              errorText: authController.fieldError(_kCurrent),
                              onChanged: (_) =>
                                  authController.clearFieldError(_kCurrent),
                            ),
                          ),
                          SizedBox(height: Dimensions.h16),
                        ],

                        // New Password
                        WidgetWithLabel(
                          label: 'new_password'.tr,
                          textField: CustomTextFieldWidget(
                            labelText: 'enter_password'.tr,
                            hintText: 'enter_your_new_password'.tr,
                            controller: newPasswordController,
                            focusNode: newPasswordNode,
                            nextFocus: confirmPasswordNode,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            errorText: authController.fieldError(_kNew),
                            onChanged: (value) {
                              authController.clearFieldError(_kNew);
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
                            alignment: AlignmentDirectional.centerStart,
                            child: PassViewWidget(),
                          ),
                        SizedBox(height: Dimensions.h16),

                        // Confirm Password
                        WidgetWithLabel(
                          label: 'confirm_password'.tr,
                          textField: CustomTextFieldWidget(
                            labelText: 'enter_password'.tr,
                            hintText: 're_enter_your_new_password'.tr,
                            controller: confirmPasswordController,
                            focusNode: confirmPasswordNode,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            errorText: authController.fieldError(_kConfirm),
                            onChanged: (_) =>
                                authController.clearFieldError(_kConfirm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Save/Reset Button
              GetBuilder<ForgotPasswordController>(
                builder: (forgotPasswordController) {
                  return SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.w16,
                        vertical: Dimensions.h16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
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
    // All validation rules live in AuthController.
    final bool valid = authController.validatePasswordForm(
      requireCurrent: widget.fromPasswordChange,
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (!valid) {
      _focusFirstError(authController);
      return;
    }

    final String currentPassword = currentPasswordController.text.trim();
    final String password = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (widget.fromPasswordChange) {
      _changeUserPassword(currentPassword, password);
    } else {
      _resetUserPassword(password, confirmPassword);
    }
  }

  void _focusFirstError(AuthController authController) {
    final Map<String, FocusNode> nodes = {
      _kCurrent: currentPasswordNode,
      _kNew: newPasswordNode,
      _kConfirm: confirmPasswordNode,
    };
    nodes[authController.firstFieldErrorKey]?.requestFocus();
  }

  void _changeUserPassword(String currentPassword, String password) {
    Get.find<ForgotPasswordController>()
        .changePassword(
      Get.find<ProfileController>().profileModel!,
      currentPassword,
      password,
    )
        .then((success) {
      if (success) {
        _showSuccessBottomSheet();
      }
      // Server errors are shown by the controller (snackbar).
    });
  }

  void _resetUserPassword(String password, String confirmPassword) {
    Get.find<ForgotPasswordController>()
        .resetPassword(
      widget.resetToken,
      '+${widget.number!.trim()}',
      password,
      confirmPassword,
    )
        .then((value) {
      if (value.isSuccess) {
        Get.find<AuthController>()
            .login('+${widget.number!.trim()}', password)
            .then((value) => Get.offAllNamed(RouteHelper.getInitialRoute()));
      } else {
        showCustomSnackBar(value.message);
      }
    });
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w20,
          vertical: Dimensions.h20,
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
            CustomImageWidget(
              image: ManagerAssets.changePasswordImage,
              height: Dimensions.h200,
              width: Dimensions.w200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: Dimensions.h20),
            Text(
              'password_changed_successfully'.tr,
              style: TextStyle(
                fontSize: Dimensions.fs18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Dimensions.h30),
            CustomButtonWidget(
              buttonText: 'go_back'.tr,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Get.back(); // Close bottom sheet
                Get.back(); // Go back to previous screen
              },
            ),
          ],
        ),
      ),
    );
  }
}