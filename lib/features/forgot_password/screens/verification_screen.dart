import 'dart:async';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  final String? firebaseSession;
  const VerificationScreen(
      {super.key, required this.number, this.firebaseSession});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  Timer? _timer;
  int _seconds = 0;
  bool _blocked = false; // 405/429: temporary lock

  @override
  void initState() {
    super.initState();

    _number = widget.number!.startsWith('+')
        ? widget.number
        : '+${widget.number!.substring(1, widget.number!.length)}';
    _startTimer();
  }

  void _startTimer([int seconds = 60, bool blocked = false]) {
    _timer?.cancel();
    _seconds = seconds;
    _blocked = blocked;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _seconds = 0;
          _blocked = false;
          timer.cancel();
        }
      });
    });
    if (mounted) setState(() {});
  }

  /// 405 = 600 s lock per the guide (blocked_temp_otp); 429 = rate limit (60 s).
  void _handleRateLimit(ResponseModel response) {
    if (response.isRateLimited) {
      _startTimer(response.statusCode == 405 ? 600 : 60, true);
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _resend(ForgotPasswordController controller) async {
    if (widget.firebaseSession != null) {
      // Firebase OTP
      await controller.firebaseVerifyPhoneNumber(_number!, canRoute: false);
      if (!mounted) return;
      _startTimer();
    } else {
      controller.forgetPassword(widget.number).then((value) {
        if (value.isSuccess) {
          _startTimer();
          showCustomSnackBar('resend_code_successful'.tr, isError: false);
        } else {
          _handleRateLimit(value);
          showCustomSnackBar(value.message);
        }
      });
    }
  }

  void _verify(ForgotPasswordController controller) {
    if (widget.firebaseSession != null) {
      controller
          .verifyFirebaseOtp(
        phoneNumber: _number!,
        session: widget.firebaseSession!,
        otp: controller.verificationCode,
      )
          .then((value) {
        if (value.isSuccess) {
          Get.toNamed(RouteHelper.getResetPasswordRoute(
              _number, controller.verificationCode, 'reset-password'));
        }
      });
    } else {
      controller.verifyToken(_number).then((value) {
        if (value.isSuccess) {
          Get.toNamed(RouteHelper.getResetPasswordRoute(
              _number, controller.verificationCode, 'reset-password'));
        } else {
          _handleRateLimit(value);
          showCustomSnackBar(value.message);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    // Focused box: asphalt on light, yellow on dark (never yellow on white).
    final Color accent = isDark ? cs.primary : cs.onSurface;

    // Boxes shrink on small screens so six of them always fit in one row.
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double available =
        (screenWidth > 500 ? 500 : screenWidth) - Dimensions.w16 * 2;
    final double fieldWidth =
        ((available / 6) - 8).clamp(38.0, 52.0).toDouble();

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'otp_verification'.tr),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.only(top: Dimensions.h16),
          child: Container(
            color: theme.cardColor,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.w16,
                  vertical: Dimensions.h16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: GetBuilder<ForgotPasswordController>(
                    builder: (forgotPasswordController) {
                      final bool canVerify =
                          forgotPasswordController.verificationCode.length == 6 &&
                              !_blocked;
          
                      return Column(
                        children: [
                          // Instruction text
                          Get.find<SplashController>().configModel!.demo!
                              ? Text(
                                  'for_demo_purpose'.tr,
                                  style: textRegular(),
                                  textAlign: TextAlign.center,
                                )
                              : Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                      text: 'enter_the_verification_sent_to'.tr,
                                      style: textRegular().copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontSize: Dimensions.fs16,
                                      ),
                                    ),
                                    // LRM marks keep "+970..." intact inside RTL text.
                                    TextSpan(
                                      text: ' \u200E$_number\u200E',
                                      style: textBold().copyWith(
                                        color: cs.onSurface,
                                        fontSize: Dimensions.fs16,
                                      ),
                                    ),
                                  ]),
                                  textAlign: TextAlign.center,
                                ),
          
                          SizedBox(height: Dimensions.h25),
          
                          // PIN boxes
                          PinCodeTextField(
                            length: 6,
                            appContext: context,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            animationDuration: const Duration(milliseconds: 200),
                            backgroundColor: Colors.transparent,
                            enableActiveFill: true,
                            cursorColor: accent,
                            textStyle: textBold().copyWith(
                              fontSize: Dimensions.fs20,
                              color: cs.onSurface,
                            ),
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(12),
                              fieldHeight: 56,
                              fieldWidth: fieldWidth,
                              borderWidth: 1,
                              selectedBorderWidth: 1.6,
                              inactiveColor: cs.outline,
                              inactiveFillColor: theme.cardColor,
                              selectedColor: accent,
                              selectedFillColor: theme.cardColor,
                              activeColor: cs.outline,
                              activeFillColor: cs.primaryContainer,
                            ),
                            onChanged:
                                forgotPasswordController.updateVerificationCode,
                            beforeTextPaste: (text) => true,
                          ),
          
                          SizedBox(height: Dimensions.h16),
          
                          // Lock countdown (only on 405/429)
                          if (_blocked)
                            Padding(
                              padding: EdgeInsets.only(bottom: Dimensions.h10),
                              child: Text(
                                _formatTime(_seconds),
                                style: textBold().copyWith(color: cs.error),
                              ),
                            ),
          
                          // Resend row
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'did_not_receive_the_code'.tr,
                                style: textRegular()
                                    .copyWith(color: cs.onSurfaceVariant),
                              ),
                              !forgotPasswordController.isLoading
                                  ? TextButton(
                                      onPressed: _seconds < 1
                                          ? () =>
                                              _resend(forgotPasswordController)
                                          : null,
                                      child: Text(
                                        '${'resend'.tr}${_seconds > 0 ? ' (${_formatTime(_seconds)})' : ''}',
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Dimensions.w20),
                                      child: const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                            ],
                          ),
          
                          SizedBox(height: Dimensions.h25),
          
                          // Always visible: disabled until the 6 digits are in.
                          CustomButtonWidget(
                            buttonText: 'verify'.tr,
                            isLoading: forgotPasswordController.isLoading,
                            onPressed: canVerify
                                ? () => _verify(forgotPasswordController)
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
