import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:vibration/vibration.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class SliderButton extends StatefulWidget {
  final Widget? child;

  final double radius;
  final double height;
  final double width;
  final double buttonSize;

  /// null = من الثيم
  final Color? backgroundColor;
  final Color? buttonColor;
  final BoxShadow? boxShadow;
  final Widget? icon;

  final Object? label;
  final Alignment alignLabel;
  final Function action;

  final bool shimmer;
  final bool vibrationFlag;
  final bool disable;
  final bool isLtr;

  /// غير مستخدمين حالياً (محفوظين عشان ما ينكسر أي استدعاء قديم)
  final bool dismissible;
  final double dismissThresholds;

  const SliderButton({
    super.key,
    required this.action,
    this.radius = 100,
    this.boxShadow,
    this.child,
    this.isLtr = true,
    this.vibrationFlag = true,
    this.shimmer = true,
    this.height = 70,
    this.buttonSize = 60,
    this.width = 250,
    this.alignLabel = const Alignment(0.0, 0),
    this.backgroundColor,
    this.buttonColor,
    this.label,
    this.icon,
    this.dismissible = true,
    this.dismissThresholds = 1.0,
    this.disable = false,
  }) : assert(buttonSize <= height);

  @override
  SliderButtonState createState() => SliderButtonState();
}

class SliderButtonState extends State<SliderButton> {
  Key _dismissibleKey = UniqueKey();

  Widget _buildLabel(BuildContext context) {
    final Object? label = widget.label;
    if (label is Widget) return label;
    if (label is String) {
      return Text(
        label,
        style: textMedium().copyWith(
          fontSize: Dimensions.fs16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }
    return const SizedBox();
  }

  void _resetButton() {
    if (!mounted) return;
    setState(() => _dismissibleKey = UniqueKey());
  }

  Widget _buildKnob(ThemeData theme, Color knobColor, Widget icon) {
    final ColorScheme cs = theme.colorScheme;
    return Container(
      width: widget.width - widget.height,
      height: widget.height,
      alignment: widget.isLtr ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.only(left: (widget.height - widget.buttonSize) / 2),
      child: widget.child ??
          Container(
            height: widget.buttonSize,
            width: widget.buttonSize,
            decoration: BoxDecoration(
              boxShadow: [
                widget.boxShadow ??
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.2),
                      blurRadius: Dimensions.r4,
                    ),
              ],
              color: knobColor,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            child: Center(child: icon),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    // المسار والزر: من الثيم (معتم، عشان لمعة النص تذوب فيه)
    final Color trackColor = widget.disable
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.18), theme.cardColor)
        : widget.backgroundColor ??
            Color.alphaBlend(
                cs.onSurface.withValues(alpha: 0.08), theme.cardColor);
    final Color knobColor = widget.disable
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.30), theme.cardColor)
        : widget.buttonColor ?? cs.primary;
    final Widget icon = widget.icon ??
        Icon(
          Icons.double_arrow_rounded,
          color: cs.onPrimary,
          size: Dimensions.w20,
        );

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      alignment: Alignment.centerLeft,
      child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
        Container(
          alignment: widget.alignLabel,
          child: widget.shimmer && !widget.disable
              // اللمعة بلون المسار: النص بيخفت وهو بيعبر الضوء، فاتح وداكن
              ? Shimmer(
                  color: trackColor,
                  colorOpacity: 0.75,
                  child: _buildLabel(context),
                )
              : _buildLabel(context),
        ),
        widget.disable
            ? Tooltip(
                verticalOffset: 50,
                message: 'Button is disabled',
                child: _buildKnob(theme, knobColor, icon),
              )
            : Directionality(
                textDirection: TextDirection.ltr, // فرض LTR دائماً
                child: Dismissible(
                  key: _dismissibleKey,
                  direction: DismissDirection.startToEnd,
                  movementDuration: const Duration(milliseconds: 300),
                  confirmDismiss: (direction) async {
                    widget.action();

                    if (widget.vibrationFlag &&
                        await Vibration.hasVibrator() == true) {
                      Vibration.vibrate(duration: 200);
                    }

                    Future.delayed(
                        const Duration(milliseconds: 100), _resetButton);

                    return false;
                  },
                  child: _buildKnob(theme, knobColor, icon),
                ),
              ),
        const SizedBox.expand(),
      ]),
    );
  }
}