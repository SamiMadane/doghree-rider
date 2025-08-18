import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: ColorsManager.primary,
  secondaryHeaderColor: ColorsManager.secondary,
  disabledColor: ColorsManager.disabledDark,
  brightness: Brightness.dark,
  hintColor: ColorsManager.hintDark,
  cardColor: ColorsManager.cardDark,
  shadowColor: ColorsManager.shadowDark,
  scaffoldBackgroundColor: ColorsManager.scaffoldBgDark,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ColorsManager.textButtonDark),
  ),
  colorScheme: const ColorScheme.dark(
    primary: ColorsManager.primary,
    secondary: ColorsManager.primary,
  ).copyWith(error: ColorsManager.error),
  popupMenuTheme: const PopupMenuThemeData(
    color: ColorsManager.cardDark,
    surfaceTintColor: ColorsManager.cardDark,
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: ColorsManager.cardDark),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: ColorsManager.fabColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: ColorsManager.bottomAppBarDark,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    color: ColorsManager.Strock2Dark,
  ),
  iconTheme: const IconThemeData(color: ColorsManager.iconDark),
  primaryIconTheme: const IconThemeData(color: ColorsManager.iconDark),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: ColorsManager.TextColorDark),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColorsExtension(
      strock1: ColorsManager.Strock1Dark,
      strock2: ColorsManager.Strock2Dark,
    ),
  ],
);
