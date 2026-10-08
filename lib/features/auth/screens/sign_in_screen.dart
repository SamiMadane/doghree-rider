import 'package:country_code_picker/country_code_picker.dart';
import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/common/widgets/session_expired_bottom_sheet.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/common/widgets/widget_with_label.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/features/splash/controllers/splash_controller.dart';
import 'package:wefrh_rider/helper/custom_validator_helper.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _countryDialCode;
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    _checkLogoutReason();
    _countryDialCode =
        Get.find<AuthController>().getUserCountryDialCode().isNotEmpty
            ? Get.find<AuthController>().getUserCountryDialCode()
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>().configModel!.country!)
                .dialCode;
    _countryCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty
        ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(
                Get.find<SplashController>().configModel!.country!)
            .code;
    _phoneController.text = Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  void _checkLogoutReason() async {
    String? reason = await Get.find<AuthController>().getLogoutReason();

    if (reason == 'session_expired') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomBottomSheet(
          child: SessionExpiredBottomSheet(
            onConfirm: () {
              Get.back();
              Get.offAllNamed(RouteHelper.getSignInRoute());
            },
          ),
          isDismissible: false,
          showCloseButton: false, 
        );
      });

      await Get.find<AuthController>().clearLogoutReason();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          child: GetBuilder<AuthController>(builder: (authController) {
            return Column(children: [
              Image.asset(
                ManagerAssets.logo,
              ),
              SizedBox(
                height: Dimensions.h20,
              ),
              Text('sign_in_account'.tr,
                  style: textBold().copyWith(fontSize: Dimensions.fs18)),
              SizedBox(
                height: Dimensions.h4,
              ),
              Text('enter_details_continue'.tr,
                  style: textRegular().copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fs14)),
              SizedBox(height: Dimensions.h25),
              WidgetWithLabel(
                label: 'mobile_number'.tr,
                textField: CustomTextFieldWidget(
                  hintText: 'xxx-xxxx-xxxx',
                  labelText: 'phone_number'.tr,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocus: _passwordFocus,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  isRequired: true,
                  onCountryChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                    _countryCode = countryCode.code;
                  },
                  countryDialCode: _countryCode ??
                      CountryCode.fromCountryCode(Get.find<SplashController>()
                              .configModel!
                              .country!)
                          .code,
                ),
              ),
              SizedBox(height: Dimensions.h25),
              WidgetWithLabel(
                label: 'password'.tr,
                textField: CustomTextFieldWidget(
                  hintText: '********',
                  labelText: 'password'.tr,
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.visiblePassword,
                  isPassword: true,
                  isRequired: true,
                  onSubmit: (text) => GetPlatform.isWeb
                      ? _login(
                          authController,
                          _phoneController,
                          _passwordController,
                          _countryDialCode!,
                          _countryCode!,
                          context,
                        )
                      : null,
                ),
              ),
              Row(children: [
                Expanded(
                  child: ListTile(
                    onTap: () => authController.toggleRememberMe(),
                    leading: Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.isActiveRememberMe,
                      onChanged: (bool? isChecked) =>
                          authController.toggleRememberMe(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            Dimensions.r4), // غير الرقم لتكبير أو تصغير الزوايا
                      ),
                    ),
                    title: Text('remember_me'.tr,
                        style: textMedium().copyWith(
                          color: Theme.of(context).disabledColor,
                        )),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    horizontalTitleGap: -4,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Get.toNamed(RouteHelper.getForgotPassRoute()),
                  child: Text(
                    '${'forgot_password'.tr}',
                    style: textMedium().copyWith(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ]),
              SizedBox(height: Dimensions.h16),
              CustomButtonWidget(
                buttonText: 'sign_in'.tr,
                isLoading: authController.isLoading,
                onPressed: () => _login(
                    authController,
                    _phoneController,
                    _passwordController,
                    _countryDialCode!,
                    _countryCode!,
                    context),
              ),
              SizedBox(
                  height: Get.find<SplashController>()
                          .configModel!
                          .toggleDmRegistration!
                      ? Dimensions.h25
                      : 0),
              Get.find<SplashController>().configModel!.toggleDmRegistration!
                  ? TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(1, 40),
                      ),
                      onPressed: () {
                        Get.toNamed(
                            RouteHelper.getDeliverymanRegistrationRoute());
                      },
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: '${'join_as_a'.tr} ',
                            style: textMedium().copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fs16)),
                        TextSpan(
                            text: 'delivery_man'.tr,
                            style: textMedium().copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fs16)),
                      ])),
                    )
                  : const SizedBox(),
            ]);
          }),
        ),
      )),
    );
  }

  void _login(
      AuthController authController,
      TextEditingController phoneText,
      TextEditingController passText,
      String countryDialCode,
      String countryCode,
      BuildContext context) async {
    String phone = phoneText.text.trim();
    String password = passText.text.trim();

    String numberWithCountryCode = countryDialCode + phone;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else {
      authController
          .login(numberWithCountryCode, password)
          .then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(
                phone, password, countryDialCode, countryCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          await Get.find<ProfileController>().getProfile();
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}
