import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/theme_extension.dart';

// Dark mode: primary and CTA buttons are both yellow + asphalt.
final ButtonStyle _ctaButtonDark = ButtonStyle(
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
      return ManagerColors.disabledButtonDarkMode;
    }
    return ManagerColors.primaryDark;
  }),
  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
    if (states.contains(WidgetState.disabled)) return ManagerColors.hintDark;
    return ManagerColors.onPrimary;
  }),
  overlayColor: const WidgetStatePropertyAll<Color>(Color(0x1F1B1B1B)),
);

ThemeData dark = ThemeData(
  fontFamily: 'Roboto', // fonts: postponed
  primaryColor: ManagerColors.primaryDark,
  disabledColor: ManagerColors.disabledDark,
  brightness: Brightness.dark,
  hintColor: ManagerColors.hintDark,
  cardColor: ManagerColors.cardDark,
  shadowColor: ManagerColors.shadowDark,
  scaffoldBackgroundColor: ManagerColors.scaffoldBgDark,
  colorScheme: const ColorScheme.dark(
    primary: ManagerColors.primaryDark,
    onPrimary: ManagerColors.onPrimary,
    primaryContainer: ManagerColors.primaryBgDark,
    onPrimaryContainer: ManagerColors.primaryDark,
    // asphalt would vanish on the asphalt surface, so secondary flips to white
    secondary: ManagerColors.white,
    onSecondary: ManagerColors.onPrimary,
    tertiary: ManagerColors.primaryDark,
    onTertiary: ManagerColors.onPrimary,
    surface: ManagerColors.cardDark,
    onSurface: ManagerColors.TextColorDark,
    onSurfaceVariant: ManagerColors.hintDark,
    outline: ManagerColors.Strock2Dark,
    error: ManagerColors.error,
    onError: ManagerColors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ManagerColors.cardDark,
    foregroundColor: ManagerColors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: ManagerColors.white,
      fontSize: 20,
      fontWeight: FontWeight.w800,
    ),
    iconTheme: IconThemeData(color: ManagerColors.white),
    actionsIconTheme: IconThemeData(color: ManagerColors.white),
    // Light status-bar icons over dark.
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(style: _ctaButtonDark),
  filledButtonTheme: FilledButtonThemeData(style: _ctaButtonDark),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ManagerColors.textButtonDark,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: ManagerColors.cardDark,
    surfaceTintColor: ManagerColors.cardDark,
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: ManagerColors.cardDark),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: ManagerColors.fabColor,
    foregroundColor: ManagerColors.onPrimary, // icon on yellow = asphalt
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: ManagerColors.cardDark,
    elevation: 8,
    selectedItemColor: ManagerColors.primaryDark,
    unselectedItemColor: Color(0x99FFFFFF),
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  ),
  // bottomAppBarTheme: BottomAppBarTheme(
  //   color: ManagerColors.bottomAppBarDark,
  //   height: 60,
  //   padding: EdgeInsets.symmetric(vertical: 5),
  // ),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    color: ManagerColors.Strock2Dark,
  ),
  iconTheme: const IconThemeData(color: ManagerColors.iconDark),
  primaryIconTheme: const IconThemeData(color: ManagerColors.iconDark),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: ManagerColors.TextColorDark),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColorsExtension(
      strock1: ManagerColors.Strock1Dark,
      strock2: ManagerColors.Strock2Dark,
      senderMessageBg: ManagerColors.senderMessageBgDark,
      receiverMessageBg: ManagerColors.receiverMessageBgDark,
      grayBg: ManagerColors.grayBgDarkMode,
      primaryBg: ManagerColors.primaryBgDark,
      blueBg: ManagerColors.blueBgDarkMode,
      naturalBlue: ManagerColors.naturalBlueDarkMode,
      darkBlue: ManagerColors.darkBlueDarkMode,
      blue: ManagerColors.blueDarkMode,
      gray: ManagerColors.grayDarkMode,
      green: ManagerColors.greenDarkMode,
      greenBg: ManagerColors.greenBgDarkMode,
      disabledButton: ManagerColors.disabledButtonDarkMode,
      orangeBg: ManagerColors.orangeBgDarkMode,
      orange: ManagerColors.orangeDarkMode,
      red: ManagerColors.redDarkMode,
      redBg: ManagerColors.redBgDarkMode,
    ),
  ],
);