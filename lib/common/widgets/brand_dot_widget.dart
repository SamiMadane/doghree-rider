import 'package:doghree_rider/util/dimensions.dart';
import 'package:flutter/material.dart';

class BrandDot extends StatelessWidget {
  const BrandDot({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: Dimensions.w14,
      height: Dimensions.w14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryColor,
        border: Border.all(color: theme.colorScheme.onPrimary, width: 1),
      ),
    );
  }
}