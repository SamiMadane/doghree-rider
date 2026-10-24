import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/theme_extension.dart';

// new: shared border for input fields (radius 12 per brand guide)
OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

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
    if (states.contains(WidgetState.disabled)) {
      return const Color(0x991B1B1B); // was ManagerColors.hintDark (asphalt 60% on faded yellow)
    }
    return ManagerColors.onPrimary;
  }),
  overlayColor: const WidgetStatePropertyAll<Color>(Color(0x1F1B1B1B)),
);

ThemeData dark = ThemeData(
  fontFamily: 'Roboto', // fonts: postponed (target: Tajawal + Lemonada for displayLarge/headlineLarge)
  primaryColor: ManagerColors.primaryDark,
  disabledColor: ManagerColors.disabledDark,
  brightness: Brightness.dark,
  hintColor: ManagerColors.hintDark,
  cardColor: ManagerColors.cardDark,
  shadowColor: ManagerColors.shadowDark,
  scaffoldBackgroundColor: ManagerColors.scaffoldBgDark,
  dividerColor: ManagerColors.Strock2Dark, // new
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
  // new: input fields per brand guide (radius 12, focused border yellow 1.6)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ManagerColors.cardDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ManagerColors.hintDark,
    ),
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ManagerColors.hintDark,
    ),
    floatingLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: ManagerColors.TextColorDark,
    ),
    errorStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ManagerColors.error,
    ),
    border: _inputBorder(ManagerColors.Strock2Dark),
    enabledBorder: _inputBorder(ManagerColors.Strock2Dark),
    focusedBorder: _inputBorder(ManagerColors.primaryDark, 1.6),
    errorBorder: _inputBorder(ManagerColors.error),
    focusedErrorBorder: _inputBorder(ManagerColors.error, 1.6),
  ),
  // new: chips (dark yellowSoft when selected, stadium shape)
  chipTheme: ChipThemeData(
    backgroundColor: ManagerColors.cardDark,
    selectedColor: ManagerColors.primaryBgDark,
    checkmarkColor: ManagerColors.primaryDark,
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: ManagerColors.TextColorDark,
    ),
    side: const BorderSide(color: ManagerColors.Strock2Dark),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  // new: cards use cardDark explicitly
  cardTheme: const CardThemeData(
    color: ManagerColors.cardDark,
    surfaceTintColor: ManagerColors.cardDark,
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: ManagerColors.cardDark,
    surfaceTintColor: ManagerColors.cardDark,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: ManagerColors.cardDark, // new
    surfaceTintColor: ManagerColors.cardDark,
  ),
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