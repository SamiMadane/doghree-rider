import 'package:flutter/material.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';

/// Money text that counts up when it first appears or when the value changes.
class AnimatedAmountText extends StatelessWidget {
  final double value;
  final TextStyle style;

  const AnimatedAmountText({super.key, required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) =>
          Text(PriceConverterHelper.convertPrice(v), style: style),
    );
  }
}