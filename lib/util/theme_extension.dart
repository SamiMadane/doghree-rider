import 'package:flutter/material.dart';

@immutable
class CustomColorsExtension extends ThemeExtension<CustomColorsExtension> {
  final Color strock1;
  final Color strock2;

  const CustomColorsExtension({
    required this.strock1,
    required this.strock2,
  });

  @override
  CustomColorsExtension copyWith({
    Color? stroke1,
    Color? stroke2,
  }) {
    return CustomColorsExtension(
      strock1: stroke1 ?? this.strock1,
      strock2: stroke2 ?? this.strock2,
    );
  }

  @override
  CustomColorsExtension lerp(
      ThemeExtension<CustomColorsExtension>? other, double t) {
    if (other is! CustomColorsExtension) return this;
    return CustomColorsExtension(
      strock1: Color.lerp(strock1, other.strock1, t)!,
      strock2: Color.lerp(strock2, other.strock2, t)!,
    );
  }
}
