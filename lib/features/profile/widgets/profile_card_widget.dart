import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  const ProfileCard({
    super.key,
    required this.child,
    this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(Dimensions.w16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? Dimensions.r24),
        border: Border.all(color: cs.outline),
      ),
      child: child,
    );
  }
}