import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: ManagerColors.primary,
  secondaryHeaderColor: ManagerColors.secondary,
  disabledColor: ManagerColors.disabledDark,
  brightness: Brightness.dark,
  hintColor: ManagerColors.hintDark,
  cardColor: ManagerColors.cardDark,
  shadowColor: ManagerColors.shadowDark,
  scaffoldBackgroundColor: ManagerColors.scaffoldBgDark,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ManagerColors.textButtonDark),
  ),
  colorScheme: const ColorScheme.dark(
    primary: ManagerColors.primary,
    secondary: ManagerColors.primary,
  ).copyWith(error: ManagerColors.error),
  popupMenuTheme: const PopupMenuThemeData(
    color: ManagerColors.cardDark,
    surfaceTintColor: ManagerColors.cardDark,
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: ManagerColors.cardDark),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: ManagerColors.fabColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: ManagerColors.bottomAppBarDark,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
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
    ),
  ],
);
