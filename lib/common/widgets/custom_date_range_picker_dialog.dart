import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class CustomDateRangePickerDialog extends StatefulWidget {
  final DateTimeRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDateRangePickerDialog({
    super.key,
    this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomDateRangePickerDialog> createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<CustomDateRangePickerDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange?.start;
    _end = widget.initialRange?.end;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color? buttonInk = theme.textTheme.bodyMedium?.color;
    final bool ready = _start != null && _end != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: Dimensions.w20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(Dimensions.r24),
          border: Border.all(color: scheme.outline),
        ),
        padding: EdgeInsets.all(Dimensions.w16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SfDateRangePicker(
              backgroundColor: Colors.transparent,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: widget.initialRange == null
                  ? null
                  : PickerDateRange(
                      widget.initialRange!.start,
                      widget.initialRange!.end,
                    ),
              minDate: widget.firstDate,
              maxDate: widget.lastDate,
              showActionButtons: false,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                final Object? value = args.value;
                if (value is PickerDateRange) {
                  setState(() {
                    _start = value.startDate;
                    _end = value.endDate;
                  });
                }
              },
              headerStyle: DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                backgroundColor: Colors.transparent,
                textStyle: textBold().copyWith(
                  fontSize: Dimensions.fs16,
                  color: scheme.onSurface,
                ),
              ),
              monthViewSettings: DateRangePickerMonthViewSettings(
                // أسبوع السحب عندكم بيبدأ السبت
                firstDayOfWeek: 6,
                dayFormat: 'EEE',
                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                  textStyle: textMedium().copyWith(
                    fontSize: Dimensions.fs12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: textRegular().copyWith(
                  fontSize: Dimensions.fs14,
                  color: scheme.onSurface,
                ),
                // اليوم: خط أسفلت عريض (ممنوع نص أصفر على أبيض)
                todayTextStyle: textBold().copyWith(
                  fontSize: Dimensions.fs14,
                  color: scheme.onSurface,
                ),
                disabledDatesTextStyle: textRegular().copyWith(
                  fontSize: Dimensions.fs14,
                  color: theme.disabledColor,
                ),
              ),
              yearCellStyle: DateRangePickerYearCellStyle(
                textStyle: textRegular().copyWith(
                  fontSize: Dimensions.fs14,
                  color: scheme.onSurface,
                ),
                todayTextStyle: textBold().copyWith(
                  fontSize: Dimensions.fs14,
                  color: scheme.onSurface,
                ),
              ),
              // بداية ونهاية الفترة: أصفر + نص أسفلت
              selectionColor: scheme.primary,
              startRangeSelectionColor: scheme.primary,
              endRangeSelectionColor: scheme.primary,
              selectionTextStyle: textBold().copyWith(
                fontSize: Dimensions.fs14,
                color: scheme.onPrimary,
              ),
              // الأيام بين البداية والنهاية: أصفر ناعم + نص أسفلت
              rangeSelectionColor: scheme.primaryContainer,
              rangeTextStyle: textMedium().copyWith(
                fontSize: Dimensions.fs14,
                color: scheme.onPrimaryContainer,
              ),
              todayHighlightColor: scheme.primary,
            ),
            SizedBox(height: Dimensions.h12),
            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.transparent,
                    isBorder: true,
                    isBold: true,
                    borderColor: buttonInk,
                    buttonText: 'cancel'.tr,
                    textColor: buttonInk,
                  ),
                ),
                SizedBox(width: Dimensions.w12),
                Expanded(
                  child: CustomButtonWidget(
                    onPressed: ready
                        ? () => Navigator.of(context).pop(
                              DateTimeRange(start: _start!, end: _end!),
                            )
                        : null,
                    buttonText: 'confirm'.tr,
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