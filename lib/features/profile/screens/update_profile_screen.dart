import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart'; // ✅ جديد
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/field_with_label.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _countryDialCode = '+970'; // الافتراضي

  @override
  void initState() {
    super.initState();
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }
    Get.find<ProfileController>().initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'edit_profile'.tr),
      body: GetBuilder<ProfileController>(
        builder: (profileController) {
          if (profileController.profileModel != null &&
              _fullNameController.text.isEmpty) {
            _fullNameController.text =
                '${profileController.profileModel!.fName ?? ''} ${profileController.profileModel!.lName ?? ''}';

            // ✅ هنا نفصل الكود عن الرقم
            String rawPhone = profileController.profileModel!.phone ?? '';
            if (rawPhone.isNotEmpty) {
              try {
                final parsed = PhoneNumber.parse(rawPhone);
                _countryDialCode = '+${parsed.countryCode}';
                _phoneController.text = parsed.nsn; // الرقم بدون كود الدولة
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
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        margin: const EdgeInsets.only(
                            top: Dimensions.paddingSizeDefault),
                        color: Theme.of(context).cardColor,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 62,
                                    backgroundColor: Theme.of(context)
                                        .disabledColor
                                        .withAlpha(50),
                                    backgroundImage:
                                        profileController.pickedFile != null
                                            ? (GetPlatform.isWeb
                                                ? NetworkImage(profileController
                                                    .pickedFile!.path)
                                                : FileImage(File(profileController
                                                    .pickedFile!
                                                    .path)) as ImageProvider)
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
                                    child: profileController.pickedFile == null
                                        ? Icon(Icons.person,
                                            size: 60,
                                            color: Theme.of(context).hintColor)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () =>
                                          profileController.pickProfileImage(),
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),

                              // Full Name
                              WidgetWithLabel(
                                label: 'full_name'.tr,
                                textField: CustomTextFieldWidget(
                                  controller: _fullNameController,
                                  labelText: 'full_name'.tr,
                                  hintText: 'ex_jhon_doe'.tr,
                                  inputType: TextInputType.name,
                                  capitalization: TextCapitalization.words,
                                  isRequired: true,
                                  focusNode: _fullNameFocus,
                                  nextFocus: _phoneFocus,
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
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
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),

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
                        ),
                      ),
                    ),
                    // زر التعديل
                    SafeArea(
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault,
                          bottom: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                spreadRadius: 2)
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

  void _updateProfile(ProfileController profileController) async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();

    // ✅ الرقم النهائي مع الكود
    String fullPhoneNumber = '$_countryDialCode$phoneNumber';

    // تقسيم الاسم
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    if (profileController.profileModel!.fName == firstName &&
        profileController.profileModel!.lName == lastName &&
        profileController.profileModel!.phone == fullPhoneNumber &&
        profileController.profileModel!.email == email &&
        profileController.pickedFile == null) {
      showCustomSnackBar('change_something_to_update'.tr);
    } else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    } else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    } else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    } else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      ProfileModel updatedUser = ProfileModel(
        fName: firstName,
        lName: lastName,
        email: email,
        phone: fullPhoneNumber, 
      );
      profileController
          .updateUserInfo(
              updatedUser, Get.find<AuthController>().getUserToken())
          .then((isSuccess) async {
        if (isSuccess) {
          await profileController.getProfile();
        }
      });
    }
  }
}
