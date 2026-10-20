import 'dart:async';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/api/api_error_handler.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/auth/domain/models/vehicle_model.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/features/auth/domain/services/auth_service_interface.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/helper/image_picker_helper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:doghree_rider/util/app_constants.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}) {
    _notification = authServiceInterface.isNotificationActive();
  }

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _notification = true;
  bool get notification => _notification;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  List<XFile> _pickedIdentities = [];
  List<XFile> get pickedIdentities => _pickedIdentities;

  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  List<String> get identityTypeList => _identityTypeList;

  String? _selectedIdentityType;
  String? get selectedIdentityType => _selectedIdentityType;

  final List<String> _dmTypeList = ['freelancer', 'salary_based'];
  List<String> get dmTypeList => _dmTypeList;

  String? _selectedDmType;
  String? get selectedDmType => _selectedDmType;

  String? _selectedDmTypeId;
  String? get selectedDmTypeId => _selectedDmTypeId;

  List<VehicleModel>? _vehicles;
  List<VehicleModel>? get vehicles => _vehicles;

  List<int?>? _vehicleIds;
  List<int?>? get vehicleIds => _vehicleIds;

  String? _selectedVehicleId;
  String? get selectedVehicleId => _selectedVehicleId;

  double _dmStatus = 0.4;
  double get dmStatus => _dmStatus;

  bool _lengthCheck = false;
  bool get lengthCheck => _lengthCheck;

  bool _numberCheck = false;
  bool get numberCheck => _numberCheck;

  bool _uppercaseCheck = false;
  bool get uppercaseCheck => _uppercaseCheck;

  bool _lowercaseCheck = false;
  bool get lowercaseCheck => _lowercaseCheck;

  bool _spatialCheck = false;
  bool get spatialCheck => _spatialCheck;

  bool _showPassView = false;
  bool get showPassView => _showPassView;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  Map<String, String> _fieldErrors = {};
  String? fieldError(String key) => _fieldErrors[key];

  void clearFieldError(String key) {
    if (_fieldErrors.containsKey(key)) {
      _fieldErrors.remove(key);
      update();
    }
  }

  void setFieldErrors(Map<String, String> errors) {
    _fieldErrors = errors;
    update();
  }
Future<ResponseModel> login(String phone, String password) async {
  _isLoading = true;
  update();
  Response response = await authServiceInterface.login(phone, password);
  ResponseModel responseModel;
  if (response.statusCode == 200) {
    authServiceInterface.saveUserToken(response.body['token'],
        response.body['zone_topic'], response.body['topic']);
    await authServiceInterface.updateToken();
    responseModel = ResponseModel(true, 'successful');
  } else {
    final String message = (response.statusText != null &&
            response.statusText!.isNotEmpty)
        ? response.statusText!
        : 'error_occurred'.tr;

    // فقط أخطاء بيانات الدخول بتنزل تحت الحقل، أي شي ثاني (إنترنت/سيرفر) snackbar
    if (_isCredentialsError(response.statusCode)) {
      _fieldErrors = {'login_password': message};
    } else {
      ApiChecker.checkApi(response, sessionAware: false);
    }
    responseModel = ResponseModel(false, message);
  }
  _isLoading = false;
  update();
  return responseModel;
}

