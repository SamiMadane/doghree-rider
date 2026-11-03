import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/dashed_line_widget.dart';
import 'package:doghree_rider/common/widgets/image_diaglog_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_account_details.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/withdrawal_status_helper.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

/// Same bottom sheet as the rest of the app (showCustomBottomSheet).
void showWithdrawalDetails(WalletWithdrawal item) {
  showCustomBottomSheet(child: WithdrawalDetailsSheet(item: item));
}

String _two(int n) => n.toString().padLeft(2, '0');

String _fmt(DateTime? d) => d == null
    ? ''
    : '${d.year}-${_two(d.month)}-${_two(d.day)} '
        '${_two(d.hour)}:${_two(d.minute)}';

bool _has(String? v) => v != null && v.trim().isNotEmpty;

class WithdrawalDetailsSheet extends StatelessWidget {
  final WalletWithdrawal item;

  const WithdrawalDetailsSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool paid = item.status == 'paid';
    final bool rejected = item.status == 'rejected';
    final String? proof = item.payoutProofUrl;

    // Account fields first, then the request facts. Two cells per row.
    final List<Widget> accountCells = <Widget>[
      for (final WalletAccountField f in walletAccountFields(
          item.methodName, item.accountFields,
          methodKey: item.methodKey))
        _Fact(label: f.label, value: f.value, ltr: false),
    ];

    final List<Widget> requestCells = <Widget>[
      _Fact(label: 'wallet_requested_at'.tr, value: _fmt(item.requestedAt)),
      if (paid && item.paidAt != null)
        _Fact(label: 'wallet_paid_at'.tr, value: _fmt(item.paidAt)),
      if (paid && _has(item.payoutReference))
        _ReferenceFact(
          label: 'wallet_reference'.tr,
          value: item.payoutReference!,
        ),
      // Straight from the backend (payout_method_label).
      if (_has(item.payoutMethodLabel))
        _Fact(
          label: 'wallet_payout_method'.tr,
          value: item.payoutMethodLabel!,
          ltr: false,
        ),
    ];

    // Flexible (not a fixed max height): the sheet wrapper already adds the
    // handle and close button, so the content must shrink to what is left.
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
              'wallet_withdraw_details'.tr,
              textAlign: TextAlign.center,
              style: textBold().copyWith(
                fontSize: Dimensions.fs16,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: Dimensions.h16),
            _Hero(item: item),
            SizedBox(height: Dimensions.h16),
            DashedLine(color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
            SizedBox(height: Dimensions.h16),

            // Why it was rejected comes first: it is what the rider needs.
            if (rejected && _has(item.rejectionReason)) ...[
              _TextBlock(
                label: 'wallet_rejection_reason'.tr,
                text: item.rejectionReason!,
                accent: cs.error,
              ),
              SizedBox(height: Dimensions.h16),
            ],

            if (item.methodName.isNotEmpty) ...[
              WalletMethodHeader(name: item.methodName, logoUrl: item.logoUrl),
              SizedBox(height: Dimensions.h16),
            ],
            if (accountCells.isNotEmpty) ...[
              _FactsGrid(cells: accountCells),
              SizedBox(height: Dimensions.h16),
            ],
            _FactsGrid(cells: requestCells),
            SizedBox(height: Dimensions.h16),

            if (proof != null && proof.isNotEmpty) ...[
              const _Line(),
              _ProofRow(url: proof),
            ],

            if (_has(item.note)) ...[
              SizedBox(height: Dimensions.h16),
              _TextBlock(label: 'wallet_note'.tr, text: item.note!),
            ],
            if ((paid || rejected) && _has(item.adminNote)) ...[
              SizedBox(height: Dimensions.h12),
              _TextBlock(label: 'wallet_admin_note'.tr, text: item.adminNote!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header row: amount at the start, status (dot + text) at the end.
class _Hero extends StatelessWidget {
  final WalletWithdrawal item;

  const _Hero({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              PriceConverterHelper.convertPrice(item.amount),
              textDirection: TextDirection.ltr,
              style: textBold().copyWith(
                fontSize: Dimensions.fs32,
                height: 1.2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SizedBox(width: Dimensions.w12),
        WalletStatusLabel(
          label: item.statusText,
          color: item.statusColor,
          fontSize: Dimensions.fs14,
          dotSize: Dimensions.w8,
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outline,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Facts grid: label over value, two columns
// ═══════════════════════════════════════════════════════════════

class _FactsGrid extends StatelessWidget {
  final List<Widget> cells;

  const _FactsGrid({required this.cells});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < cells.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < cells.length ? Dimensions.h16 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cells[i]),
                SizedBox(width: Dimensions.w16),
                Expanded(
                  child: i + 1 < cells.length
                      ? cells[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;
  final bool ltr;
  final Widget? trailing;

  const _Fact({
    required this.label,
    required this.value,
    this.ltr = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textRegular().copyWith(
            fontSize: Dimensions.fs12,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.h2),
        Row(
          children: [
            Flexible(
              child: Text(
                value.trim(),
                textDirection: ltr ? TextDirection.ltr : null,
                style: textMedium().copyWith(
                  fontSize: Dimensions.fs14,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: Dimensions.w6),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }
}

/// Reference number: tap to copy (the icon turns into a check for a moment).
class _ReferenceFact extends StatefulWidget {
  final String label;
  final String value;

  const _ReferenceFact({required this.label, required this.value});

  @override
  State<_ReferenceFact> createState() => _ReferenceFactState();
}

class _ReferenceFactState extends State<_ReferenceFact> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value.trim()));
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _copy,
      child: _Fact(
        label: widget.label,
        value: widget.value,
        trailing: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          size: Dimensions.w18,
          color: _copied
              ? ManagerColors.success
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Rows
// ═══════════════════════════════════════════════════════════════

/// Payout proof: small thumbnail, tap to open it full screen.
class _ProofRow extends StatelessWidget {
  final String url;

  const _ProofRow({required this.url});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final double thumb = Dimensions.w28 * 2;

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => ImageDialogWidget(imageUrl: url),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.h12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'wallet_payout_proof'.tr,
                style: textRegular().copyWith(
                  fontSize: Dimensions.fs13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.r10),
              child: SizedBox(
                width: thumb,
                height: thumb,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return ColoredBox(
                      color: theme.scaffoldBackgroundColor,
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.w20,
                          height: Dimensions.w20,
                          child: CircularProgressIndicator(
                            strokeWidth: Dimensions.w2,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, error, __) {
                    debugPrint('PROOF image failed: $error | $url');
                    return ColoredBox(
                      color: theme.scaffoldBackgroundColor,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: Dimensions.w20,
                        color: cs.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: Dimensions.w8),
            // chevron_right mirrors itself automatically in RTL.
            Icon(
              Icons.chevron_right_rounded,
              size: Dimensions.w20,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Long text: label on top, full-width text below, optional side accent.
class _TextBlock extends StatelessWidget {
  final String label;
  final String text;
  final Color? accent;

  const _TextBlock({required this.label, required this.text, this.accent});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textRegular().copyWith(
            fontSize: Dimensions.fs12,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.h2),
        Text(
          text.trim(),
          style: textRegular().copyWith(
            fontSize: Dimensions.fs14,
            height: 1.5,
            color: cs.onSurface,
          ),
        ),
      ],
    );

    if (accent == null) return content;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: Dimensions.w2,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(Dimensions.r4),
            ),
          ),
          SizedBox(width: Dimensions.w12),
          Expanded(child: content),
        ],
      ),
    );
  }
}
