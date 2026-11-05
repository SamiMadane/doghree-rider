import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ResponsiveHelper {
  static bool isMobilePhone() => !kIsWeb;

  static bool isWeb() => kIsWeb;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650 || !kIsWeb;

  static bool isTab(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width < 1300 && width >= 650;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1300;
}