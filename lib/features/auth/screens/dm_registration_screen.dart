import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';

import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/address/controllers/address_controller.dart';
import 'package:wefrh_rider/features/auth/widgets/dm_registration_step1.dart';
import 'package:wefrh_rider/features/auth/widgets/dm_registration_step2.dart';
import 'package:wefrh_rider/common/widgets/step_progress_bar%20.dart';
import 'package:wefrh_rider/features/splash/controllers/splash_controller.dart';
import 'package:wefrh_rider/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:wefrh_rider/helper/custom_validator_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/helper/validate_check.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';

class DmRegistrationScreen extends StatefulWidget {
  const DmRegistrationScreen({super.key});

  @override
  State<DmRegistrationScreen> createState() => _DmRegistrationScreenState();
}

class _DmRegistrationScreenState extends State<DmRegistrationScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();

  final FocusNode _fNameNode = FocusNode();
  final FocusNode _lNameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();
  final FocusNode _identityNumberNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  String? _countryDialCode;

  @override
  void initState() {
    super.initState();
    _countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel!.country!)
        .dialCode;
    Get.find<AuthController>().resetDmRegistrationData();
    Get.find<AddressController>().resetSelectedDeliveryZone();
    Get.find<AddressController>().getZoneList();
    Get.find<AuthController>().getVehicleList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// تحقق الخطوة الأولى: يرجّع (اسم الحقل ← رسالة الخطأ).
  /// الخريطة الفاضية = كل شي سليم.
  Map<String, String> _validateStep1(
    AuthController auth, {
    required String fName,
    required String lName,
    required String phone,
    required bool phoneIsValid,
    required String email,
    required String password,
    required String confirmPass,
  }) {
    final Map<String, String> errors = {};

    if (auth.pickedImage == null) {
      errors['image'] = 'pick_delivery_man_profile_image'.tr;
    }

    final String? fNameError = ValidateCheck.validateEmptyText(
        fName, 'enter_delivery_man_first_name');
    if (fNameError != null) errors['f_name'] = fNameError;

    final String? lNameError = ValidateCheck.validateEmptyText(
        lName, 'enter_delivery_man_last_name');
    if (lNameError != null) errors['l_name'] = lNameError;

    final String? phoneError = ValidateCheck.validatePhone(
        phone, 'enter_delivery_man_phone_number');
    if (phoneError != null) {
      errors['phone'] = phoneError;
    } else if (!phoneIsValid) {
      errors['phone'] = 'enter_a_valid_phone_number'.tr;
    }

    // دالة التحقق من الإيميل تقبل أحرف صغيرة فقط، فنفحص النسخة الصغيرة
    final String? emailError = ValidateCheck.validateEmail(email.toLowerCase());
    if (emailError != null) {
      errors['email'] = emailError;
    } else if (email.length > 100) {
      errors['email'] = 'enter_a_valid_email_address'.tr;
    }

    final String? passError = ValidateCheck.validatePassword(
        password, 'enter_password_for_delivery_man');
    if (passError != null) {
      errors['password'] = passError;
    } else if (!auth.spatialCheck ||
        !auth.lowercaseCheck ||
        !auth.uppercaseCheck ||
        !auth.numberCheck ||
        !auth.lengthCheck) {
      errors['password'] = 'provide_valid_password'.tr;
    }

    final String? confirmError =
        ValidateCheck.validateConfirmPassword(confirmPass, password);
    if (confirmError != null) errors['confirm_password'] = confirmError;

    return errors;
  }

  /// يركّز على أول حقل فيه خطأ (والصفحة بتسحب له لحالها)
  void _focusFirstError(Map<String, String> errors) {
    if (errors.containsKey('image')) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      return;
    }
    final Map<String, FocusNode> order = {
      'f_name': _fNameNode,
      'l_name': _lNameNode,
      'phone': _phoneNode,
      'email': _emailNode,
      'password': _passwordNode,
      'confirm_password': _confirmPasswordNode,
    };
    for (final e in order.entries) {
      if (errors.containsKey(e.key)) {
        e.value.requestFocus();
        return;
      }
    }
  }

  /// تحقق الخطوة الثانية: يرجّع (اسم الحقل ← رسالة الخطأ).
  Map<String, String> _validateStep2(
    AuthController auth,
    AddressController address,
    String identityNumber,
  ) {
    final Map<String, String> errors = {};

    if (auth.selectedDmTypeId == null) {
      errors['delivery_type'] = 'select_delivery_type'.tr;
    }
    if (address.selectedDeliveryZoneId == null) {
      errors['zone_id'] = 'select_delivery_zone'.tr;
    }
    if (auth.selectedVehicleId == null) {
      errors['vehicle_id'] = 'select_vehicle_type'.tr;
    }
    if (auth.selectedIdentityType == null) {
      errors['identity_type'] = 'select_identity_type'.tr;
    }
    if (identityNumber.isEmpty) {
      errors['identity_number'] = 'enter_delivery_man_identity_number'.tr;
    }
    if (auth.pickedIdentities.isEmpty) {
      errors['identity_image'] = 'please_upload_identity_image'.tr;
    }
    return errors;
  }

  /// يوصّل المستخدم لأول خطأ بالخطوة الثانية
  void _focusFirstErrorStep2(Map<String, String> errors) {
    final bool topError = errors.containsKey('delivery_type') ||
        errors.containsKey('zone_id') ||
        errors.containsKey('vehicle_id') ||
        errors.containsKey('identity_type');
    if (topError) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else if (errors.containsKey('identity_number')) {
      _identityNumberNode.requestFocus();
    } else if (errors.containsKey('identity_image')) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (Get.find<AuthController>().dmStatus != 0.4 && !didPop) {
          Get.find<AuthController>().dmStatusChange(0.4);
        } else {
          Future.delayed(const Duration(milliseconds: 0), () {
            Get.offAllNamed(RouteHelper.getSignInRoute());
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBarWidget(
          title: 'join_as_a_delivery_man'.tr,
          onBackPressed: () async {
            if (Get.find<AuthController>().dmStatus != 0.4) {
              Get.find<AuthController>().dmStatusChange(0.4);
            } else {
              Get.back();
            }
          },
        ),
        body: GetBuilder<AuthController>(builder: (authController) {
          return GetBuilder<AddressController>(builder: (addressController) {
            return Padding(
              padding: EdgeInsets.only(top: Dimensions.h16),
              child: Container(
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  StepProgressBar(status: authController.dmStatus),
                  Expanded(
                      child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.w16,
                      vertical: Dimensions.h16,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DmRegistrationStep1(
                            fNameController: _fNameController,
                            lNameController: _lNameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            fNameNode: _fNameNode,
                            lNameNode: _lNameNode,
                            emailNode: _emailNode,
                            phoneNode: _phoneNode,
                            passwordNode: _passwordNode,
                            confirmPasswordNode: _confirmPasswordNode,
                            countryDialCode: _countryDialCode,
                            onCountryChanged: (code) {
                              setState(() {
                                _countryDialCode = code.dialCode;
                              });
                            },
                          ),
                          DmRegistrationStep2(
                            identityNumberController: _identityNumberController,
                            identityNumberNode: _identityNumberNode,
                          ),
                        ]),
                  )),
                  Container(
                    padding: EdgeInsets.only(
                        top: Dimensions.h16,
                        left: Dimensions.w16,
                        right: Dimensions.w16,
                        bottom: Dimensions.h4),
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
                    child: CustomButtonWidget(
                      buttonText: authController.dmStatus == 0.4
                          ? 'next'.tr
                          : 'submit'.tr,
                      isLoading: authController.isLoading,
                      onPressed: !authController.acceptTerms
                          ? null
                          : () async {
                              String fName = _fNameController.text.trim();
                              String lName = _lNameController.text.trim();
                              String email = _emailController.text.trim();
                              String phone = _phoneController.text.trim();
                              String password = _passwordController.text.trim();
                              String confirmPass =
                                  _confirmPasswordController.text.trim();
                              String identityNumber =
                                  _identityNumberController.text.trim();

                              String numberWithCountryCode =
                                  _countryDialCode! + phone;
                              PhoneValid phoneValid =
                                  await CustomValidator.isPhoneValid(
                                      numberWithCountryCode);
                              numberWithCountryCode = phoneValid.phone;

                              if (authController.dmStatus == 0.4) {
                                // ===== الخطوة الأولى: أخطاء تحت الحقول =====
                                final Map<String, String> errors =
                                    _validateStep1(
                                  authController,
                                  fName: fName,
                                  lName: lName,
                                  phone: phone,
                                  phoneIsValid: phoneValid.isValid,
                                  email: email,
                                  password: password,
                                  confirmPass: confirmPass,
                                );
                                authController.setFieldErrors(errors);
                                if (errors.isEmpty) {
                                  authController.dmStatusChange(0.8);
                                } else {
                                  _focusFirstError(errors);
                                }
                              } else {
                                // ===== الخطوة الثانية: أخطاء تحت الحقول =====
                                final Map<String, String> errors2 =
                                    _validateStep2(authController,
                                        addressController, identityNumber);
                                authController.setFieldErrors(errors2);
                                if (errors2.isNotEmpty) {
                                  _focusFirstErrorStep2(errors2);
                                } else {
                                  authController
                                      .registerDeliveryMan(DeliveryManBodyModel(
                                    fName: fName,
                                    lName: lName,
                                    password: password,
                                    phone: numberWithCountryCode,
                                    email: email.toLowerCase(),
                                    identityNumber: identityNumber,
                                    identityType:
                                        authController.selectedIdentityType,
                                    earning: authController.selectedDmTypeId,
                                    zoneId: addressController
                                        .selectedDeliveryZoneId,
                                    vehicleId: authController.selectedVehicleId,
                                  ));
                                }
                              }
                            },
                    ),
                  ),
                ]),
              ),
            );
          });
        }),
      ),
    );
  }
}