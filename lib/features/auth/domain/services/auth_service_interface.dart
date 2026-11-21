import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:doghree_rider/features/auth/domain/models/vehicle_model.dart';

abstract class AuthServiceInterface {
  Future<Response> login(String phone, String password);
  Future<Response> updateToken();
  Future<bool> saveUserToken(
      String token, String? zoneTopic, String? vehicleWiseTopic);
  String getUserToken();
  bool isLoggedIn();
  Future<bool> clearSharedData();
  Future<bool> retryPendingPushCleanup();
  Future<void> saveUserNumber(
      String number, String countryDialCode, String countryCode);
  Future<void> purgeStoredPassword();
  String getUserNumber();
  String getUserCountryDialCode();
  String getUserCountryCode();
  bool isNotificationActive();
  void setNotificationActive(bool isActive);
  Future<bool> clearUserNumber();
  Future<Response> registerDeliveryMan(
      DeliveryManBodyModel deliveryManBody, List<MultipartBody> multiParts);
  Future<List<VehicleModel>?> getVehicleList();
  List<MultipartBody> prepareMultiPartsBody(
      XFile? pickedImage, List<XFile> pickedIdentities);
  List<int?> vehicleIds(List<VehicleModel>? vehicles);
  Future<void> setLogoutReason(String reason);
  Future<String?> getLogoutReason();
  Future<void> clearLogoutReason();
}
