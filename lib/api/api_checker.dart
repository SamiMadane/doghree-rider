import 'package:flutter/foundation.dart';
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
        showCloseButton: false,
      );
    } else {
      _isSessionExpiredBottomSheetShown = false;
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }
    debugPrint('SESSION EXPIRED triggered. token=${Get.find<AuthController>().getUserToken()}');
debugPrint(StackTrace.current.toString());
  }

  static void resetDialogState() {
    _isSessionExpiredBottomSheetShown = false;
  }
}

// import 'package:doghree_rider/api/api_error_handler.dart';
// import 'package:doghree_rider/api/api_error_model.dart';
// import 'package:doghree_rider/api/error_type.dart';
// import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
// import 'package:doghree_rider/common/widgets/session_expired_bottom_sheet.dart';
// import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
// import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
// import 'package:doghree_rider/helper/route_helper.dart';
// import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
// import 'package:get/get.dart';

// class ApiChecker {
//   static bool _isSessionExpiredBottomSheetShown = false;

//   /// معالجة الاستجابة والتحقق من الأخطاء
//   static void checkApi(Response response, {bool showToast = true}) {
//     // معالجة الخطأ باستخدام النظام الجديد
//     final errorModel = ApiErrorHandler.handleError(response);

//     // التعامل مع حالات خاصة
//     if (response.statusCode == HttpStatusCode.unauthorized) {
//       _handleSessionExpired(showBottomSheet: showToast);
//       return;
//     }

//     // عرض رسالة الخطأ للمستخدم
//     if (showToast) {
//       _showErrorMessage(errorModel);
//     }
//   }

//   /// عرض رسالة الخطأ بشكل مناسب
//   static void _showErrorMessage(ApiErrorModel errorModel) {
//     // إذا كان هناك أخطاء validation
//     if (errorModel.validationErrors != null &&
//         errorModel.validationErrors!.isNotEmpty) {
//       final validationMessage =
//           ApiErrorHandler.formatValidationErrors(errorModel.validationErrors);
//       showCustomSnackBar(
//         '${errorModel.message}\n$validationMessage',
//         isError: true,
//       );
//       return;
//     }

//     // عرض الرسالة العادية
//     showCustomSnackBar(
//       errorModel.message,
//       isError: true,
//     );
//   }

//   /// معالجة انتهاء الجلسة
//   static void _handleSessionExpired({bool showBottomSheet = true}) {
//     // منع إظهار أكثر من Dialog
//     if (_isSessionExpiredBottomSheetShown) return;
//     _isSessionExpiredBottomSheetShown = true;

//     Get.find<AuthController>().clearSharedData();
//     Get.find<ProfileController>().stopLocationRecord();

//     if (showBottomSheet && Get.context != null) {
//       // إظهار Dialog
//       showCustomBottomSheet(
//         child: SessionExpiredBottomSheet(
//           onConfirm: () {
//             _isSessionExpiredBottomSheetShown = false;
//             Get.back(); // يغلق الشيت
//             Get.offAllNamed(RouteHelper.getSignInRoute());
//           },
//         ),
//         isDismissible: false,
//         showCloseButton: false,
//       );
//     } else {
//       // إذا التطبيق في الخلفية أو لا نريد Dialog
//       _isSessionExpiredBottomSheetShown = false;
//       Get.offAllNamed(RouteHelper.getSignInRoute());
//     }
//   }

//   /// إعادة تعيين حالة الـ Dialog
//   static void resetDialogState() {
//     _isSessionExpiredBottomSheetShown = false;
//   }

//   /// معالجة الأخطاء بدون عرض رسالة (للاستخدام في الـ Controllers)
//   static ApiErrorModel handleErrorSilently(dynamic error) {
//     return ApiErrorHandler.handleError(error);
//   }

//   /// التحقق من نوع الخطأ
//   static bool isNoInternetError(Response response) {
//     return response.statusCode == HttpStatusCode.noInternet ||
//         response.statusCode == 1;
//   }

//   static bool isServerError(Response response) {
//     return response.statusCode == HttpStatusCode.serverError ||
//         response.statusCode == HttpStatusCode.serviceUnavailable;
//   }

//   static bool isUnauthorizedError(Response response) {
//     return response.statusCode == HttpStatusCode.unauthorized;
//   }

//   static bool isValidationError(Response response) {
//     return response.statusCode == HttpStatusCode.validationError;
//   }
// }
