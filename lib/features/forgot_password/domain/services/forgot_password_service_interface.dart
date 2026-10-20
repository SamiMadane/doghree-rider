import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';

abstract class ForgotPasswordServiceInterface {
  Future<ResponseModel> changePassword(ProfileModel userInfoModel, String currentPassword, String password);
  Future<ResponseModel> forgetPassword(String? phone);
  Future<ResponseModel> verifyToken(String? phone, String token);
  Future<ResponseModel> resetPassword(String? resetToken, String phone, String password, String confirmPassword);
  Future<ResponseModel> verifyFirebaseOtp({required String phoneNumber, required String session, required String otp});
}