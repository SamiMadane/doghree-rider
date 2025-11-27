// ملف جديد: helper/session_checker.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:wefrh_rider/api/api_client.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/util/app_constants.dart';

/// مدير فحص صلاحية الجلسة بشكل دوري
class SessionChecker extends GetxService {
  final ApiClient apiClient;
  Timer? _sessionCheckTimer;
  
  SessionChecker({required this.apiClient});

  /// بدء فحص الجلسة كل 30 ثانية
  void startSessionCheck() {
    stopSessionCheck();
    
    _sessionCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _checkSession(),
    );
  }

  /// إيقاف فحص الجلسة
  void stopSessionCheck() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }

  /// فحص صلاحية الجلسة
  Future<void> _checkSession() async {
    if (!Get.find<AuthController>().isLoggedIn()) {
      stopSessionCheck();
      return;
    }

    try {
      Response response = await apiClient.getData(
        AppConstants.profileUri + _getUserToken(),
        handleError: false,
      );

      if (response.statusCode == 401) {
        stopSessionCheck();
      }
    } catch (e) {
      print('Session check failed: $e');
    }
  }

  String _getUserToken() {
    return Get.find<AuthController>().getUserToken();
  }

  @override
  void onClose() {
    stopSessionCheck();
    super.onClose();
  }
}