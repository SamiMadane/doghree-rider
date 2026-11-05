import 'package:audioplayers/audioplayers.dart';
import 'package:doghree_rider/common/widgets/app_shimmer.dart';
import 'package:doghree_rider/common/widgets/brand_dot_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/replay_image.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LottieBottomSheetOrderRequest extends StatefulWidget {
  final bool isRequest;
  final Function onAccept;
  final Function onReject;
  final int orderId;
  final bool isParcel;
  final OrderRequestType requestType;

  const LottieBottomSheetOrderRequest({
    super.key,
    required this.isRequest,
    required this.onAccept,
    required this.onReject,
    required this.orderId,
    required this.isParcel,
    this.requestType = OrderRequestType.newOrder,
  });

  @override
  State<LottieBottomSheetOrderRequest> createState() =>
      _LottieBottomSheetOrderRequestState();
}

enum OrderRequestType { newOrder, nearbyOrder, assignedOrder }

class _LottieBottomSheetOrderRequestState
    extends State<LottieBottomSheetOrderRequest>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Get.find<OrderController>().getOrderWithId(widget.orderId);
    });
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final CurvedAnimation curved =
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic);
    _fade = curved;
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(curved);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat();

    _startAlarm();
    _slideController.forward();
    Get.find<OrderController>()
        .getOrderDetails(widget.orderId, widget.isParcel);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startAlarm() async {
    AudioPlayer audio = AudioPlayer();
    await audio.play(AssetSource('notification.mp3'));
  }

  void _handleAccept() {
    _slideController.reverse().then((_) {
      Navigator.pop(context);
      widget.onAccept();
    });
  }

  void _closeBottomSheet() {
    _slideController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  String _getTitle() {
    switch (widget.requestType) {
      case OrderRequestType.newOrder:
        return 'new_order_request_from_customer'.tr;
      case OrderRequestType.nearbyOrder:
        return 'new_order_nearby'.tr;
      case OrderRequestType.assignedOrder:
        return 'order_assigned_to_you'.tr;
    }
  }

  String _getSubtitle() {
    switch (widget.requestType) {
      case OrderRequestType.newOrder:
        return 'new_order_opportunity'.tr;
      case OrderRequestType.nearbyOrder:
        return 'nearby_order_opportunity'.tr;
      case OrderRequestType.assignedOrder:
        return 'assigned_order_waiting'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      color: theme.cardColor,
      child: GetBuilder<OrderController>(builder: (orderController) {
        final order = orderController.orderModel;
        // orderModel is shared between screens: only trust it if it is THIS order.
        final bool loaded =
            order != null && (order.id == null || order.id == widget.orderId);
        final double? fee = (loaded)
            ? (order.originalDeliveryCharge ?? order.deliveryCharge)
            : null;
        final double tips = (loaded) ? (order.dmTips ?? 0) : 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.w20,
                      vertical: Dimensions.h12,
                    ),
                    child: Column(
                      children: [
                        _RequestHero(pulse: _pulseController),
                        SizedBox(height: Dimensions.h12),
                        Text(
                          _getTitle(),
                          textAlign: TextAlign.center,
                          style: textBold().copyWith(
                            fontSize: Dimensions.fs20,
                            color: scheme.onSurface,
                          ),
                        ),
                        SizedBox(height: Dimensions.h4),
                        Text(
                          _getSubtitle(),
                          textAlign: TextAlign.center,
                          style: textMedium().copyWith(
                            fontSize: Dimensions.fs14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: Dimensions.h12),
                        _MetaChips(
                          orderId: widget.orderId,
                          isParcel: widget.isParcel,
                        ),
                        SizedBox(height: Dimensions.h16),
                        if (fee != null)
                          _FeeStrip(fee: fee, tips: tips)
                        else
                          AppShimmerBlock(
                            width: double.infinity,
                            height: Dimensions.h70,
                            radius: Dimensions.r16,
                          ),
                        SizedBox(height: Dimensions.h12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildActions(theme),
          ],
        );
      }),
    );
  }

  /// Fixed bottom bar, separated from the content by a thin outline.
  Widget _buildActions(ThemeData theme) {
    final Color ink = theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w20,
        vertical: Dimensions.h16,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: widget.isRequest == true
            ? Row(
                children: [
                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: _closeBottomSheet,
                      buttonText: 'not_now'.tr,
                      isBorder: true,
                      transparent: true,
                      fontColor: ink,
                      borderColor: ink,
                    ),
                  ),
                  SizedBox(width: Dimensions.w16),
                  Expanded(
                    flex: 2,
                    child: CustomButtonWidget(
                      onPressed: _handleAccept,
                      buttonText: 'view_order'.tr,
                    ),
                  ),
                ],
              )
            : CustomButtonWidget(
                onPressed: _handleAccept,
                buttonText: 'view_details'.tr,
              ),
      ),
    );
  }
}

