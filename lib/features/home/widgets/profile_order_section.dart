import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';

const double _kTopHeight = 128; // tear line sits at this height
const double _kBottomHeight = 92;
const double _kNotch = 11;
const double _kRadius = 22;

class ProfileOrdersSection extends StatelessWidget {
  final ProfileController profileController;
  const ProfileOrdersSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final model = profileController.profileModel;

    return Container(
      margin: EdgeInsets.only(top: Dimensions.h20),
      child: CustomPaint(
        foregroundPainter: _TicketBorderPainter(
          border: scheme.outline,
          tear: scheme.outline,
        ),
        child: ClipPath(
          clipper: const _TicketClipper(),
          child: Container(
            color: theme.cardColor,
            height: _kTopHeight + _kBottomHeight,
            child: Column(
              children: [
                SizedBox(
                  height: _kTopHeight,
                  child: _TicketTop(
                    value: model?.orderCount.toString(),
                    label: 'total_orders'.tr,
                  ),
                ),
                SizedBox(
                  height: _kBottomHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: _StubCell(
                          label: 'todays_orders'.tr,
                          value: model?.todaysOrderCount.toString(),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        indent: 22,
                        endIndent: 22,
                        color: scheme.outline,
                      ),
                      Expanded(
                        child: _StubCell(
                          label: 'weeks_orders'.tr,
                          value: model?.thisWeekOrderCount.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ───────────── Top part: total + target watermark ─────────────
class _TicketTop extends StatelessWidget {
  final String? value;
  final String label;
  const _TicketTop({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Stack(
      children: [
        // Target watermark on the end side (left in RTL), cropped by the card.
        PositionedDirectional(
          end: -34,
          top: -8,
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _TargetWatermarkPainter(
              base: scheme.onSurface,
              ring: theme.primaryColor,
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Mini target: the only touch of yellow.
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor,
                        border: Border.all(color: scheme.onSurface, width: 2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _CountText(value: value, fontSize: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ───────────── Bottom stub cell ─────────────
class _StubCell extends StatelessWidget {
  final String label;
  final String? value;
  const _StubCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          _CountText(value: value, fontSize: 28),
        ],
      ),
    );
  }
}

/// ───────────── Animated number ─────────────
class _CountText extends StatelessWidget {
  final String? value;
  final double fontSize;
  const _CountText({required this.value, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final style = TextStyle(
      fontSize: fontSize,
      height: 1.15,
      fontWeight: FontWeight.w800,
      color: color,
    );

    if (value == null) {
      return Shimmer(
        duration: const Duration(seconds: 2),
        color: Colors.grey[500]!,
        child: Container(
          height: fontSize,
          width: fontSize * 1.2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    final target = int.tryParse(value!);
    if (target == null) return Text(value!, style: style);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(v.round().toString(), style: style),
    );
  }
}

/// ───────────── Ticket shape ─────────────
Path _ticketPath(Size size) {
  final body = Path()
    ..addRRect(RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_kRadius),
    ));
  final notches = Path()
    ..addOval(Rect.fromCircle(
        center: Offset(0, _kTopHeight), radius: _kNotch))
    ..addOval(Rect.fromCircle(
        center: Offset(size.width, _kTopHeight), radius: _kNotch));
  return Path.combine(PathOperation.difference, body, notches);
}

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();
  @override
  Path getClip(Size size) => _ticketPath(size);
  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _TicketBorderPainter extends CustomPainter {
  final Color border;
  final Color tear;
  _TicketBorderPainter({required this.border, required this.tear});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _ticketPath(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = border,
    );

    // Tear line.
    final dash = Paint()
      ..color = tear
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    double x = _kNotch + 8;
    final end = size.width - _kNotch - 8;
    while (x < end) {
      canvas.drawLine(
        Offset(x, _kTopHeight),
        Offset(math.min(x + 6, end), _kTopHeight),
        dash,
      );
      x += 11;
    }
  }

  @override
  bool shouldRepaint(_TicketBorderPainter o) =>
      o.border != border || o.tear != tear;
}

/// ───────────── Target watermark (the logo's wheel, very light) ─────────────
class _TargetWatermarkPainter extends CustomPainter {
  final Color base; // outer ring + center dot
  final Color ring; // yellow ring
  _TargetWatermarkPainter({required this.base, required this.ring});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2;
    Path circle(double rad) =>
        Path()..addOval(Rect.fromCircle(center: c, radius: rad));

    // Same proportions as the logo wheel: ring edge at 65%, dot at 35%.
    final Path outer =
        Path.combine(PathOperation.difference, circle(r), circle(r * 0.65));
    final Path mid = Path.combine(
        PathOperation.difference, circle(r * 0.65), circle(r * 0.35));
    final Path dot = circle(r * 0.35);

    canvas.drawPath(outer, Paint()..color = base.withValues(alpha: 0.05));
    canvas.drawPath(mid, Paint()..color = ring.withValues(alpha: 0.20));
    canvas.drawPath(dot, Paint()..color = base.withValues(alpha: 0.05));
  }

  @override
  bool shouldRepaint(_TargetWatermarkPainter o) =>
      o.base != base || o.ring != ring;
}