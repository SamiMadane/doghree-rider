import 'package:flutter/material.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';

/// Two-step progress bar drawn as a road.
/// Light mode: asphalt road with yellow lane dashes.
/// Dark mode: yellow road with asphalt lane dashes.
/// Steps not reached yet are a faded road without dashes.
class StepProgressBar extends StatefulWidget {
  final double status;
  final bool showDivider;

  /// Overrides the road color (the dashes pick a contrasting brand color).
  final Color? color;

  /// Lane dashes run along the last reached step (use while it is in progress).
  final bool animated;

  /// Road thickness. 10 keeps the dashes visible.
  final double height;

  const StepProgressBar({
    super.key,
    required this.status,
    this.showDivider = true,
    this.color,
    this.animated = false,
    this.height = 12,
  });

  @override
  State<StepProgressBar> createState() => _StepProgressBarState();
}

class _StepProgressBarState extends State<StepProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant StepProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.animated) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    final Color road = widget.color ??
        (isDark ? ManagerColors.primaryDark : ManagerColors.onPrimary);
    final Color dash = widget.color != null
        ? (ThemeData.estimateBrightnessForColor(road) == Brightness.dark
            ? ManagerColors.primaryLight
            : ManagerColors.onPrimary)
        : (isDark ? ManagerColors.onPrimary : ManagerColors.primaryLight);

    // status == 0.4: only the first step is reached. Otherwise both are.
    final bool firstOnly = widget.status == 0.4;
    final bool secondReached = !firstOnly;

    Widget segment({required bool reached, required bool runs}) {
      return Expanded(
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(
            painter: _RoadPainter(
              road: reached ? road : road.withAlpha(46),
              dash: dash,
              showDashes: reached,
              direction: rtl ? -1 : 1,
              animation: runs ? _controller : null,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Row(
            children: [
              segment(reached: true, runs: widget.animated && firstOnly),
              SizedBox(width: Dimensions.w10),
              segment(
                reached: secondReached,
                runs: widget.animated && secondReached,
              ),
            ],
          ),
        ),
        if (widget.showDivider) ...[
          SizedBox(height: Dimensions.h10),
          const Divider(),
        ]
      ],
    );
  }
}

class _RoadPainter extends CustomPainter {
  _RoadPainter({
    required this.road,
    required this.dash,
    required this.showDashes,
    required this.direction,
    this.animation,
  }) : super(repaint: animation);

  final Color road;
  final Color dash;
  final bool showDashes;
  final double direction; // 1 = left to right, -1 = right to left
  final Animation<double>? animation;

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final RRect body =
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(h / 2));
    canvas.drawRRect(body, Paint()..color = road);
    if (!showDashes) return;

    final double dashW = h * 1.6;
    final double gap = h * 1.5;
    final double period = dashW + gap;
    final double dashH = h * 0.26;
    final double inset = h * 0.9; // keep dashes away from the rounded ends
    if (size.width <= inset * 2) return;

    final double t = animation?.value ?? 0;
    final double shift = (t * period * direction) % period;

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(inset, 0, size.width - inset, h));
    final Paint paint = Paint()..color = dash;
    for (double x = inset - period + shift; x < size.width; x += period) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, (h - dashH) / 2, dashW, dashH),
          Radius.circular(dashH / 2),
        ),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) =>
      old.road != road ||
      old.dash != dash ||
      old.showDashes != showDashes ||
      old.direction != direction ||
      old.animation != animation;
}