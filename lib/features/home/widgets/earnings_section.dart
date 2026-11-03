import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/common/widgets/dashed_line_widget.dart';
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
            PositionedDirectional(
              end: Dimensions.w8,
              top: Dimensions.h8,
              width: Dimensions.w95,
              height: Dimensions.h95,
              child: IgnorePointer(
                child: Image.asset(
                  ManagerAssets.doghreeCoins,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            // Material شفاف: يخلي تأثير الضغط يظهر فوق خلفية الكرت
            Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== القسم الأول: الأرباح كلها + الإجمالي =====
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      Dimensions.w20,
                      Dimensions.h18,
                      Dimensions.w20,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان + العين + الرقم (بعيد عن الصورة)
                        Padding(
                          padding:
                              EdgeInsetsDirectional.only(end: Dimensions.w108),
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
                                  SizedBox(width: Dimensions.w4),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        widget.showEarnings.value = !show,
                                    child: Padding(
                                      padding: EdgeInsets.all(Dimensions.r4),
                                      child: Icon(
                                        show
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: Dimensions.r18,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Dimensions.h2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: _amount(values[_period], show, cs),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.h20),
                        // أزرار الفترة
                        Wrap(
                          spacing: Dimensions.w6,
                          runSpacing: Dimensions.h6,
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
                        // أقل من قبل: صف الإجمالي صار له padding عمودي خاص به
                        SizedBox(height: Dimensions.h12),
                        // الإجمالي: قابل للضغط، يفتح تفاصيل الأرباح لكل طلب
                        GetBuilder<CashInHandController>(builder: (c) {
                          final wallet = c.wallet;

                          return InkWell(
                            onTap: () =>
                                Get.toNamed(RouteHelper.getMyEarningRoute()),
                            borderRadius: BorderRadius.circular(Dimensions.r8),
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: Dimensions.h4),
                              child: Row(
                                children: [
                                  Container(
                                    width: Dimensions.w14,
                                    height: Dimensions.w14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.primaryColor,
                                      border: Border.all(
                                          color: cs.onPrimary, width: 1),
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.w8),
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
                                    (show && wallet != null)
                                        ? PriceConverterHelper.convertPrice(
                                            wallet.totalEarning)
                                        : '*****',
                                    style: textBold().copyWith(
                                      fontSize: Dimensions.fs14,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.w4),
                                  // chevron_right ينعكس تلقائياً بالعربي
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: Dimensions.r18,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // ===== الفاصل: شحطات الطريق =====
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.w20,
                      vertical: Dimensions.h12,
                    ),
                    child: DashedLine(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                    ),
                  ),

                  // ===== القسم الثاني: المتاح للسحب + الرصيد والسحب =====
                  GetBuilder<CashInHandController>(
                    builder: (c) {
                      final wallet = c.wallet;

                      return InkWell(
                        onTap: () =>
                            Get.toNamed(RouteHelper.getCashInHandRoute()),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            Dimensions.w20,
                            Dimensions.h2,
                            Dimensions.w20,
                            Dimensions.h14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'available_to_withdraw'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textMedium().copyWith(
                                        fontSize: Dimensions.fs13,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    // المبلغ القابل للسحب: ثاني أهم رقم بالكرت
                                    Text(
                                      wallet == null
                                          ? '—'
                                          : (show
                                              ? PriceConverterHelper
                                                  .convertPrice(
                                                      wallet.availableBalance)
                                              : '*****'),
                                      style: textBold().copyWith(
                                        fontSize: Dimensions.fs20,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'view_details'.tr,
                                    style: textBold().copyWith(
                                      fontSize: Dimensions.fs12,
                                      color: cs.tertiary,
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.w2),
                                  // chevron_right ينعكس تلقائياً بالعربي
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: Dimensions.r18,
                                    color: cs.tertiary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// الرقم الكبير: يعدّ بحركة عند تغيير الفترة أو إظهاره
  Widget _amount(double? v, bool show, ColorScheme cs) {
    final TextStyle style = textBold().copyWith(
      fontSize: Dimensions.fs34,
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
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w14,
          vertical: Dimensions.h8,
        ),
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