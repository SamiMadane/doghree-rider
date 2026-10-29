import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:doghree_rider/util/dimensions.dart';

/// ألوان الشيمر الموحدة من الثيم. كل وضع له قوة لمعة خاصة لأن التباين مختلف:
/// فاتح = لمعة بيضاء فوق رمادي خفيف (تحتاج قوة أعلى)،
/// داكن = لمعة بيضاء فوق رمادي غامق (تحتاج قوة أقل).
class AppShimmerPalette {
  final Color base;
  final Color shine;
  final double shineOpacity;
  const AppShimmerPalette(this.base, this.shine, this.shineOpacity);

  factory AppShimmerPalette.of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    return isDark
        ? AppShimmerPalette(
            cs.onSurface.withValues(alpha: 0.10), cs.onSurface, 0.14)
        : AppShimmerPalette(
            cs.onSurface.withValues(alpha: 0.09), theme.cardColor, 0.8);
  }
}

/// يغلّف أي child بلمعة الشيمر الموحدة، ويقصّها بشكل الكتلة نفسها
/// (وإلا ترسم مستطيل الويدجت كامل وتظهر الدائرة كأنها مربع).
class AppShimmer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final bool circle;
  final bool enabled;

  const AppShimmer({
    super.key,
    required this.child,
    this.borderRadius,
    this.circle = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final AppShimmerPalette p = AppShimmerPalette.of(context);
    final Widget shimmer = Shimmer(
      enabled: enabled,
      duration: const Duration(seconds: 2),
      color: p.shine,
      colorOpacity: p.shineOpacity,
      // اتجاه ثابت بالعربي والإنجليزي
      direction: const ShimmerDirection.fromLTRB(),
      child: child,
    );
    if (circle) return ClipOval(child: shimmer);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(Dimensions.r4),
      child: shimmer,
    );
  }
}

/// كتلة شيمر جاهزة: بحجم ثابت، أو بحجم محتواها عند تمرير [child].
class AppShimmerBlock extends StatelessWidget {
  final double? width;
  final double? height;
  final double? radius;
  final bool circle;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  const AppShimmerBlock({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.circle = false,
    this.enabled = true,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppShimmerPalette p = AppShimmerPalette.of(context);
    final BorderRadius corners =
        BorderRadius.circular(radius ?? Dimensions.r4);
    return AppShimmer(
      circle: circle,
      enabled: enabled,
      borderRadius: corners,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: p.base,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : corners,
        ),
        child: child,
      ),
    );
  }
}

/// سطر نص: يحجز نفس ارتفاع السطر الحقيقي، والمربع المرسوم أقصر منه
/// عشان يبقى فراغ بين السطور زي النص الحقيقي.
class AppShimmerTextLine extends StatelessWidget {
  final TextStyle style;
  final double width;
  final bool enabled;

  const AppShimmerTextLine({
    super.key,
    required this.style,
    required this.width,
    this.enabled = true,
  });

  static const double _barRatio = 0.7;

  @override
  Widget build(BuildContext context) {
    final double barHeight = (style.fontSize ?? Dimensions.fs14) * _barRatio;
    return SizedBox(
      width: width,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          // سطر شفاف يعطي ارتفاع السطر الحقيقي بنفس الـ style
          Text(' ', maxLines: 1, style: style.copyWith(color: Colors.transparent)),
          AppShimmerBlock(width: width, height: barHeight, enabled: enabled),
        ],
      ),
    );
  }
}