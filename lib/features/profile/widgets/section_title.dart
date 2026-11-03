import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h12),
      child: Text(
        text,
        style: textBold().copyWith(
          fontSize: Dimensions.fs18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}