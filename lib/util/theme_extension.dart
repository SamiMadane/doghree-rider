import 'package:flutter/material.dart';

@immutable
class CustomColorsExtension extends ThemeExtension<CustomColorsExtension> {
  final Color strock1;
  final Color strock2;
  final Color senderMessageBg;
  final Color receiverMessageBg;
  final Color grayBg;
  final Color primaryBg;
  final Color blueBg;
  final Color naturalBlue;
  final Color darkBlue;
  final Color blue;
  final Color gray;
  final Color green;
  final Color greenBg;
  final Color disabledButton;
  final Color orangeBg;
  final Color orange;

  

  const CustomColorsExtension({
    required this.strock1,
    required this.strock2,
    required this.senderMessageBg,
    required this.receiverMessageBg,
    required this.grayBg,
    required this.primaryBg,
    required this.blueBg,
    required this.naturalBlue,
    required this.darkBlue,
    required this.blue,
    required this.gray,
    required this.green,
    required this.greenBg,
    required this.disabledButton,
    required this.orangeBg,
    required this.orange,
    
  });

  @override
  CustomColorsExtension copyWith({
    Color? stroke1,
    Color? stroke2,
    Color? senderMessageBg,
    Color? receiverMessageBg,
    Color? grayBg,
    Color? primaryBg,
    Color? blueBg,
    Color? naturalBlue,
    Color? darkBlue,
    Color? blue,
    Color? gray,
    Color? green,
    Color? greenBg,
    Color? disabledButton,
    Color? orangeBg,
    Color? orange,
  }) {
    return CustomColorsExtension(
      strock1: stroke1 ?? this.strock1,
      strock2: stroke2 ?? this.strock2,
      senderMessageBg: senderMessageBg ?? this.senderMessageBg,
      receiverMessageBg: receiverMessageBg ?? this.receiverMessageBg,
      grayBg: grayBg ?? this.grayBg,
      primaryBg: primaryBg ?? this.primaryBg,
      blueBg: blueBg ?? this.blueBg,
      naturalBlue: naturalBlue ?? this.naturalBlue,
      darkBlue: darkBlue ?? this.darkBlue,
      blue: blue ?? this.blue,
      gray: gray ?? this.gray,
      green: green ?? this.green,
      greenBg: greenBg ?? this.greenBg,
      disabledButton: disabledButton ?? this.disabledButton,
      orangeBg: orangeBg ?? this.orangeBg,
      orange: orange ?? this.orange,
    );
  }

  @override
  CustomColorsExtension lerp(
      ThemeExtension<CustomColorsExtension>? other, double t) {
    if (other is! CustomColorsExtension) return this;
    return CustomColorsExtension(
      strock1: Color.lerp(strock1, other.strock1, t)!,
      strock2: Color.lerp(strock2, other.strock2, t)!,
      senderMessageBg: Color.lerp(senderMessageBg, other.senderMessageBg, t)!,
      receiverMessageBg: Color.lerp(receiverMessageBg, other.receiverMessageBg, t)!,
      grayBg: Color.lerp(grayBg, other.grayBg, t)!,
      primaryBg: Color.lerp(primaryBg, other.primaryBg, t)!,
      blueBg: Color.lerp(blueBg, other.blueBg, t)!,
      naturalBlue: Color.lerp(naturalBlue, other.naturalBlue, t)!,
      darkBlue: Color.lerp(darkBlue, other.darkBlue, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      gray: Color.lerp(gray, other.gray, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenBg: Color.lerp(greenBg, other.greenBg, t)!,
      disabledButton: Color.lerp(disabledButton, other.disabledButton, t)!,
      orangeBg: Color.lerp(orangeBg, other.orangeBg, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
    );
  }
}
