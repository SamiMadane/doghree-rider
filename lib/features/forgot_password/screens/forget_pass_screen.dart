import 'package:country_code_picker/country_code_picker.dart';
import 'package:doghree_rider/common/widgets/widget_with_label.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:doghree_rider/helper/custom_validator_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
    final FocusNode _phoneFocus = FocusNode();

  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel!.country!)
      .dialCode;
  String? _countryCode = CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel!.country!)
      .code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBarWidget(
     
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          child: Column(children: [
            Image.asset(ManagerAssets.logo),
            SizedBox(
              height: Dimensions.h25,
            ),
            Text('forgot_password'.tr,
                style: textMedium().copyWith(
                    fontSize: Dimensions.fs18),
                textAlign: TextAlign.center),
            SizedBox(
              height: Dimensions.h16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text('please_enter_mobile'.tr,
                  style: textMedium().copyWith(
                      color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center),
            ),
            SizedBox(
              height: Dimensions.h25,
            ),
            WidgetWithLabel(
              label: 'mobile_number'.tr,
              textField: CustomTextFieldWidget(
                controller: _numberController,
                hintText: 'xxx-xxxx-xxxx',
                labelText: 'phone_number'.tr,
                focusNode: _phoneFocus,
                inputType: TextInputType.phone,
                isPhone: true,
                isRequired: true,
                onCountryChanged: (CountryCode countryCode) {
                  _countryDialCode = countryCode.dialCode;
                  _countryCode = countryCode.code;
                },
                countryDialCode: _countryCode ??
                    CountryCode.fromCountryCode(
                            Get.find<SplashController>()
                                .configModel!
                                .country!)
                        .code,
                inputAction: TextInputAction.done,
                onSubmit: (text) =>
                    GetPlatform.isWeb ? _forgetPass(_countryDialCode!) : null,
              ),
            ),
            SizedBox(height: Dimensions.h20),
            GetBuilder<ForgotPasswordController>(
                builder: (forgotPasswordController) {
              return !forgotPasswordController.isLoading
                  ? CustomButtonWidget(
                      buttonText: 'confirm'.tr,
                      onPressed: () => _forgetPass(_countryDialCode!),
                    )
                  : const Center(child: CircularProgressIndicator());
            }),
          ]),
        ),
      ),
    );
  }

  void _forgetPass(String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode + phone;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else {
      Get.find<ForgotPasswordController>()
          .forgetPassword(numberWithCountryCode)
          .then((status) async {
        if (status.isSuccess) {
          if (Get.find<SplashController>()
              .configModel!
              .firebaseOtpVerification!) {
            Get.find<ForgotPasswordController>()
                .firebaseVerifyPhoneNumber(numberWithCountryCode);
          } else {
            Get.toNamed(
                RouteHelper.getVerificationRoute(numberWithCountryCode));
          }
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}
