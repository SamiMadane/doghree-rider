import 'package:flutter/material.dart';

class ManagerColors {
  // 🌟 Primary & Secondary Colors
  static const Color shimmer = Color(0xFFC2C2C2);

  // ⚪ Neutral / Base Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Orange family = brand "warning" (E8890C)
  static const Color orangeLightMode = Color(0xFFE8890C); // was 0xFFE28D00
  static const Color orangeDarkMode = Color(0xFFE8890C); // was 0xFFFFFfE5 (typo: near-white)
  static const Color orangeBgLightMode = Color(0x1FE8890C); // was 0x1FE28D00
  static const Color orangeBgDarkMode = Color(0x1FE8890C); // was 0x1FFFFFFF

  // NOTE: not part of the Doghri palette. Left as is: check usages and replace/remove.
  static const Color purple = Color(0xFFA456EC);

// Green Family (brand has a single green: success 19B36B)
  static const Color success = Color(0xFF19B36B);
  static const Color greenLightMode = Color(0xFF19B36B); // was 0xFF00AC3F
  static const Color greenDarkMode = Color(0xFF19B36B); // was 0xFF4ADE80
  static const Color greenBgLightMode = Color(0x3319B36B); // was 0x3300AC3F
  static const Color greenBgDarkMode = Color(0xFF1A2E1F);
  static const Color lightGreen = Color(0xFF19B36B); // was 0xFF2ABF61
  static const Color darkGreen = Color(0xFF19B36B); // was 0xFF388E3C
  static const Color oliveGreen = Color(0xFF19B36B); // was 0xFF70A43A
  static const Color greenCircle = Color(0xFFDCF4E9); // was 0xFFDCFBBB (15% success tint on white)

// Gray Family (neutral grays, no blue tint)
  static const Color grayLightMode = Color(0xFFDDDDDD); // was 0xFFDCE0E3
  static const Color grayDarkMode = Color(0xFF8C8C8C); // was 0xFF6B7280
  static const Color grayBgLightMode = Color(0xFFE9E9E9);
  static const Color grayBgDarkMode = Color(0xFF262626); // was 0xFF1F2937
  static const Color grayCirule = Color(0xFFA7A7A7);
  static const Color darkGray = Color(0xFF3A3A3A); // was 0xFF68707D (roadGrey)
  static const Color grayCiruleSelected = Color(0xFFCECECE);
  static const Color disabledButtonLightMode = Color(0x331B1B1B); // was 0xFFDEDFE3
  static const Color disabledButtonDarkMode = Color(0x4DFFC233); // was 0xFF374151

// Blue Family
  static const Color blueBgLightMode = Color(0xFFFFF1CC); // was 0x3306238D
  static const Color blueBgDarkMode = Color(0xFF3D341F); // was 0xFF0F1E3D
  static const Color darkBlueLightMode = Color(0xFF1B1B1B); // was 0xFF2B3E82
  static const Color blueLightMode = Color(0xFF8A5F00); // was 0xFF1E36A4
  static const Color darkBlueDarkMode = Color(0xFFFFFFFF); // was 0xFF93C5FD
  static const Color blueDarkMode = Color(0xFFFFC233); // was 0xFF60A5FA
  static const Color naturalBlueLightMode = Color(0xFF8A5F00); // was 0xFF2E68E5
  static const Color naturalBlueDarkMode = Color(0xFFFFC233); // was 0xFF60A5FA

// Red Family (brand danger: E5484D)
  static const Color redLightMode = Color(0xFFE5484D); // was 0xFFEF4444
  static const Color redDarkMode = Color(0xFFE5484D); // was 0xFFF87171
  static const Color redBgLightMode = Color(0x33E5484D); // was 0x33EF4444
  static const Color redBgDarkMode = Color(0xFF2D1515);

  static const Color red = Color(0xFFE5484D); // was 0xFFE64849
  static const Color redCircle = Color(0xFFFFD9D7);

  // new: text/icons on yellow
  static const Color onPrimary = Color(0xFF1B1B1B);

  static const Color primaryLight = Color(0xFFFFC233); // was 0xFF0146C7
  static const Color primaryBgLight = Color(0xFFFFF1CC); // was 0x330146C7

  static const Color primaryDark = Color(0xFFFFC233); // was 0xFF4A90E2
  static const Color primaryBgDark = Color(0xFF3D341F); // was 0x334A90E2

  static const Color scaffoldBgLight = Color(0xFFF9F7F3);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color disabledLight = Color(0x613A3A3A); // was 0xFF6C7278
  static const Color Strock1Light = Color(0xFFA8A8A8);
  static const Color Strock2Light = Color(0x403A3A3A); // was 0xFFD0D0D0
  static const Color hintLight = Color(0xFF3A3A3A); // was 0xFF6C7278 (roadGrey)
  static const Color shadowLight = Color(0x13000000);
  static const Color iconLight = Color(0xFF1B1B1B); // was 0xFF292D32
  static const Color TextColorLight = Color(0xFF1B1B1B); // was 0xFF2B3141
  static const Color senderMessageBgLight = Color(0xFFF8F8F8);
  static const Color receiverMessageBgLight = Color(0xFF1B1B1B); // was 0xFF2B3141
  static const Color bottomAppBarLight = Colors.white;

  // 🌚 Dark Theme Colors
  static const Color scaffoldBgDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1B1B1B);
  static const Color disabledDark = Color(0x61FFFFFF); // was 0xFFF0F0F0
  static const Color Strock1Dark = Color(0xFF6B6B6B);
  static const Color Strock2Dark = Color(0x33FFFFFF); // was 0xFF3A3A3A
  static const Color hintDark = Color(0xB3FFFFFF); // was 0xFFBEBEBE
  static const Color shadowDark = Color(0x1FFFFFFF);
  static const Color TextColorDark = Color(0xFFFFFFFF);
  static const Color senderMessageBgDark = Color(0x33FFFFFF);
  static const Color receiverMessageBgDark = Color(0xFF1E1E1E);

  static const Color iconDark = Colors.white;
  static const Color bottomAppBarDark = Color(0xFF1B1B1B);

  // 🎯 Status Colors
  static const Color warning = Color(0xFFE8890C); // was 0xFFFFC107
  static const Color error = Color(0xFFE5484D); // was 0xFFF44336

  // 🔹 Additional Colors (optional, used in UI components)
  static const Color fabColor = primaryLight;
  static const Color textButtonLight = Color(
      0xFF8A5F00); // was primaryLight (yellow text on white is unreadable)
  static const Color textButtonDark = Color(0xFFFFC233); // was 0xFF54B46B
}