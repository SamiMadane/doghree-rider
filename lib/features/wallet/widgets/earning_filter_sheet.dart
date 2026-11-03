import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_date_range_picker_dialog.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

const String _allTypes = 'all_types_earning';
const String _allTime = 'all_time';
const String _customRange = 'custom_date_range';

void showEarningFilterSheet() =>
    showCustomBottomSheet(child: const EarningFilterSheet());

/// Edits a local draft; nothing reaches the controller until Apply or Reset,
/// so closing the sheet never leaves the list and the filter out of sync.
class EarningFilterSheet extends StatefulWidget {
  const EarningFilterSheet({super.key});

  @override
  State<EarningFilterSheet> createState() => _EarningFilterSheetState();
}

class _EarningFilterSheetState extends State<EarningFilterSheet> {
  final WalletController _c = Get.find<WalletController>();

  late String _type;
  late String _dateType;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _type = _c.selectedEarningType ?? _allTypes;
    _dateType = _c.selectedDateType ?? _allTime;
    _range = _storedRange();
  }

  DateTimeRange? _storedRange() {
    final DateTime? start = DateTime.tryParse(_c.from ?? '');
    final DateTime? end = DateTime.tryParse(_c.to ?? '');
    if (start == null || end == null) return null;
    return DateTimeRange(start: start, end: end);
  }

  bool get _needsRange => _dateType == _customRange;
  bool get _canApply => !_needsRange || _range != null;
  Future<void> _pickRange() async {
    final DateTime now = DateTime.now();
    final DateTime first = now.subtract(const Duration(days: 365));
    final DateTimeRange? current = _range;
    // The initial range must sit inside [first, now] or the picker asserts.
    final bool fits = current != null && !current.start.isBefore(first);

    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (_) => CustomDateRangePickerDialog(
        initialRange: fits ? current : null,
        firstDate: first,
        lastDate: now,
      ),
    );
    if (picked != null && mounted) setState(() => _range = picked);
  }

  void _apply() {
    Navigator.of(context).pop();
    _c.applyEarningFilter(type: _type, dateType: _dateType, range: _range);
  }

  void _reset() {
    Navigator.of(context).pop();
    _c.applyEarningFilter(type: _allTypes, dateType: _allTime);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color? buttonInk = Theme.of(context).textTheme.bodyMedium?.color;

    return Flexible(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Dimensions.w20,
          Dimensions.h4,
          Dimensions.w20,
          Dimensions.h20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'filter_by'.tr,
              textAlign: TextAlign.center,
              style: textBold().copyWith(
                fontSize: Dimensions.fs16,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: Dimensions.h20),
            _FilterGroup(
              label: 'select_earning_types'.tr,
              options: _c.earningTypes,
              selected: _type,
              onSelected: (String v) => setState(() => _type = v),
            ),
            SizedBox(height: Dimensions.h20),
            _FilterGroup(
              label: 'select_date_range'.tr,
              options: _c.dateTypes,
              selected: _dateType,
              onSelected: (String v) => setState(() => _dateType = v),
            ),
            if (_needsRange) ...[
              SizedBox(height: Dimensions.h12),
              _RangeField(range: _range, onTap: _pickRange),
            ],
            SizedBox(height: Dimensions.h25),
            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'reset'.tr,
                    isBorder: true,
                    transparent: true,
                    textColor: buttonInk,
                    borderColor: buttonInk,
                    onPressed: _reset,
                  ),
                ),
                SizedBox(width: Dimensions.w10),
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'apply_filter'.tr,
                    onPressed: _canApply ? _apply : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small label above a wrap of single-choice pills.
class _FilterGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textMedium().copyWith(
            fontSize: Dimensions.fs14,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.h10),
        Wrap(
          spacing: Dimensions.w8,
          runSpacing: Dimensions.h8,
          children: [
            for (final String option in options)
              _FilterPill(
                label: option.tr,
                selected: option == selected,
                onTap: () => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}

/// Same pill as the period pills on the home earnings card.
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Selected: asphalt on light, yellow on dark (brand guide).
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
          borderRadius: BorderRadius.circular(Dimensions.r50),
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

/// Outlined field that shows the chosen range and opens the picker.
class _RangeField extends StatelessWidget {
  final DateTimeRange? range;
  final VoidCallback onTap;

  const _RangeField({required this.range, required this.onTap});

  String _format(DateTime d) => d.toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final DateTimeRange? r = range;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.r10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w14,
            vertical: Dimensions.h12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.r10),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  r == null
                      ? 'custom_date_range'.tr
                      : '${_format(r.start)} - ${_format(r.end)}',
                  textDirection: r == null ? null : TextDirection.ltr,
                  style: textRegular().copyWith(
                    fontSize: Dimensions.fs14,
                    color: r == null ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
              ),
              SizedBox(width: Dimensions.w12),
              SvgPicture.asset(
                ManagerAssets.calendarIcon,
                width: Dimensions.w20,
                height: Dimensions.w20,
                colorFilter: ColorFilter.mode(
                  cs.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
