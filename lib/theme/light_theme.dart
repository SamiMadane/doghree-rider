import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: ColorsManager.primary,
  secondaryHeaderColor: ColorsManager.secondary,
  disabledColor: ColorsManager.disabledLight,
  brightness: Brightness.light,
  hintColor: ColorsManager.hintLight,
  cardColor: ColorsManager.cardLight,
  shadowColor: ColorsManager.shadowLight,
  scaffoldBackgroundColor: ColorsManager.scaffoldBgLight,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ColorsManager.textButtonLight),
  ),
  colorScheme: const ColorScheme.light(
    primary: ColorsManager.primary,
    secondary: ColorsManager.primary,
  ).copyWith(error: ColorsManager.error),
  popupMenuTheme: const PopupMenuThemeData(
    color: ColorsManager.cardLight,
    surfaceTintColor: ColorsManager.cardLight,
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: ColorsManager.cardLight),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: ColorsManager.fabColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: ColorsManager.bottomAppBarLight,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    color: ColorsManager.Strock2Light,
  ),
  iconTheme: const IconThemeData(color: ColorsManager.iconLight),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: ColorsManager.TextColorLight),
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColorsExtension(
      strock1: ColorsManager.Strock1Light,
      strock2: ColorsManager.Strock2Light,
    ),
  ],
);
