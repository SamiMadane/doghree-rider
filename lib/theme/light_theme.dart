import 'package:flutter/material.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/theme_extension.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: ManagerColors.primaryLight,
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
    primary: ManagerColors.primaryLight,
    secondary: ManagerColors.primaryLight,
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
