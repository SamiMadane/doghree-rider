import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

class EarningsSection extends StatefulWidget {
  final ProfileController profileController;
  final RxBool showEarnings; // تتحكم بجميع الأرقام

  const EarningsSection({
    super.key,
    required this.profileController,
    required this.showEarnings,
  });

  @override
  State<EarningsSection> createState() => _EarningsSectionState();
}

class _EarningsSectionState extends State<EarningsSection> {
  int _period = 0; // 0 اليوم، 1 الأسبوع، 2 الشهر

  @override
  Widget build(BuildContext context) {
    final profile = widget.profileController.profileModel;
    if (profile == null || profile.earnings != 1) return const SizedBox();

    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    final List<double?> values = <double?>[
      profile.todaysEarning,
      profile.thisWeekEarning,
      profile.thisMonthEarning,
    ];
    final List<String> titles = <String>[
      'your_earnings_today'.tr,
      'your_earnings_week'.tr,
      'your_earnings_month'.tr,
    ];
    final List<String> pills = <String>[
      'today'.tr,
      'this_week'.tr,
      'this_month'.tr,
    ];

    return Obx(() {
      final bool show = widget.showEarnings.value;

      return Container(
        margin: EdgeInsets.only(top: Dimensions.h20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(Dimensions.r20),
          border: Border.all(color: cs.outline),
        ),
        child: Stack(
          children: [
            // هالة العملات (بتنقصّ من زاوية الكرت)
            PositionedDirectional(
              end: -40,
              top: -18,
              width: 150,
              height: 150,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primaryContainer,
                ),
              ),
            ),
            PositionedDirectional(
              end: 8,
              top: 6,
              width: 96,
              height: 96,
              child: IgnorePointer(
                child: Image.asset(
                  ManagerAssets.doghreeCoins,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان + العين + الرقم (بعيد عن الصورة)
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.only(end: 108),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    titles[_period],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textMedium().copyWith(
                                      fontSize: Dimensions.fs13,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      widget.showEarnings.value = !show,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      show
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 18,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: _amount(values[_period], show, cs),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // أزرار الفترة
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List<Widget>.generate(
                          pills.length,
                          (i) => _PeriodPill(
                            label: pills[i],
                            selected: _period == i,
                            onTap: () {
                              if (_period == i) return;
                              HapticFeedback.selectionClick();
                              setState(() => _period = i);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // شريط الإجمالي
                Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor,
                          border:
                              Border.all(color: cs.onSurface, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'total_earnings'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textMedium().copyWith(
                            fontSize: Dimensions.fs13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        (show && profile.balance != null)
                            ? PriceConverterHelper.convertPrice(
                                profile.balance)
                            : '*****',
                        style: textBold().copyWith(
                          fontSize: Dimensions.fs16,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// الرقم الكبير: يعدّ بحركة عند تغيير الفترة أو إظهاره
  Widget _amount(double? v, bool show, ColorScheme cs) {
    final TextStyle style = textBold().copyWith(
      fontSize: 34,
      height: 1.2,
      color: cs.onSurface,
    );
    if (v == null || !show) return Text('*****', style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: v),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) =>
          Text(PriceConverterHelper.convertPrice(value), style: style),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // المختار: أسفلت على الفاتح، أصفر على الداكن (حسب الدليل)
    final Color selectedBg = isDark ? cs.primary : cs.onSurface;
    final Color selectedFg = isDark ? cs.onPrimary : cs.surface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? selectedBg : cs.outline),
        ),
        child: Text(
          label,
          style: (selected ? textBold() : textMedium()).copyWith(
            fontSize: Dimensions.fs13,
            color: selected ? selectedFg : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}