import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/forgot_password/domain/services/forgot_password_service_interface.dart';
import 'package:doghree_rider/helper/firebase_state.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:flutter/foundation.dart';

class ForgotPasswordController extends GetxController implements GetxService {
  final ForgotPasswordServiceInterface forgotPasswordServiceInterface;
  ForgotPasswordController({required this.forgotPasswordServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _verificationCode = '';
  String get verificationCode => _verificationCode;

  /// Runs one request with the loader on. The loader always stops, and an
  /// exception becomes a failed result instead of a stuck button (D-12, C3).
  Future<ResponseModel> _withLoader(Future<ResponseModel> Function() call) async {
    _isLoading = true;
    update();
    try {
      return await call();
    } catch (e) {
      if (kDebugMode) debugPrint('forgot password call failed: ${e.runtimeType}');
      return ResponseModel(false, 'error_occurred'.tr);
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<bool> changePassword(ProfileModel updatedUserModel, String currentPassword, String password) async {
    final ResponseModel responseModel = await _withLoader(() =>
        forgotPasswordServiceInterface.changePassword(updatedUserModel, currentPassword, password));
    if (responseModel.isSuccess) {
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    return responseModel.isSuccess;
  }

  Future<ResponseModel> forgetPassword(String? phone) =>
      _withLoader(() => forgotPasswordServiceInterface.forgetPassword(phone));

  Future<ResponseModel> verifyToken(String? number) => _withLoader(
      () => forgotPasswordServiceInterface.verifyToken(number, _verificationCode));

  Future<ResponseModel> verifyFirebaseOtp({required String phoneNumber, required String session, required String otp}) =>
      _withLoader(() => forgotPasswordServiceInterface.verifyFirebaseOtp(
          phoneNumber: phoneNumber, session: session, otp: otp));

  Future<ResponseModel> resetPassword(String? resetToken, String phone, String password, String confirmPassword) =>
      _withLoader(() => forgotPasswordServiceInterface.resetPassword(
          resetToken, phone, password, confirmPassword));

  void updateVerificationCode(String query) {
    _verificationCode = query;
    update();
  }

  Future<void> firebaseVerifyPhoneNumber(String phoneNumber, {bool canRoute = true}) async {
    // Without Firebase there is no phone verification: one message, no
    // loader left running (D-12).
    if (!FirebaseState.ready) {
      showCustomSnackBar('error_occurred'.tr);
      return;
    }
    _isLoading = true;
    update();

    try {
      await _verifyPhoneNumber(phoneNumber, canRoute);
    } catch (e) {
      if (kDebugMode) debugPrint('verifyPhoneNumber failed: ${e.runtimeType}');
      _isLoading = false;
      update();
      showCustomSnackBar('error_occurred'.tr);
    }
  }

  Future<void> _verifyPhoneNumber(String phoneNumber, bool canRoute) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isLoading = false;
        update();

        if(e.code == 'invalid-phone-number') {
          showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
        }else{
          showCustomSnackBar(e.message?.replaceAll('_', ' '));
        }

      },
      codeSent: (String vId, int? resendToken) {
        _isLoading = false;
        update();

        if(canRoute) {
          Get.toNamed(RouteHelper.getVerificationRoute(phoneNumber, session: vId));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

}