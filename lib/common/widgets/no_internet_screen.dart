import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_svg/svg.dart';
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
  const NoInternetScreen({super.key, this.child});

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
                      "opps".tr,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs28,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Dimensions.h16),
                    SvgPicture.asset(
                      ManagerAssets.noInternetImage,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: Dimensions.h25),
                    Text(
                      "no_connection".tr,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs24,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Dimensions.h10),
                    Text(
                      "please_check_your_internet_and_try_again".tr,
                      style: textRegular().copyWith(
                        fontSize: Dimensions.fs18,
                        color: Theme.of(context).disabledColor,
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
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, -2),
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
                    if (child != null) {
                      Get.off(() => child!);
                    } else {
                      Get.offAll(() => const SplashScreen(body: null));
                    }
                  } catch (e) {
                    print('❌ Error navigating: $e');
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
