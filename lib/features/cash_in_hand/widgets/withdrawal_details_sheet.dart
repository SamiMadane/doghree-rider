import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/image_diaglog_widget.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:doghree_rider/util/theme_extension.dart';

/// شعارات وسائل السحب (اختياري). المفتاح = جزء من اسم الوسيلة.
/// لما تجهّز الشعارات ضيفها هون، وإذا ما انضافت بتظهر أول حرف من الاسم.
/// مثال:
///   'جوال': ManagerAssets.jawwalPayLogo,
///   'فلسطين': ManagerAssets.bankOfPalestineLogo,
const Map<String, String> _methodLogos = <String, String>{};

/// نفس شيت التطبيق (showCustomBottomSheet)
void showWithdrawalDetails(WalletWithdrawal item) {
  showCustomBottomSheet(child: WithdrawalDetailsSheet(item: item));
}

String _two(int n) => n.toString().padLeft(2, '0');

String _fmt(DateTime? d) => d == null
    ? ''
    : '${d.year}-${_two(d.month)}-${_two(d.day)} '
        '${_two(d.hour)}:${_two(d.minute)}';

class WithdrawalDetailsSheet extends StatelessWidget {
  final WalletWithdrawal item;

  const WithdrawalDetailsSheet({super.key, required this.item});

  // ألوان الحالة من ManagerColors عبر ثيم التطبيق
  Color _statusColor(CustomColorsExtension c) {
    switch (item.status) {
      case 'paid':
        return c.green;
      case 'rejected':
        return c.red;
      default:
        return c.orange;
    }
  }

  String get _statusText {
    switch (item.status) {
      case 'pending':
        return 'wallet_status_pending'.tr;
      case 'paid':
        return 'wallet_status_paid'.tr;
      case 'rejected':
        return 'wallet_status_rejected'.tr;
      default:
        return item.statusLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final CustomColorsExtension colors =
        theme.extension<CustomColorsExtension>()!;
    final bool paid = item.status == 'paid';
    final bool rejected = item.status == 'rejected';
    final String? proof = item.payoutProofUrl;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.w20,
          vertical: Dimensions.h16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'wallet_withdraw_details'.tr,
                style: textBold().copyWith(fontSize: Dimensions.fs16),
              ),
            ),
            SizedBox(height: Dimensions.h20),

            // المبلغ + الحالة
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      PriceConverterHelper.convertPrice(item.amount),
                      textDirection: TextDirection.ltr,
                      style: textBold().copyWith(
                        fontSize: 34,
                        height: 1.2,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.w12),
                _StatusPill(label: _statusText, color: _statusColor(colors)),
              ],
            ),

            SizedBox(height: Dimensions.h16),
            _DashedLine(color: colors.strock1),
            SizedBox(height: Dimensions.h20),

            // سبب الرفض: كتلة كاملة العرض، تتحمل أي طول
            if (rejected && _has(item.rejectionReason)) ...[
              _TextBlock(
                label: 'wallet_rejection_reason'.tr,
                text: item.rejectionReason!,
                accent: colors.red,
              ),
              SizedBox(height: Dimensions.h20),
            ],

            // حساب السحب
            _MethodRow(name: item.methodName, summary: item.accountSummary),

            // معلومات قصيرة: عنوان + قيمة
            _InfoRow(
                label: 'wallet_requested_at'.tr,
                value: _fmt(item.requestedAt),
                ltr: true),
            if (paid)
              _InfoRow(
                  label: 'wallet_paid_at'.tr,
                  value: _fmt(item.paidAt),
                  ltr: true),
            if (paid) ...[
              _InfoRow(
                  label: 'wallet_payout_method'.tr,
                  value: item.payoutMethodLabel),
              _InfoRow(
                  label: 'wallet_reference'.tr,
                  value: item.payoutReference,
                  ltr: true),
            ],

            // ملاحظات طويلة: عنوان فوق والنص تحته
            if (_has(item.note))
              _TextBlock(label: 'wallet_note'.tr, text: item.note!),
            if ((paid || rejected) && _has(item.adminNote))
              _TextBlock(
                  label: 'wallet_admin_note'.tr, text: item.adminNote!),

            if (proof != null && proof.isNotEmpty) _Proof(url: proof),
            SizedBox(height: Dimensions.h8),
          ],
        ),
      ),
    );
  }
}

bool _has(String? v) => v != null && v.trim().isNotEmpty;

/// شارة الحالة: نفس شارات التطبيق (خلفية الحالة + نص أسفلت)
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.w12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ManagerColors.onPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: textSemiBold().copyWith(
              fontSize: Dimensions.fs13,
              color: ManagerColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// حساب السحب: دائرة (شعار أو أول حرف) + اسم الوسيلة + تفاصيل الحساب
class _MethodRow extends StatelessWidget {
  final String name;
  final String summary;
  const _MethodRow({required this.name, required this.summary});

  String? get _logo {
    for (final MapEntry<String, String> e in _methodLogos.entries) {
      if (name.contains(e.key)) return e.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty && summary.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final CustomColorsExtension colors =
        theme.extension<CustomColorsExtension>()!;
    final String? logo = _logo;

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            padding: EdgeInsets.all(logo == null ? 0 : 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: logo == null ? cs.primaryContainer : cs.surface,
              border: logo == null ? null : Border.all(color: colors.strock2),
            ),
            child: logo != null
                ? Image.asset(logo, fit: BoxFit.contain)
                : Text(
                    name.isEmpty ? '•' : String.fromCharCode(name.runes.first),
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs16,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
          ),
          SizedBox(width: Dimensions.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs14,
                      color: cs.onSurface,
                    ),
                  ),
                if (summary.isNotEmpty) ...[
                  SizedBox(height: Dimensions.h4),
                  Text(
                    summary,
                    style: textRegular().copyWith(
                      fontSize: Dimensions.fs13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// سطر قصير: العنوان بالبداية والقيمة بالنهاية
class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool ltr;
  const _InfoRow({required this.label, required this.value, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textRegular().copyWith(
              fontSize: Dimensions.fs13,
              color: cs.onSurfaceVariant,
            ),
          ),
          SizedBox(width: Dimensions.w16),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                text,
                textDirection: ltr ? TextDirection.ltr : null,
                style: textMedium().copyWith(
                  fontSize: Dimensions.fs14,
                  height: 1.4,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نص طويل: العنوان فوق والنص كامل العرض، مع خط جانبي اختياري
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
            fontSize: Dimensions.fs13,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.h4),
        Text(
          text.trim(),
          style: textMedium().copyWith(
            fontSize: Dimensions.fs14,
            height: 1.5,
            color: cs.onSurface,
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h16),
      child: accent == null
          ? content
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: Dimensions.w12),
                  Expanded(child: content),
                ],
              ),
            ),
    );
  }
}

/// إثبات الدفع
class _Proof extends StatelessWidget {
  final String url;
  const _Proof({required this.url});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'wallet_payout_proof'.tr,
          style: textRegular().copyWith(
            fontSize: Dimensions.fs13,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.h8),
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => ImageDialogWidget(imageUrl: url),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.r12),
            child: Image.network(
              url,
              width: double.infinity,
              height: Dimensions.h180,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  height: Dimensions.h180,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: Dimensions.h180,
                width: double.infinity,
                alignment: Alignment.center,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Text(
                  'wallet_proof_unavailable'.tr,
                  style: textRegular().copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// خط شحطات بسيط (Row + مربعات صغيرة)
class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double dash = 7;
        const double gap = 7;
        final int count =
            ((constraints.maxWidth + gap) / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (_) => SizedBox(
              width: dash,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}