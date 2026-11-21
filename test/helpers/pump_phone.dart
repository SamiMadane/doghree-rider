import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Pumps [home] on a phone-sized surface (the 376x812 design size) inside
/// ScreenUtil and GetMaterialApp, the way the app runs it. Translations are
/// not loaded, so `.tr` shows the key: tests find texts by key.
Future<void> pumpPhone(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(376 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(376, 812),
    builder: (_, __) => GetMaterialApp(theme: light, home: home),
  ));
  await tester.pump();
}