/// Lottie on a soft stage, with two rings pulsing outward (incoming-request cue).
class _RequestHero extends StatelessWidget {
  final Animation<double> pulse;
  const _RequestHero({required this.pulse});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double stage = Dimensions.w130;
    final double box = Dimensions.w170;

    return RepaintBoundary(
      child: SizedBox(
        width: box,
        height: box,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PulsePainter(
                  progress: pulse,
                  color: scheme.primary,
                  innerRadius: stage / 2,
                ),
              ),
            ),
            Container(
              width: stage,
              height: stage,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer,
                border: Border.all(color: scheme.outline),
              ),
              child: ClipOval(
                child: ReplayImage(
                  asset: ManagerAssets.doghreeRiderAnim,
                  size: stage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;
  final double innerRadius;

  _PulsePainter({
    required this.progress,
    required this.color,
    required this.innerRadius,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxRadius = size.shortestSide / 2;

    // Two rings, half a cycle apart.
    for (final double shift in const [0.0, 0.5]) {
      final double t = (progress.value + shift) % 1.0;
      final double radius = innerRadius + (maxRadius - innerRadius) * t;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: (1 - t) * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) =>
      old.color != color || old.innerRadius != innerRadius;
}

/// Order number (+ parcel tag), shown before the order data finishes loading.
class _MetaChips extends StatelessWidget {
  final int orderId;
  final bool isParcel;

  const _MetaChips({required this.orderId, required this.isParcel});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Dimensions.w8,
      runSpacing: Dimensions.h8,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w12,
            vertical: Dimensions.h4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.r50),
            border: Border.all(color: scheme.outline),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${'id_label'.tr}: ',
                  style: textMedium().copyWith(
                    fontSize: Dimensions.fs13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                TextSpan(
                  text: '#$orderId',
                  style: textBold().copyWith(
                    fontSize: Dimensions.fs13,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isParcel)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w12,
              vertical: Dimensions.h4,
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(Dimensions.r50),
            ),
            child: Text(
              'parcel'.tr,
              style: textBold().copyWith(
                fontSize: Dimensions.fs12,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }
}

/// Delivery fee up front (the rider's main decision input) + tips if any.
class _FeeStrip extends StatelessWidget {
  final double fee;
  final double tips;

  const _FeeStrip({required this.fee, required this.tips});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h14,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.r16),
      ),
      child: Row(
        children: [
          const BrandDot(),
          SizedBox(width: Dimensions.w10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'delivery_fee'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium().copyWith(
                    fontSize: Dimensions.fs13,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: Dimensions.h2),
                Text(
                  PriceConverterHelper.convertPrice(fee),
                  textDirection: TextDirection.ltr,
                  style: textDisplay().copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          if (tips > 0) ...[
            SizedBox(width: Dimensions.w8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w12,
                vertical: Dimensions.h8,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(Dimensions.r12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'delivery_tips'.tr,
                    style: textMedium().copyWith(
                      fontSize: Dimensions.fs11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '+ ${PriceConverterHelper.convertPrice(tips)}',
                    textDirection: TextDirection.ltr,
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs14,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}