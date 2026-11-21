import 'package:get/get.dart';
import 'package:doghree_rider/api/api_error_handler.dart';
import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/common/widgets/session_expired_bottom_sheet.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';

class ApiChecker {
  static bool _isSessionExpiredBottomSheetShown = false;
    static bool isLoggingOut = false;

  /// sessionAware=false: الـ 401 خطأ عادي (مسارات /auth/)
  static void checkApi(Response response,
      {bool showDialog = true, bool sessionAware = true}) {
    if (response.statusCode == 401 && sessionAware) {
      if (isLoggingOut) return; 
      _handleSessionExpired(showBottomSheet: showDialog);
      return;
    }
    showCustomSnackBar(_messageFor(response));
  }

  /// For silent calls (handleError: false): no toast for any failure, but a
  /// 401 still ends the session the same way as a normal call.
  static void checkSession(Response response) {
    if (response.statusCode == 401) checkApi(response);
  }

  static String _messageFor(Response response) {
    if (response.statusCode == 1) {
      return ErrorMessages.getMessage(ErrorType.noInternet);
    }
    final text = response.statusText;
    if (text != null && text.trim().isNotEmpty) return text; // رسالة الخادم العربية
    return ErrorMessages.getMessage(
        ApiErrorHandler.getErrorType(response.statusCode ?? 0));
  }

  static void _handleSessionExpired({bool showBottomSheet = true}) {
    if (_isSessionExpiredBottomSheetShown) return;
    if (!Get.find<AuthController>().isLoggedIn()) return;
    _isSessionExpiredBottomSheetShown = true;

    Get.find<AuthController>().clearSharedData();
    Get.find<ProfileController>().stopLocationRecord();

    if (showBottomSheet && Get.context != null) {
      showCustomBottomSheet(
        child: SessionExpiredBottomSheet(
          onConfirm: () {
            _isSessionExpiredBottomSheetShown = false;
            Get.back();
            Get.offAllNamed(RouteHelper.getSignInRoute());
          },
        ),
        isDismissible: false,
      );
    } else {
      _isSessionExpiredBottomSheetShown = false;
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }
  }

  static void resetDialogState() {
    _isSessionExpiredBottomSheetShown = false;
  }
}
