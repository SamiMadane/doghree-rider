import 'package:flutter/material.dart';

/// شحطة "الطريق": أسفلت وعليها شحطات صفراء (وتنعكس بالداكن).
/// تنزلق فوق التبويب النشط، وتدعم RTL تلقائياً.
class BottomNavRoadIndicator extends StatelessWidget {
  final int index;
  final int count;

  const BottomNavRoadIndicator({
    super.key,
    required this.index,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // فاتح: طريق أسفلت + شحطات صفراء. داكن: طريق أصفر + شحطات أسفلت.
    final Color road = isDark ? cs.primary : cs.onSurface;
    final Color lane = isDark ? cs.onPrimary : cs.primary;

    Widget dash(double w) => Container(
          width: w,
          height: 3,
          decoration: BoxDecoration(
            color: lane,
            borderRadius: BorderRadius.circular(2),
          ),
        );

    return IgnorePointer(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: AlignmentDirectional(
          count <= 1 ? 0 : -1 + 2 * index / (count - 1),
          -1,
        ),
        child: FractionallySizedBox(
          widthFactor: 1 / count,
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 45,
                height: 8,
                decoration: BoxDecoration(
                  color: road,
                  borderRadius: BorderRadius.circular(4),
                ),
                // ترتيب الشحطات ثابت (طويلة، طويلة، قصيرة) بغض النظر عن RTL
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dash(11),
                      const SizedBox(width: 3),
                      dash(11),
                      const SizedBox(width: 3),
                      dash(6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}