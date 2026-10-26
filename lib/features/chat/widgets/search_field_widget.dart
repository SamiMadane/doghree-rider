import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget suffixIcon;
  final Function iconPressed;
  final Function? onSubmit;
  final Function? onChanged;
  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.hint,
    required this.suffixIcon,
    required this.iconPressed,
    this.onSubmit,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.r20),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: textRegular().copyWith(
        fontSize: Dimensions.fs14,
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textMedium().copyWith(
          fontSize: Dimensions.fs14,
          color: cs.onSurfaceVariant,
        ),
        filled: true,
        fillColor: theme.cardColor,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimensions.w16,
          vertical: Dimensions.h10,
        ),
        border: border(cs.outline),
        enabledBorder: border(cs.outline),
        focusedBorder: border(isDark ? cs.primary : cs.onSurface, 1.6),
        suffixIcon: IconButton(
          onPressed: iconPressed as void Function()?,
          icon: suffixIcon,
        ),
      ),
      onSubmitted: onSubmit as void Function(String)?,
      onChanged: onChanged as void Function(String)?,
    );
  }
}