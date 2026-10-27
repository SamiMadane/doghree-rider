import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_toast.dart';
import 'package:doghree_rider/util/dimensions.dart';

void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
  int? showDuration,
}) {
  if (message == null || message.isEmpty) return;

  try {
    final context = Get.overlayContext;

    if (getXSnackBar) {
      if (context != null) {
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Colors.transparent,
          messageText: CustomToast(text: message, isError: isError),
          maxWidth: 500,
          duration: Duration(seconds: showDuration ?? 3),
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.only(
            left: Dimensions.w10,
            right: Dimensions.w10,
            bottom: 100,
          ),
          borderRadius: 50,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        ));
      } else {
        if (kDebugMode) print('SnackBar (GetX) skipped: $message');
      }
    } else {
      if (context != null) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(SnackBar(
          dismissDirection: DismissDirection.endToStart,
          elevation: 0,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          content: CustomToast(text: message, isError: isError),
          duration: Duration(seconds: showDuration ?? 2),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        // Fallback: print to console
        if (kDebugMode) print('SnackBar (Scaffold) skipped: $message');
      }
    }
  } catch (e) {
    // Safety fallback
    if (kDebugMode) {
      print('❌ Failed to show snackbar safely: $e');
    }
  }
}
