import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color onTrack = isDark ? cs.primary : cs.onSurface;
    final Color onThumb = isDark ? cs.onPrimary : cs.primary;

    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (states) =>
            states.contains(WidgetState.selected) ? onThumb : theme.cardColor,
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (states) =>
            states.contains(WidgetState.selected) ? onTrack : cs.outline,
      ),
      trackOutlineColor:
          const WidgetStatePropertyAll<Color>(Colors.transparent),
    );
  }
}