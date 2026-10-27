import 'dart:math' as math;

import 'package:doghree_rider/util/manager_assets.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/util/manager_colors.dart';

/// An order seen by the radar: direction (degrees, 0 = right, 90 = down)
/// and distance from the target, in design-frame units.
class _Order {
  const _Order(this.angleDeg, this.radius);
  final double angleDeg;
  final double radius;
}

/// Geometry of the splash mark inside its 960x960 design frame.
/// Tune these if the overlay doesn't sit exactly on your PNG
/// (turn on debugGeometry to see them).
class _Geo {
  static const double frame = 960;
  // Road centerline: top of the diagonal -> corner -> left end of the bar.
  static const List<Offset> road = <Offset>[
    Offset(488, 330),
    Offset(684, 593),
    Offset(440, 593),
  ];
  static const Offset wheel = Offset(288, 597);
  static const double wheelOuterR = 80;
  static const double dotR = 28;
  static const double courierR = 24;

  /// Radius of the radar sweep.
  static const double radarR = 900;

  /// Decoy orders around the target. They stay clear of the mark itself.
  /// (The "found" order is the top of the road, which is on the mark.)
  static const List<_Order> orders = <_Order>[
    _Order(-150, 330),
    _Order(-95, 520),
    _Order(-30, 650),
    _Order(35, 400),
    _Order(110, 300),
    _Order(160, 420),
  ];
}

class DoghreeSplashAnimation extends StatefulWidget {
  const DoghreeSplashAnimation({
    super.key,
    required this.isLoading,
    this.onFinished,
    this.frameSize = 240,
    this.cycleDuration = const Duration(milliseconds: 3600),
    this.markLightAsset = ManagerAssets.splashAnimLight,
    this.markDarkAsset = ManagerAssets.splashanimDark,
    this.logoLightAsset = ManagerAssets.logoDoghreeLight,
    this.logoDarkAsset = ManagerAssets.logoDoghreeDark,
    this.debugGeometry = false,
  });

  /// true while config/bootstrap is loading.
  final bool isLoading;

  /// Called after loading finished and the reveal ended.
  final VoidCallback? onFinished;

  /// On-screen size (dp) of the 960x960 design frame. Tune it until the mark
  /// matches the native splash exactly (240 = a 960px image treated as 4x).
  final double frameSize;

  /// Duration of one full cycle (radar sweep + lock + ride + arrival).
  /// The splash lasts at least one cycle. Lower = faster.
  final Duration cycleDuration;

  /// Transparent 960x960 PNGs: the mark only, same frame as the native splash.
  final String markLightAsset;
  final String markDarkAsset;

  /// Final logo shown after loading. Pass null for both to skip the reveal.
  final String? logoLightAsset;
  final String? logoDarkAsset;

  /// Draws the geometry in red over the mark, to calibrate.
  final bool debugGeometry;

  @override
  State<DoghreeSplashAnimation> createState() => _DoghreeSplashAnimationState();
}

