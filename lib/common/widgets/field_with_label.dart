import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class WidgetWithLabel extends StatelessWidget {
  final String label;
  final Widget textField;

  const WidgetWithLabel({
    super.key,
    required this.label,
    required this.textField,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(
          label,
          style: robotoMedium,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        textField,
      ],
    );
  }
}
