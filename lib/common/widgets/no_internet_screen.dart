import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/splash/screens/splash_screen.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoInternetScreen extends StatelessWidget {
  final Widget? child;

  /// When set, Retry reruns this load in place instead of navigating
  /// (used inside a tab, for example My Orders).
  final VoidCallback? onRetry;

  /// True when the server failed (5xx, 403, a body that is not JSON) while
  /// the internet works: same screen, server text (D-12).
  final bool serverProblem;
  const NoInternetScreen(
      {super.key, this.child, this.onRetry, this.serverProblem = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.w16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "oops".tr,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs28,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Dimensions.h16),
                    Image.asset(
                      ManagerAssets.noInternetImage,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: Dimensions.h25),
                    Text(
                      (serverProblem ? 'server_problem' : 'no_connection').tr,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs24,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Dimensions.h10),
                    Text(
                      (serverProblem
                              ? 'server_problem_try_again'
                              : 'please_check_your_internet_and_try_again')
                          .tr,
                      style: textRegular().copyWith(
                        fontSize: Dimensions.fs18,
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ زر Retry ثابت بأسفل الصفحة
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimensions.w16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: Dimensions.r5,
                  spreadRadius: Dimensions.r1,
                  offset: Offset(0, -Dimensions.h2),
                ),
              ],
            ),
            child: CustomButtonWidget(
              onPressed: () async {
                final List<ConnectivityResult> connectivityResult =
                    await (Connectivity().checkConnectivity());

                if (!connectivityResult.contains(ConnectivityResult.none)) {
                  try {
                    // ✅ إعادة تحميل Splash
                    if (onRetry != null) {
                      onRetry!();
                    } else if (child != null) {
                      Get.off(() => child!);
                    } else {
                      Get.offAll(() => const SplashScreen(body: null));
                    }
                  } catch (e) {
                    showCustomSnackBar('error_occurred'.tr);
                  }
                } else {
                  showCustomSnackBar('still_no_internet_connection'.tr);
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              buttonText: "retry".tr,
            ),
          ),
        ],
      ),
    );
  }
}
