import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/common/widgets/custom_text_field_widget.dart';
import 'package:doghree_rider/common/widgets/widget_with_label.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  // Field error keys live in the controller.
  static const String _kName = AuthController.profileNameKey;
  static const String _kEmail = AuthController.profileEmailKey;
  static const String _kPhone = AuthController.profilePhoneKey;

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _countryDialCode = '+970';

  @override
  void initState() {
    super.initState();
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }
    Get.find<ProfileController>().initData();

    // Drop stale errors left by other screens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Get.find<AuthController>().setFieldErrors({});
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'edit_profile'.tr),
      body: GetBuilder<ProfileController>(
        builder: (profileController) {
          if (profileController.profileModel != null &&
              _fullNameController.text.isEmpty) {
            _fullNameController.text =
                '${profileController.profileModel!.fName ?? ''} ${profileController.profileModel!.lName ?? ''}';

            String rawPhone = profileController.profileModel!.phone ?? '';
            if (rawPhone.isNotEmpty) {
              try {
                final parsed = PhoneNumber.parse(rawPhone);
                _countryDialCode = '+${parsed.countryCode}';
                _phoneController.text = parsed.nsn;
              } catch (e) {
                _phoneController.text = rawPhone;
              }
            }

            _emailController.text = profileController.profileModel!.email ?? '';
          }

          return profileController.profileModel != null
              ? Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.w16,
                          vertical: Dimensions.h16,
                        ),
                        margin: EdgeInsets.only(top: Dimensions.h16),
                        color: Theme.of(context).cardColor,
                        // Nested builder: field errors rebuild only this subtree,
                        // so the controllers above are never re-filled.
                        child: GetBuilder<AuthController>(
                          builder: (authController) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: Dimensions.h10),
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: Dimensions.r62,
                                        backgroundColor: scheme.outline,
                                        backgroundImage: profileController
                                                    .pickedFile !=
                                                null
                                            ? (GetPlatform.isWeb
                                                ? NetworkImage(profileController
                                                    .pickedFile!.path)
                                                : FileImage(File(
                                                        profileController
                                                            .pickedFile!
                                                            .path))
                                                    as ImageProvider)
                                            : (profileController.profileModel!
                                                            .imageFullUrl !=
                                                        null &&
                                                    profileController
                                                        .profileModel!
                                                        .imageFullUrl!
                                                        .isNotEmpty
                                                ? NetworkImage(profileController
                                                    .profileModel!
                                                    .imageFullUrl!)
                                                : null),
                                        child: (profileController.pickedFile ==
                                                    null &&
                                                (profileController
                                                            .profileModel
                                                            ?.imageFullUrl ==
                                                        null ||
                                                    profileController
                                                        .profileModel!
                                                        .imageFullUrl!
                                                        .isEmpty))
                                            ? Icon(
                                                Icons.person,
                                                size: Dimensions.w60,
                                                color: scheme.onSurfaceVariant,
                                              )
                                            : null,
                                      ),
                                      PositionedDirectional(
                                        bottom: 0,
                                        end: 0,
                                        child: InkWell(
                                          onTap: () => profileController
                                              .pickProfileImageWithCrop(
                                                  context),
                                          child: Material(
                                            elevation: 4,
                                            shape: const CircleBorder(),
                                            color: Theme.of(context).cardColor,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.all(Dimensions.w4),
                                              child: SizedBox(
                                                height: Dimensions.w32,
                                                width: Dimensions.w32,
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    ManagerAssets.editIcon,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      scheme.primary,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: Dimensions.h25),

                                  // Full Name
                                  WidgetWithLabel(
                                    label: 'full_name'.tr,
                                    textField: CustomTextFieldWidget(
                                      controller: _fullNameController,
                                      labelText: 'full_name'.tr,
                                      hintText: 'full_name'.tr,
                                      inputType: TextInputType.name,
                                      capitalization: TextCapitalization.words,
                                      isRequired: true,
                                      focusNode: _fullNameFocus,
                                      nextFocus: _emailFocus,
                                      errorText:
                                          authController.fieldError(_kName),
                                      onChanged: (_) => authController
                                          .clearFieldError(_kName),
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.h16),

                                  // Email
                                  WidgetWithLabel(
                                    label: 'email'.tr,
                                    textField: CustomTextFieldWidget(
                                      controller: _emailController,
                                      labelText: 'email'.tr,
                                      hintText: 'enter_email'.tr,
                                      inputType: TextInputType.emailAddress,
                                      isRequired: true,
                                      focusNode: _emailFocus,
                                      nextFocus: _phoneFocus,
                                      errorText:
                                          authController.fieldError(_kEmail),
                                      onChanged: (_) => authController
                                          .clearFieldError(_kEmail),
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.h16),

                                  // Phone
                                  WidgetWithLabel(
                                    label: 'mobile_number'.tr,
                                    textField: CustomTextFieldWidget(
                                      labelText: 'phone_number'.tr,
                                      hintText: 'xxx-xxx-xxxxx'.tr,
                                      isRequired: true,
                                      controller: _phoneController,
                                      focusNode: _phoneFocus,
                                      inputType: TextInputType.phone,
                                      isPhone: true,
                                      errorText:
                                          authController.fieldError(_kPhone),
                                      onChanged: (_) => authController
                                          .clearFieldError(_kPhone),
                                      onCountryChanged: (code) {
                                        setState(() {
                                          _countryDialCode = code.dialCode!;
                                        });
                                      },
                                      countryDialCode: _countryDialCode,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Save button
                    SafeArea(
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
                        child: !profileController.isLoading
                            ? CustomButtonWidget(
                                onPressed: () =>
                                    _updateProfile(profileController),
                                buttonText: 'save_changes'.tr,
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _updateProfile(ProfileController profileController) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileModel current = profileController.profileModel!;

    final List<String> names =
        AuthController.splitFullName(_fullNameController.text);
    final String email = _emailController.text.trim();
    final String fullPhoneNumber =
        '$_countryDialCode${_phoneController.text.trim()}';

    // General message (not tied to a field): nothing was changed.
    if (current.fName == names[0] &&
        current.lName == names[1] &&
        current.phone == fullPhoneNumber &&
        current.email == email &&
        profileController.pickedFile == null) {
      authController.setFieldErrors({});
      showCustomSnackBar('change_something_to_update'.tr);
      return;
    }

    // Field rules live in AuthController.
    final bool valid = authController.validateProfileForm(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );
    if (!valid) {
      _focusFirstError(authController);
      return;
    }

    final ProfileModel updatedUser = ProfileModel(
      fName: names[0],
      lName: names[1],
      email: email,
      phone: fullPhoneNumber,
    );

    // Server errors are shown by ProfileController (snackbar).
    profileController
        .updateUserInfo(updatedUser, authController.getUserToken())
        .then((isSuccess) async {
      if (isSuccess) {
        await profileController.getProfile();
      }
    });
  }

  void _focusFirstError(AuthController authController) {
    final Map<String, FocusNode> nodes = {
      _kName: _fullNameFocus,
      _kEmail: _emailFocus,
      _kPhone: _phoneFocus,
    };
    nodes[authController.firstFieldErrorKey]?.requestFocus();
  }
}