import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// ألوان الشيمر من الثيم. كل وضع له قوة لمعة خاصة لأن التباين مختلف:
/// فاتح = لمعة بيضاء فوق رمادي خفيف (تحتاج قوة أعلى)،
/// داكن = لمعة بيضاء فوق رمادي غامق (تحتاج قوة أقل).
class _ShimmerPalette {
  final Color base;
  final Color shine;
  final double shineOpacity;
  const _ShimmerPalette(this.base, this.shine, this.shineOpacity);

  factory _ShimmerPalette.of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    return isDark
        ? _ShimmerPalette(cs.onSurface.withValues(alpha: 0.10), cs.onSurface, 0.14)
        : _ShimmerPalette(cs.onSurface.withValues(alpha: 0.09), theme.cardColor, 0.8);
  }
}

class OrderShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  final EdgeInsetsGeometry? margin;

  const OrderShimmerWidget({
    super.key,
    required this.isEnabled,
    this.margin,
  });

  /// اللمعة تُقصّ بشكل الكتلة نفسها، وإلا ترسم مستطيل الويدجت كامل
  /// وتظهر الدائرة كأنها مربع.
  Widget _shimmer(
    _ShimmerPalette p,
    Widget child, {
    BorderRadius? radius,
    bool circle = false,
  }) {
    final Widget shimmer = Shimmer(
      enabled: isEnabled,
      duration: const Duration(seconds: 2),
      color: p.shine,
      colorOpacity: p.shineOpacity,
      child: child,
    );
    if (circle) return ClipOval(child: shimmer);
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(Dimensions.r4),
      child: shimmer,
    );
  }

  /// كتلة شيمر بحجم ثابت
  Widget _block(
    _ShimmerPalette p, {
    required double height,
    required double width,
    double? radius,
    bool circle = false,
  }) {
    final BorderRadius corners =
        BorderRadius.circular(radius ?? Dimensions.r4);
    return _shimmer(
      p,
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: p.base,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : corners,
        ),
      ),
      radius: corners,
      circle: circle,
    );
  }

  /// سطر نص: يحجز نفس ارتفاع السطر الحقيقي، والمربع المرسوم أقصر منه
  /// عشان يبقى فراغ بين السطور زي النص الحقيقي.
  Widget _textLine(
    _ShimmerPalette p, {
    required TextStyle style,
    required double width,
  }) {
    final double barHeight = (style.fontSize ?? Dimensions.fs14) * 0.7;
    return SizedBox(
      width: width,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          // سطر شفاف يعطي ارتفاع السطر الحقيقي بنفس الـ style
          Text(
            ' ',
            maxLines: 1,
            style: style.copyWith(color: Colors.transparent),
          ),
          _block(p, height: barHeight, width: width),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ShimmerPalette p = _ShimmerPalette.of(context);
    final TextStyle title = textSemiBold().copyWith(fontSize: Dimensions.fs14);
    final TextStyle subtitle =
        textRegular().copyWith(fontSize: Dimensions.fs14);

    return CustomCard(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      margin: margin ?? EdgeInsetsDirectional.only(end: Dimensions.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID + حالة الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _textLine(p, style: title, width: 90),
                ),
              ),
              // نفس padding وشكل شارة الدفع
              _shimmer(
                p,
                Container(
                  width: 70,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.w12,
                    vertical: Dimensions.h4,
                  ),
                  decoration: BoxDecoration(
                    color: p.base,
                    borderRadius: BorderRadius.circular(Dimensions.r20),
                  ),
                  child: Text(
                    ' ',
                    maxLines: 1,
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs12,
                      color: Colors.transparent,
                    ),
                  ),
                ),
                radius: BorderRadius.circular(Dimensions.r20),
              ),
            ],
          ),
          SizedBox(height: Dimensions.h16),

          // أيقونات + خطوط
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _block(
                    p,
                    height: Dimensions.h28,
                    width: Dimensions.w28,
                    circle: true,
                  ),
                  SizedBox(
                    height: Dimensions.h40,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      dashLength: 8,
                      dashColor: Theme.of(context).disabledColor,
                    ),
                  ),
                  _block(
                    p,
                    height: Dimensions.h24,
                    width: Dimensions.w24,
                    circle: true,
                  ),
                ],
              ),
              SizedBox(width: Dimensions.w8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المتجر
                    _textLine(p, style: title, width: 140),
                    // عنوان المتجر
                    _textLine(p, style: subtitle, width: 200),
                    SizedBox(height: Dimensions.h4),
                    SizedBox(height: Dimensions.h20),
                    // عنوان التوصيل / المتجر
                    _textLine(p, style: title, width: 170),
                    // Label
                    _textLine(p, style: subtitle, width: 110),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // زر التفاصيل: بنفس ارتفاع الزر الحقيقي (حد أدنى أزرار الثيم 52)
          _block(
            p,
            height: 52,
            width: double.infinity,
            radius: Dimensions.r20,
          ),
        ],
      ),
    );
  }
}