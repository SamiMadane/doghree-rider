import 'package:doghree_rider/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shown when dependency set-up fails at start-up (D-12). Nothing else can
/// run without it, and the translation files are part of what failed, so the
/// text is fixed and in both languages. There is no Retry: running the set-up
/// again on a half-registered GetX container is not safe.
class StartupFailedApp extends StatelessWidget {
  const StartupFailedApp({super.key});

  static const String messageEn =
      'The app could not start. Close it and open it again.';
  static const String messageAr = 'تعذّر تشغيل التطبيق. أغلقه وافتحه من جديد.';

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(376, 812),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.w24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      messageAr,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: Dimensions.fs16),
                    ),
                    SizedBox(height: Dimensions.h16),
                    Text(
                      messageEn,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: Dimensions.fs16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
