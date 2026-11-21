import 'package:doghree_rider/features/dashboard/widgets/dashboard_bottom_nav_widget.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// G2 (audit row 60): the bottom nav, sized through `Dimensions`, lays out
/// without an overflow on one logical screen size.
///
/// `Dimensions` fields are static and computed once, on first access, from the
/// ScreenUtil scale. So every screen size runs in its own test file (its own
/// isolate) and calls this case once. Not a test file itself (no `_test`).
///
/// Widget tests render text with the test font, so this guards the layout
/// arithmetic only; the real check stays on a device (D-11).
void runBottomNavOverflowCase(Size logicalSize) {
  testWidgets(
      'G2 bottom nav has no overflow at '
      '${logicalSize.width.toInt()}x${logicalSize.height.toInt()}',
      (tester) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = logicalSize * 2.0;
    addTearDown(tester.view.reset);

    for (int page = 0; page < 4; page++) {
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(376, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => GetMaterialApp(
          theme: light,
          home: Scaffold(
            body: const SizedBox.shrink(),
            bottomNavigationBar: DashboardBottomNavWidget(
              pageIndex: page,
              itemCount: 4,
              onTap: (_) {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'page $page');
      expect(find.byType(DashboardBottomNavWidget), findsOneWidget);
    }
  });
}
