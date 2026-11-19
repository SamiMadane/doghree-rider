import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:doghree_rider/interface/repository_interface.dart';

abstract class AuthRepositoryInterface implements RepositoryInterface {
  Future<dynamic> login(String phone, String password);
  Future<dynamic> updateToken();
  Future<bool> saveUserToken(String token, String? zoneTopic, String? vehicleWiseTopic);
  String getUserToken();
  bool isLoggedIn();
  Future<bool> clearSharedData();
  Future<bool> retryPendingPushCleanup();
  Future<void> saveUserNumber(String number, String countryDialCode, String countryCode);
  Future<void> purgeStoredPassword();
  String getUserNumber();
  String getUserCountryDialCode();
  String getUserCountryCode();
  bool isNotificationActive();
  void setNotificationActive(bool isActive);
  Future<bool> clearUserNumber();
  Future<dynamic> registerDeliveryMan(DeliveryManBodyModel deliveryManBody, List<MultipartBody> multiParts);
  Future<void> setLogoutReason(String reason);
  Future<String?> getLogoutReason();
  Future<void> clearLogoutReason();
}