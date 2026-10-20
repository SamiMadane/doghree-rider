import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

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
          style: textMedium(),
        ),
        SizedBox(height: Dimensions.h10),
        textField,
      ],
    );
  }
}
