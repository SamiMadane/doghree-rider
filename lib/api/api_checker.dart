import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/common/widgets/session_expired_bottom_sheet.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';

class ApiChecker {
  static bool _isSessionExpiredBottomSheetShown = false;

  static void checkApi(Response response, {bool showDialog = true}) {
    if (response.statusCode == 401) {
      _handleSessionExpired(showBottomSheet: showDialog);
    } else {
      showCustomSnackBar(response.statusText);
    }
  }

  static void _handleSessionExpired({bool showBottomSheet = true}) {
    // منع إظهار أكثر من Dialog
    if (_isSessionExpiredBottomSheetShown) return;
    _isSessionExpiredBottomSheetShown = true;

    Get.find<AuthController>().clearSharedData();
    Get.find<ProfileController>().stopLocationRecord();

    if (showBottomSheet && Get.context != null) {
      // إظهار Dialog
      showCustomBottomSheet(
        child: SessionExpiredBottomSheet(
          onConfirm: () {
            _isSessionExpiredBottomSheetShown = false;
            Get.back(); // يغلق الشيت
            Get.offAllNamed(RouteHelper.getSignInRoute());
          },
        ),
        isDismissible: false, // مهم
        showCloseButton: false, // نريد إزالة زر الإغلاق
      );
    } else {
      // إذا التطبيق في الخلفية أو لا نريد Dialog
      _isSessionExpiredBottomSheetShown = false;
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }
  }

  // دالة لإعادة تعيين الحالة (مفيدة للحالات الخاصة)
  static void resetDialogState() {
    _isSessionExpiredBottomSheetShown = false;
  }
}


// import 'package:wefrh_rider/api/api_error_handler.dart';
// import 'package:wefrh_rider/api/api_error_model.dart';
// import 'package:wefrh_rider/api/error_type.dart';
// import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
// import 'package:wefrh_rider/common/widgets/session_expired_bottom_sheet.dart';
// import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
// import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
// import 'package:wefrh_rider/helper/route_helper.dart';
// import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
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