bool _isCredentialsError(int? code) => code == 401 || code == 422;

  static const List<String> _step1Fields = [
    'email',
    'phone',
    'password',
    'f_name',
    'l_name',
    'image'
  ];

  bool _isStep1Error(String? code) =>
      code != null &&
      _step1Fields.any((f) => code == f || code.startsWith('$f.'));

  Future<void> registerDeliveryMan(DeliveryManBodyModel deliveryManBody) async {
    if (_isLoading) return; // يمنع الضغط المزدوج
    _isLoading = true;
    _fieldErrors = {};
    update();
    try {
      final List<MultipartBody> multiParts = authServiceInterface
          .prepareMultiPartsBody(_pickedImage, _pickedIdentities);
      final Response response = await authServiceInterface.registerDeliveryMan(
          deliveryManBody, multiParts);

      if (response.statusCode == 200) {
        Get.offAllNamed(RouteHelper.getDmRegistrationSuccessRoute());
      } else {
        final errs = ApiErrorHandler.extractErrors(response.body);
        final step1 = errs.where((e) => _isStep1Error(e.key)).toList();
        if (step1.isNotEmpty) {
          _fieldErrors = {for (final e in step1) e.key: e.value};
          _dmStatus = 0.4;
        } else {
          ApiChecker.checkApi(response, sessionAware: false);
        }
      }
    } catch (e) {
      debugPrint('REGISTER error: $e');
      showCustomSnackBar('error_occurred'.tr);
    }
    _isLoading = false;
    update();
  }

  void setSelectedDmType(String? dmType) {
    _selectedDmType = dmType;
    _selectedDmTypeId = _selectedDmType == 'freelancer' ? '1' : '0';
    update();
  }

  void setSelectedVehicleType({String? vehicleId}) {
    _selectedVehicleId = vehicleId;
    update();
  }

  void setSelectedIdentityType(String? identityType) {
    _selectedIdentityType = identityType;
    update();
  }

  Future<void> getVehicleList() async {
    List<VehicleModel>? vehicles = await authServiceInterface.getVehicleList();
    if (vehicles != null) {
      _vehicles = [];
      _vehicleIds = [];
      _vehicles!.addAll(vehicles);
      _vehicleIds!.addAll(authServiceInterface.vehicleIds(vehicles));
    }
    update();
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  void dmStatusChange(double value, {bool isUpdate = true}) {
    _dmStatus = value;
    if (isUpdate) {
      update();
    }
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authServiceInterface.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password,
      String countryDialCode, String countryCode) {
    authServiceInterface.saveUserNumberAndPassword(
        number, password, countryDialCode, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryDialCode() {
    return authServiceInterface.getUserCountryDialCode();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  // ========== ✅ NEW: Pick Image with Crop Support ==========
  /// اختيار صورة الديلفري مان مع القص الاحترافي
  static const int _maxImageBytes = 2 * 1024 * 1024;

  Future<bool> _imageSizeOk(XFile file) async {
    try {
      return await file.length() <= _maxImageBytes;
    } catch (_) {
      return true;
    }
  }

  Future<void> pickDmImageWithCrop(BuildContext context) async {
    final XFile? croppedImage =
        await ImagePickerHelper.showImageSourceBottomSheet(
      context: context,
      cropStyle: CropStyle.circle, // دائري للبروفايل
      lockAspectRatio: false,
    );
    if (croppedImage != null) {
      if (!await _imageSizeOk(croppedImage)) {
        showCustomSnackBar('please_upload_lower_size_file'.tr);
        return;
      }
      _pickedImage = croppedImage;
      update();
    }
  }

  /// اختيار صور الهوية مع القص الاحترافي
  Future<void> pickIdentityImageWithCrop(BuildContext context) async {
    final XFile? croppedImage =
        await ImagePickerHelper.showImageSourceBottomSheet(
      context: context,
      cropStyle: CropStyle.rectangle,
      lockAspectRatio: true,
      aspectRatio: const CropAspectRatio(ratioX: 856, ratioY: 540),
    );

    if (croppedImage != null) {
      if (!await _imageSizeOk(croppedImage)) {
        showCustomSnackBar('please_upload_lower_size_file'.tr);
        return;
      }
      _pickedIdentities.add(croppedImage);
      update();
    }
  }

  // ========== ⚠️ KEEP OLD METHOD (for backward compatibility) ==========
  void pickDmImageForRegistration(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    } else {
      if (isLogo) {
        _pickedImage = await authServiceInterface.pickImageFromGallery();
      } else {
        XFile? pickedIdentities =
            await authServiceInterface.pickImageFromGallery();
        if (pickedIdentities != null) {
          _pickedIdentities.add(pickedIdentities);
        }
      }
      update();
    }
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  void showHidePass({bool isUpdate = true}) {
    _showPassView = !_showPassView;
    if (isUpdate) {
      update();
    }
  }

  Future<void> setLogoutReason(String reason) async {
    await authServiceInterface.setLogoutReason(reason);
  }

  Future<String?> getLogoutReason() async {
    return await authServiceInterface.getLogoutReason();
  }

  Future<void> clearLogoutReason() async {
    await authServiceInterface.clearLogoutReason();
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if (pass.length > 7) {
      _lengthCheck = true;
    }
    if (pass.contains(RegExp(r'[a-z]'))) {
      _lowercaseCheck = true;
    }
    if (pass.contains(RegExp(r'[A-Z]'))) {
      _uppercaseCheck = true;
    }
    if (pass.contains(RegExp(r'[ .!@#$&*~^%]'))) {
      _spatialCheck = true;
    }
    if (pass.contains(RegExp(r'[\d+]'))) {
      _numberCheck = true;
    }
    if (isUpdate) {
      update();
    }
  }

  void resetDmRegistrationData() {
    _fieldErrors = {};
    _pickedImage = null;
    _pickedIdentities = [];
    _selectedIdentityType = null;
    _selectedDmType = AppConstants.allowDmTypeSelection ? null : 'freelancer';
    _selectedDmTypeId = AppConstants.allowDmTypeSelection ? null : '1';
    _selectedVehicleId = null;
    _dmStatus = 0.4;
    _showPassView = false;
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;
  }
}