class _DoghreeSplashAnimationState extends State<DoghreeSplashAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _cycle =
      AnimationController(vsync: this, duration: widget.cycleDuration);
  late final AnimationController _reveal = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 450));

  bool get _hasLogo =>
      widget.logoLightAsset != null && widget.logoDarkAsset != null;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Repeat the cycle until loading is done, always finishing a full cycle
    // so the courier arrives before the reveal.
    while (mounted) {
      await _cycle.forward(from: 0);
      if (!mounted) return;
      if (!widget.isLoading) break;
    }
    if (!mounted) return;
    if (_hasLogo) await _reveal.forward();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) widget.onFinished?.call();
  }

  @override
  void dispose() {
    _cycle.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg =
        isDark ? ManagerColors.onPrimary : ManagerColors.primaryLight;
    final Color road =
        isDark ? ManagerColors.primaryLight : ManagerColors.onPrimary;
    final String? logo = isDark ? widget.logoDarkAsset : widget.logoLightAsset;
    final double logoW =
        (MediaQuery.of(context).size.width * 0.7).clamp(220.0, 320.0);

    return ColoredBox(
      color: bg,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_cycle, _reveal]),
          builder: (BuildContext context, Widget? _) {
            final double r = Curves.easeOut.transform(_reveal.value);
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                Opacity(
                  opacity: 1 - r,
                  child: Transform.scale(
                    scale: 1 - 0.35 * r,
                    child: SizedBox.square(
                      dimension: widget.frameSize,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Image.asset(
                            isDark
                                ? widget.markDarkAsset
                                : widget.markLightAsset,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                          CustomPaint(
                            painter: _RadarRidePainter(
                              t: _cycle.value,
                              road: road,
                              lane: bg,
                              debug: widget.debugGeometry,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (logo != null)
                  Opacity(
                    opacity: r,
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * r,
                      child: Image.asset(logo, width: logoW),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Overlay on top of the mark PNG. Four clearly different beats:
///  1) radar sweep (rotation) that lights up nearby orders
///  2) lock-on reticle (shrinks inward) on the order at the top of the road
///  3) courier ride with squash & stretch
///  4) arrival: rings expanding outward + dot pulse (only moment with rings)
/// t = 0 and t = 1 both look exactly like the static mark (seamless loop).
class _RadarRidePainter extends CustomPainter {
  _RadarRidePainter({
    required this.t,
    required this.road,
    required this.lane,
    required this.debug,
  });

  final double t; // 0..1 within one cycle
  final Color road; // mark color (asphalt on light, yellow on dark)
  final Color lane; // background color
  final bool debug;

  // Timeline (fractions of one cycle)
  static const double _radarStart = 0.02;
  static const double _radarEnd = 0.32; // beam lands on the order
  static const double _foundAt = 0.38; // courier pops
  static const double _launchAt = 0.46; // courier leaves
  static const double _rideEnd = 0.68; // end of the road
  static const double _hopEnd = 0.78; // enters the target

  static double _seg(double v, double a, double b,
          [Curve curve = Curves.linear]) =>
      curve.transform(((v - a) / (b - a)).clamp(0.0, 1.0));

  static double _slope(double x, Curve c) {
    const double e = 0.01;
    final double a = c.transform((x - e).clamp(0.0, 1.0));
    final double b = c.transform((x + e).clamp(0.0, 1.0));
    return (b - a) / (2 * e);
  }

  static Offset _along(double f) {
    final List<Offset> p = _Geo.road;
    final double l1 = (p[1] - p[0]).distance;
    final double l2 = (p[2] - p[1]).distance;
    final double d = f * (l1 + l2);
    if (d <= l1) return Offset.lerp(p[0], p[1], d / l1)!;
    return Offset.lerp(p[1], p[2], (d - l1) / l2)!;
  }

  static double _angleAlong(double f) {
    final Offset a = _along((f - 0.01).clamp(0.0, 1.0));
    final Offset b = _along((f + 0.01).clamp(0.0, 1.0));
    return math.atan2(b.dy - a.dy, b.dx - a.dx);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _Geo.frame);

    _paintRadar(canvas);
    _paintLockOn(canvas);
    _paintArrival(canvas);
    _paintCourier(canvas);
    if (debug) _paintDebug(canvas);

    canvas.restore();
  }

  // 1) Radar: a rotating beam with a fading wedge; orders light up as it
  //    passes. It does one full turn and stops exactly on the road top.
  void _paintRadar(Canvas canvas) {
    final double vis = _seg(t, _radarStart, _radarStart + 0.04) *
        (1 - _seg(t, _radarEnd, _radarEnd + 0.06));
    if (vis <= 0.003) return;

    final Offset c = _Geo.wheel;
    final Offset top = _Geo.road.first;
    final double thetaEnd = math.atan2(top.dy - c.dy, top.dx - c.dx);
    final double thetaStart = thetaEnd - 2 * math.pi;
    final double swept =
        2 * math.pi * _seg(t, _radarStart, _radarEnd, Curves.easeInOut);
    final double theta = thetaStart + swept;

    // Faint static range rings (they don't move, so they read as a scope)
    for (final double r in <double>[330, 640]) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = road.withValues(alpha: 0.12 * vis),
      );
    }

    // Trailing wedge behind the beam
    final Rect rect = Rect.fromCircle(center: c, radius: _Geo.radarR);
    canvas.drawArc(
      rect,
      theta - math.pi / 2,
      math.pi / 2,
      true,
      Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi / 2,
          colors: <Color>[
            road.withValues(alpha: 0),
            road.withValues(alpha: 0.34 * vis),
          ],
          transform: GradientRotation(theta - math.pi / 2),
        ).createShader(rect),
    );

    // The beam
    final Offset dir = Offset(math.cos(theta), math.sin(theta));
    canvas.drawLine(
      c + dir * (_Geo.wheelOuterR + 8),
      c + dir * _Geo.radarR,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = road.withValues(alpha: 0.55 * vis),
    );

    // Orders: light up when the beam passes, then slowly fade
    for (final _Order o in _Geo.orders) {
      final double a = o.angleDeg * math.pi / 180;
      final double ang0 = (a - thetaStart) % (2 * math.pi);
      if (swept < ang0) continue;
      final double age =
          ((swept - ang0) / (2 * math.pi)).clamp(0.0, 1.0);
      final double lit = math.pow(1 - age, 1.4).toDouble() * vis;
      final double hit = (age / 0.10).clamp(0.0, 1.0);
      final Offset p = c + Offset(math.cos(a), math.sin(a)) * o.radius;
      canvas.drawCircle(
        p,
        15 * Curves.easeOutBack.transform(hit),
        Paint()..color = road.withValues(alpha: (0.7 * lit).clamp(0.0, 1.0)),
      );
      if (hit < 1) {
        canvas.drawCircle(
          p,
          15 + 30 * hit,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color =
                road.withValues(alpha: ((1 - hit) * 0.5 * vis).clamp(0.0, 1.0)),
        );
      }
    }
  }

  // 2) Lock-on: a reticle that SHRINKS onto the order (inward, unlike rings)
  void _paintLockOn(Canvas canvas) {
    final double p =
        _seg(t, _radarEnd, _foundAt + 0.04, Curves.easeOutCubic);
    final double alpha = _seg(t, _radarEnd, _radarEnd + 0.04) *
        (1 - _seg(t, _launchAt - 0.02, _launchAt + 0.04));
    if (p <= 0 || alpha <= 0.003) return;

    final Offset top = _Geo.road.first;
    final double radius = 96 - 60 * p; // ends around the courier
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = road.withValues(alpha: (0.75 * alpha).clamp(0.0, 1.0));

    canvas.drawCircle(top, radius, paint);
    for (int i = 0; i < 4; i++) {
      final double a = i * math.pi / 2;
      final Offset d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(top + d * (radius + 4), top + d * (radius + 18), paint);
    }
  }

  // 4) Arrival: rings expanding outward + dot pulse
  void _paintArrival(Canvas canvas) {
    for (final double start in <double>[_hopEnd, _hopEnd + 0.06]) {
      final double p = _seg(t, start, 1.0, Curves.easeOut);
      if (p > 0 && p < 1) {
        canvas.drawCircle(
          _Geo.wheel,
          _Geo.wheelOuterR + 4 + p * 150,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7 * (1 - p) + 2
            ..color = road.withValues(alpha: (1 - p) * 0.5),
        );
      }
    }
    final double pulse = math.sin(math.pi * _seg(t, _hopEnd, _hopEnd + 0.16));
    if (pulse > 0.01) {
      canvas.drawCircle(
        _Geo.wheel,
        _Geo.dotR - 2 + 11 * pulse,
        Paint()..color = road,
      );
    }
  }

  // 3) Courier with squash & stretch
  void _paintCourier(Canvas canvas) {
    final double pop =
        Curves.easeOutBack.transform(_seg(t, _foundAt, _foundAt + 0.05));
    final double vanish =
        1 - _seg(t, _hopEnd - 0.02, _hopEnd + 0.04, Curves.easeIn);
    final double cs = pop * vanish;
    if (cs <= 0.01) return;

    Offset pos;
    double angle;
    double sx = 1;
    double sy = 1;

    if (t < _launchAt) {
      // Waiting at the top, then a small crouch before launch
      pos = _Geo.road.first;
      angle = _angleAlong(0);
      final double w = _seg(t, _launchAt - 0.04, _launchAt, Curves.easeIn);
      sx = 1 - 0.15 * w;
      sy = 1 + 0.12 * w;
    } else if (t < _rideEnd) {
      // Ride along the road: stretch with speed
      final double x = _seg(t, _launchAt, _rideEnd);
      final double f = Curves.easeInOutCubic.transform(x);
      final double k = (_slope(x, Curves.easeInOutCubic) / 3).clamp(0.0, 1.0);
      pos = _along(f);
      angle = _angleAlong(f);
      sx = 1 + 0.45 * k;
      sy = 1 - 0.20 * k;
    } else {
      // Hop from the end of the road into the target
      final double x = _seg(t, _rideEnd, _hopEnd);
      final double f = Curves.easeInOut.transform(x);
      final double k = (_slope(x, Curves.easeInOut) / 2.2).clamp(0.0, 1.0);
      pos = Offset.lerp(_Geo.road.last, _Geo.wheel, f)!;
      angle = math.pi; // moving left
      sx = 1 + 0.40 * k;
      sy = 1 - 0.18 * k;
    }

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    canvas.scale(sx * cs, sy * cs);
    canvas.drawCircle(Offset.zero, _Geo.courierR, Paint()..color = lane);
    canvas.drawCircle(
      Offset.zero,
      _Geo.courierR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = road,
    );
    canvas.drawCircle(Offset.zero, 8, Paint()..color = road);
    canvas.restore();
  }

  void _paintDebug(Canvas canvas) {
    final Paint d = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.red;
    final Path path = Path()..moveTo(_Geo.road[0].dx, _Geo.road[0].dy);
    for (final Offset o in _Geo.road.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(path, d);
    canvas.drawCircle(_Geo.wheel, _Geo.wheelOuterR, d);
    canvas.drawCircle(_Geo.wheel, _Geo.dotR, d);
    for (final _Order o in _Geo.orders) {
      final double a = o.angleDeg * math.pi / 180;
      canvas.drawCircle(
        _Geo.wheel + Offset(math.cos(a), math.sin(a)) * o.radius,
        15,
        d,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarRidePainter old) =>
      old.t != t ||
      old.road != road ||
      old.lane != lane ||
      old.debug != debug;
}