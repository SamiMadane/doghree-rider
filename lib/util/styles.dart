import 'package:flutter/material.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';

TextStyle textRegular() => TextStyle(
      fontFamily: AppConstants.fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: Dimensions.fs14,
    );

TextStyle textMedium() => TextStyle(
      fontFamily: AppConstants.fontFamily,
      fontFamilyFallback: AppConstants.fontFallback,
      fontWeight: FontWeight.w500,
      fontSize: Dimensions.fs14,
    );

TextStyle textSemiBold() => TextStyle(
      fontFamily: AppConstants.fontFamily,
      fontFamilyFallback: AppConstants.fontFallback,
      fontWeight: FontWeight.w600,
      fontSize: Dimensions.fs14,
    );

TextStyle textBold() => TextStyle(
      fontFamily: AppConstants.fontFamily,
      fontFamilyFallback: AppConstants.fontFallback,
      fontWeight: FontWeight.w700,
      fontSize: Dimensions.fs14,
    );

TextStyle textDisplay() => TextStyle(
      fontFamily: 'Lemonada',
      fontFamilyFallback: AppConstants.fontFallback,
      fontWeight: FontWeight.w700,
      fontSize: Dimensions.fs24,
      height: 1.4,
    );
