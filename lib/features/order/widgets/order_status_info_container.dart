import 'package:flutter/material.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/order/widgets/order_prep_stage.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class OrderStatusInfoContainer extends StatelessWidget {
  final bool processing;

  const OrderStatusInfoContainer({super.key, required this.processing});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final OrderPrepStage stage = OrderPrepStage.of(processing);

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w16,
              vertical: Dimensions.h16,
            ),
            child: Row(
              children: [
                Image.asset(
                  stage.image,
                  width: Dimensions.w56,
                  height: Dimensions.h56,
                  fit: BoxFit.contain,
                  cacheWidth: 256,
                ),
                SizedBox(width: Dimensions.w20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StageChip(stage: stage),
                      SizedBox(height: Dimensions.h8),
                      Text(
                        stage.description,
                        style: textMedium().copyWith(
                          fontSize: Dimensions.fs13,
                          height: 1.4,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _LaneStrip(stage: stage),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final OrderPrepStage stage;
  const _StageChip({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w10,
        vertical: Dimensions.h4,
      ),
      decoration: BoxDecoration(
        color: stage.chipBackground,
        borderRadius: BorderRadius.circular(Dimensions.r50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Dimensions.w6,
            height: Dimensions.w6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: stage.chipForeground,
            ),
          ),
          SizedBox(width: Dimensions.w6),
          Text(
            stage.label,
            style: textBold().copyWith(
              fontSize: Dimensions.fs12,
              color: stage.chipForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط طريق مصغّر (من الشعار): مسار + خطوط حارة.
/// التحريك فقط أثناء التجهيز.
class _LaneStrip extends StatefulWidget {
  final OrderPrepStage stage;
  const _LaneStrip({required this.stage});

  @override
  State<_LaneStrip> createState() => _LaneStripState();
}

class _LaneStripState extends State<_LaneStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _LaneStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage) _sync();
  }

  void _sync() {
    if (widget.stage.isProcessing) {
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

    return RepaintBoundary(
      child: SizedBox(
        height: Dimensions.h8,
        width: double.infinity,
        child: CustomPaint(
          painter: _LanePainter(
            progress: _controller,
            track: OrderPrepStage.laneTrack(isDark),
            dash: widget.stage.laneDash,
            rtl: rtl,
          ),
        ),
      ),
    );
  }
}

class _LanePainter extends CustomPainter {
  final Animation<double> progress;
  final Color track;
  final Color dash;
  final bool rtl;

  _LanePainter({
    required this.progress,
    required this.track,
    required this.dash,
    required this.rtl,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = track);

    final double dashLen = size.height * 2.2;
    final double gap = size.height * 1.8;
    final double period = dashLen + gap;
    final Paint paint = Paint()
      ..color = dash
      ..strokeWidth = size.height * 0.34
      ..strokeCap = StrokeCap.round;
    final double y = size.height / 2;
    final double shift = progress.value * period;

    for (double x = -period + shift; x < size.width + period; x += period) {
      double x1 = x;
      double x2 = x + dashLen;
      if (rtl) {
        // الحركة باتجاه القراءة: من اليمين لليسار بالعربية
        final double a = size.width - x2;
        final double b = size.width - x1;
        x1 = a;
        x2 = b;
      }
      canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LanePainter old) =>
      old.track != track || old.dash != dash || old.rtl != rtl;
}
