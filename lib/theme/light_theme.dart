import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/manager_colors.dart';
import 'package:sixam_mart_delivery/util/theme_extension.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: ManagerColors.primary,
  secondaryHeaderColor: ManagerColors.secondary,
  disabledColor: ManagerColors.disabledLight,
  brightness: Brightness.light,
  hintColor: ManagerColors.hintLight,
  cardColor: ManagerColors.cardLight,
  shadowColor: ManagerColors.shadowLight,
  scaffoldBackgroundColor: ManagerColors.scaffoldBgLight,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ManagerColors.textButtonLight),
  ),
  colorScheme: const ColorScheme.light(
    primary: ManagerColors.primary,
    secondary: ManagerColors.primary,
  ).copyWith(error: ManagerColors.error),
  popupMenuTheme: const PopupMenuThemeData(
    color: ManagerColors.cardLight,
    surfaceTintColor: ManagerColors.cardLight,
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: ManagerColors.cardLight),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: ManagerColors.fabColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: ManagerColors.bottomAppBarLight,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
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
      receiverMessageBg: ManagerColors.receiverMessageBgLight
    ),
  ],
);
