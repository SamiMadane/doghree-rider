import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/wallet/widgets/earning_filter_sheet.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// Row of applied-filter chips shown under the earnings app bar.
/// Hidden when no filter is active. Tap the label to edit, tap × to remove it.
class EarningFilterChipsWidget extends StatelessWidget {
  const EarningFilterChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return GetBuilder<WalletController>(builder: (c) {
      if (!c.isFiltered) return const SizedBox.shrink();

      final bool both = c.hasTypeFilter && c.hasDateFilter;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.w16,
          Dimensions.h12,
          Dimensions.w16,
          Dimensions.h4,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (c.hasTypeFilter)
                _AppliedChip(
                  label: c.selectedEarningType!.tr,
                  onEdit: showEarningFilterSheet,
                  onRemove: c.removeEarningTypeFilter,
                ),
              if (c.hasTypeFilter && c.hasDateFilter)
                SizedBox(width: Dimensions.w8),
              if (c.hasDateFilter)
                _AppliedChip(
                  label: '${c.from} - ${c.to}',
                  ltr: true,
                  onEdit: showEarningFilterSheet,
                  onRemove: c.removeEarningDateFilter,
                ),
              if (both) ...[
                SizedBox(width: Dimensions.w12),
                InkWell(
                  onTap: c.clearEarningFilter,
                  borderRadius: BorderRadius.circular(Dimensions.r8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.w4,
                      vertical: Dimensions.h8,
                    ),
                    child: Text(
                      'reset'.tr,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs13,
                        color: cs.tertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _AppliedChip extends StatelessWidget {
  final String label;
  final bool ltr;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _AppliedChip({
    required this.label,
    required this.onEdit,
    required this.onRemove,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color bg = isDark ? cs.primary : cs.primaryContainer;
    final Color fg = isDark ? cs.onPrimary : cs.onPrimaryContainer;

    return Material(
      color: bg,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onEdit,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: Dimensions.w14,
                end: Dimensions.w4,
                top: Dimensions.h8,
                bottom: Dimensions.h8,
              ),
              child: Text(
                label,
                maxLines: 1,
                textDirection: ltr ? TextDirection.ltr : null,
                style: textBold().copyWith(
                  fontSize: Dimensions.fs13,
                  color: fg,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onRemove,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: Dimensions.w4,
                end: Dimensions.w10,
                top: Dimensions.h8,
                bottom: Dimensions.h8,
              ),
              child: Icon(
                Icons.close_rounded,
                size: Dimensions.fs16,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
