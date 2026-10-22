import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/theme_extension.dart';

// Primary button (light): asphalt + white. Pressed: yellow + asphalt.
final ButtonStyle _primaryButtonLight = ButtonStyle(
  elevation: const WidgetStatePropertyAll<double>(0),
  minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 52)),
  padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: 24),
  ),
  shape: WidgetStatePropertyAll<OutlinedBorder>(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  textStyle: const WidgetStatePropertyAll<TextStyle>(
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  ),
  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
    if (states.contains(WidgetState.disabled)) {
      return ManagerColors.disabledButtonLightMode;
    }
    if (states.contains(WidgetState.pressed)) return ManagerColors.primaryLight;
    return ManagerColors.onPrimary;
  }),
  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
    if (states.contains(WidgetState.disabled)) return const Color(0x991B1B1B);
    if (states.contains(WidgetState.pressed)) return ManagerColors.onPrimary;
    return ManagerColors.white;
  }),
  overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
);

// CTA / FilledButton: yellow + asphalt (always asphalt text on yellow).
final ButtonStyle _ctaButtonLight = ButtonStyle(
  elevation: const WidgetStatePropertyAll<double>(0),
  minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 52)),
  padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: 24),
  ),
  shape: WidgetStatePropertyAll<OutlinedBorder>(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  textStyle: const WidgetStatePropertyAll<TextStyle>(
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  ),
  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
    if (states.contains(WidgetState.disabled)) {
      return ManagerColors.disabledButtonLightMode;
    }
    return ManagerColors.primaryLight;
  }),
  foregroundColor: const WidgetStatePropertyAll<Color>(ManagerColors.onPrimary),
  overlayColor: const WidgetStatePropertyAll<Color>(Color(0x1F1B1B1B)),
);

ThemeData light = ThemeData(
  fontFamily: 'Roboto', // fonts: postponed
  primaryColor: ManagerColors.primaryLight,
  disabledColor: ManagerColors.disabledLight,
  brightness: Brightness.light,
  hintColor: ManagerColors.hintLight,
  cardColor: ManagerColors.cardLight,
  shadowColor: ManagerColors.shadowLight,
  scaffoldBackgroundColor: ManagerColors.scaffoldBgLight,
  colorScheme: const ColorScheme.light(
    primary: ManagerColors.primaryLight,
    onPrimary: ManagerColors.onPrimary,
    primaryContainer: ManagerColors.primaryBgLight,
    onPrimaryContainer: ManagerColors.onPrimary,
    secondary: ManagerColors.onPrimary, // asphalt
    onSecondary: ManagerColors.white,
    tertiary: ManagerColors.textButtonLight, // textAccent
    onTertiary: ManagerColors.white,
    surface: ManagerColors.cardLight,
    onSurface: ManagerColors.TextColorLight,
    onSurfaceVariant: ManagerColors.hintLight,
    outline: ManagerColors.Strock2Light,
    error: ManagerColors.error,
    onError: ManagerColors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ManagerColors.primaryLight,
    foregroundColor: ManagerColors.onPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: ManagerColors.onPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w800,
    ),
    iconTheme: IconThemeData(color: ManagerColors.onPrimary),
    actionsIconTheme: IconThemeData(color: ManagerColors.onPrimary),
    // Dark status-bar icons over yellow.
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(style: _primaryButtonLight),
  filledButtonTheme: FilledButtonThemeData(style: _ctaButtonLight),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ManagerColors.textButtonLight,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: ManagerColors.cardLight,
    surfaceTintColor: ManagerColors.cardLight,
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: ManagerColors.cardLight),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: ManagerColors.fabColor,
    foregroundColor: ManagerColors.onPrimary, // icon on yellow = asphalt
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: ManagerColors.cardLight,
    elevation: 8,
    selectedItemColor: ManagerColors.onPrimary,
    unselectedItemColor: Color(0x993A3A3A),
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  ),
  // bottomAppBarTheme: const BottomAppBarTheme(
  //   color: ManagerColors.bottomAppBarLight,
  //   height: 60,
  //   padding: EdgeInsets.symmetric(vertical: 5),
  // ),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    color: ManagerColors.Strock2Light,
  ),
  iconTheme: const IconThemeData(color: ManagerColors.iconLight),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: ManagerColors.TextColorLight),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColorsExtension(
      strock1: ManagerColors.Strock1Light,
      strock2: ManagerColors.Strock2Light,
      senderMessageBg: ManagerColors.senderMessageBgLight,
      receiverMessageBg: ManagerColors.receiverMessageBgLight,
      grayBg: ManagerColors.grayBgLightMode,
      primaryBg: ManagerColors.primaryBgLight,
      blueBg: ManagerColors.blueBgLightMode,
      naturalBlue: ManagerColors.naturalBlueLightMode,
      darkBlue: ManagerColors.darkBlueLightMode,
      blue: ManagerColors.blueLightMode,
      gray: ManagerColors.grayLightMode,
      green: ManagerColors.greenLightMode,
      greenBg: ManagerColors.greenBgLightMode,
      disabledButton: ManagerColors.disabledButtonLightMode,
      orangeBg: ManagerColors.orangeBgLightMode,
      orange: ManagerColors.orangeLightMode,
      red: ManagerColors.redLightMode,
      redBg: ManagerColors.redBgLightMode,
    ),
  ],
);