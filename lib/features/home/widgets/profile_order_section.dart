import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/app_shimmer.dart';
import 'package:doghree_rider/common/widgets/dashed_line_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

// سماكة خط فقط، خليتها ثابتة عشان تضل واضحة
const double _kTearThickness = 2;

class ProfileOrdersSection extends StatelessWidget {
  final ProfileController profileController;
  const ProfileOrdersSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final model = profileController.profileModel;

    final double topHeight = Dimensions.h128;
    final double bottomHeight = Dimensions.h92;
    final double notch = Dimensions.r11;
    final double radius = Dimensions.r22;

    return Container(
      margin: EdgeInsets.only(top: Dimensions.h20),
      child: CustomPaint(
        foregroundPainter: _TicketBorderPainter(
          border: scheme.outline,
          topHeight: topHeight,
          notch: notch,
          radius: radius,
        ),
        child: ClipPath(
          clipper: _TicketClipper(
            topHeight: topHeight,
            notch: notch,
            radius: radius,
          ),
          child: Container(
            color: theme.cardColor,
            height: topHeight + bottomHeight,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: topHeight,
                      child: _TicketTop(
                        value: model?.orderCount.toString(),
                        label: 'total_orders'.tr,
                      ),
                    ),
                    SizedBox(
                      height: bottomHeight,
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
                            indent: Dimensions.h22,
                            endIndent: Dimensions.h22,
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

                // خط التمزيق: نفس DashedLine المستخدم بكرت الأرباح
                PositionedDirectional(
                  top: topHeight - (_kTearThickness / 2),
                  start: notch + Dimensions.w8,
                  end: notch + Dimensions.w8,
                  child: DashedLine(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                    thickness: _kTearThickness,
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

/// ───────────── Top part: total + parcels image ─────────────
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
        // الطرود "واقفة" على خط التمزيق (نفس حجم صورة الأرباح)
        PositionedDirectional(
          end: Dimensions.w20,
          bottom: Dimensions.h20,
          width: Dimensions.w95,
          height: Dimensions.h95,
          child: IgnorePointer(
            child: Image.asset(
              ManagerAssets.doghreeParcelsImage,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              Dimensions.w22,
              Dimensions.h20,
              Dimensions.w124,
              Dimensions.h18,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // النقطة الصفراء: نفس كرت الأرباح (stroke = 1)
                    Container(
                      width: Dimensions.w14,
                      height: Dimensions.w14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor,
                        border: Border.all(color: scheme.onPrimary, width: 1),
                      ),
                    ),
                    SizedBox(width: Dimensions.w8),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Dimensions.fs14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.h6),
                _CountText(value: value, fontSize: Dimensions.fs48),
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
      padding: EdgeInsets.symmetric(horizontal: Dimensions.w22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Dimensions.fs13,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: Dimensions.h2),
          _CountText(value: value, fontSize: Dimensions.fs32),
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
      return AppShimmerBlock(
        width: fontSize * 1.2,
        height: fontSize,
        radius: Dimensions.r8,
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
Path _ticketPath(
  Size size, {
  required double topHeight,
  required double notch,
  required double radius,
}) {
  final body = Path()
    ..addRRect(RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ));
  final notches = Path()
    ..addOval(Rect.fromCircle(center: Offset(0, topHeight), radius: notch))
    ..addOval(
        Rect.fromCircle(center: Offset(size.width, topHeight), radius: notch));
  return Path.combine(PathOperation.difference, body, notches);
}

class _TicketClipper extends CustomClipper<Path> {
  final double topHeight;
  final double notch;
  final double radius;
  const _TicketClipper({
    required this.topHeight,
    required this.notch,
    required this.radius,
  });

  @override
  Path getClip(Size size) =>
      _ticketPath(size, topHeight: topHeight, notch: notch, radius: radius);

  @override
  bool shouldReclip(covariant _TicketClipper old) =>
      old.topHeight != topHeight ||
      old.notch != notch ||
      old.radius != radius;
}

/// يرسم الإطار فقط. خط التمزيق صار بـ DashedLine.
class _TicketBorderPainter extends CustomPainter {
  final Color border;
  final double topHeight;
  final double notch;
  final double radius;
  _TicketBorderPainter({
    required this.border,
    required this.topHeight,
    required this.notch,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _ticketPath(size, topHeight: topHeight, notch: notch, radius: radius),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_TicketBorderPainter o) =>
      o.border != border ||
      o.topHeight != topHeight ||
      o.notch != notch ||
      o.radius != radius;
}