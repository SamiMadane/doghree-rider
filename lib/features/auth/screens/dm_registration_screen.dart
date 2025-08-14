import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';

import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_delivery/features/auth/widgets/dm_registration_step1.dart';
import 'package:sixam_mart_delivery/features/auth/widgets/dm_registration_step2.dart';
import 'package:sixam_mart_delivery/features/auth/widgets/step_progress_bar%20.dart';
import 'package:sixam_mart_delivery/features/navigation_handler/controllers/navigation_handler_controller.dart';
import 'package:sixam_mart_delivery/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:sixam_mart_delivery/helper/custom_validator_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';

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

  String? _countryDialCode;

  @override
  void initState() {
    super.initState();
    _countryDialCode = CountryCode.fromCountryCode(
            Get.find<NavigationHandlerController>().configModel!.country!)
        .dialCode;
    Get.find<AuthController>().resetDmRegistrationData();
    Get.find<AddressController>().resetSelectedDeliveryZone();
    Get.find<AddressController>().getZoneList();
    Get.find<AuthController>().getVehicleList();
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
          title: 'join_delivery_partner'.tr,
          elevation: 0,
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
              padding:
                  const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              child: Container(
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  StepProgressBar(status: authController.dmStatus),
                  Expanded(
                      child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
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
                            identityNumberController:
                                _identityNumberController,
                            identityNumberNode: _identityNumberNode,
                          ),
                        ]),
                  )),
                  Container(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
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
                              String password =
                                  _passwordController.text.trim();
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
                                if (fName.isEmpty) {
                                  showCustomSnackBar(
                                      'enter_delivery_man_first_name'.tr);
                                } else if (lName.isEmpty) {
                                  showCustomSnackBar(
                                      'enter_delivery_man_last_name'.tr);
                                } else if (email.isEmpty) {
                                  showCustomSnackBar(
                                      'enter_delivery_man_email_address'.tr);
                                } else if (!GetUtils.isEmail(email)) {
                                  showCustomSnackBar(
                                      'enter_a_valid_email_address'.tr);
                                } else if (phone.isEmpty) {
                                  showCustomSnackBar(
                                      'enter_delivery_man_phone_number'.tr);
                                } else if (!phoneValid.isValid) {
                                  showCustomSnackBar(
                                      'enter_a_valid_phone_number'.tr);
                                } else if (password.isEmpty) {
                                  showCustomSnackBar(
                                      'enter_password_for_delivery_man'.tr);
                                } else if (!authController.spatialCheck ||
                                    !authController.lowercaseCheck ||
                                    !authController.uppercaseCheck ||
                                    !authController.numberCheck ||
                                    !authController.lengthCheck) {
                                  showCustomSnackBar(
                                      'provide_valid_password'.tr);
                                } else if (password != confirmPass) {
                                  showCustomSnackBar(
                                      'password_does_not_matched'.tr);
                                } else if (authController.pickedImage ==
                                    null) {
                                  showCustomSnackBar(
                                      'pick_delivery_man_profile_image'.tr);
                                } else {
                                  authController.dmStatusChange(0.8);
                                }
                              } else {
                                if (authController.selectedDmTypeId == null) {
                                  showCustomSnackBar(
                                      'select_delivery_type'.tr);
                                } else if (addressController
                                        .selectedDeliveryZoneId ==
                                    null) {
                                  showCustomSnackBar(
                                      'select_delivery_zone'.tr);
                                } else if (authController.selectedVehicleId ==
                                    null) {
                                  showCustomSnackBar(
                                      'select_vehicle_type'.tr);
                                } else if (authController
                                        .selectedIdentityType ==
                                    null) {
                                  showCustomSnackBar(
                                      'select_identity_type'.tr);
                                } else if (identityNumber.isEmpty) {
                                  showCustomSnackBar(
                                      'enter_delivery_man_identity_number'
                                          .tr);
                                } else if (authController
                                    .pickedIdentities.isEmpty) {
                                  showCustomSnackBar(
                                      'please_upload_identity_image'.tr);
                                } else {
                                  authController.registerDeliveryMan(
                                      DeliveryManBodyModel(
                                    fName: fName,
                                    lName: lName,
                                    password: password,
                                    phone: numberWithCountryCode,
                                    email: email,
                                    identityNumber: identityNumber,
                                    identityType:
                                        authController.selectedIdentityType,
                                    earning: authController.selectedDmTypeId,
                                    zoneId: addressController
                                        .selectedDeliveryZoneId,
                                    vehicleId:
                                        authController.selectedVehicleId,
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
