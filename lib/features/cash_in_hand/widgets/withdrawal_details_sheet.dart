
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/image_diaglog_widget.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/models/wallet_withdrawal_model.dart';
import 'package:wefrh_rider/helper/price_converter_helper.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

void showWithdrawalDetails(WalletWithdrawal item) {
  Get.bottomSheet(
    WithdrawalDetailsSheet(item: item),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

String _two(int n) => n.toString().padLeft(2, '0');

String _fmt(DateTime? d) => d == null
    ? ''
    : '${d.year}-${_two(d.month)}-${_two(d.day)} '
        '${_two(d.hour)}:${_two(d.minute)}';

class WithdrawalDetailsSheet extends StatelessWidget {
  final WalletWithdrawal item;

  const WithdrawalDetailsSheet({
    super.key,
    required this.item,
  });

  Color _statusColor(BuildContext context) {
    switch (item.status) {
      case 'paid':
        return const Color(0xFF15966A);
      case 'rejected':
        return const Color(0xFFE05252);
      default:
        return const Color(0xFFE99A27);
    }
  }

  IconData _statusIcon() {
    switch (item.status) {
      case 'paid':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.schedule_rounded;
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

  Widget _sectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: Dimensions.w8),
          Text(
            title,
            style: textSemiBold().copyWith(
              fontSize: Dimensions.fs14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required String label,
    required String? value,
    IconData? icon,
    bool ltr = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.h16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: theme.hintColor,
            ),
            SizedBox(width: Dimensions.w10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textRegular().copyWith(
                    fontSize: Dimensions.fs12,
                    color: theme.hintColor,
                  ),
                ),
                SizedBox(height: Dimensions.h4),
                Text(
                  value,
                  textDirection: ltr ? TextDirection.ltr : null,
                  textAlign: ltr ? TextAlign.start : null,
                  style: textMedium().copyWith(
                    fontSize: Dimensions.fs14,
                    height: 1.4,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.w16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.r16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.35),
        ),
      ),
      child: child,
    );
  }

  Widget _buildProof(BuildContext context, String proof) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          'wallet_payout_proof'.tr,
          Icons.receipt_long_rounded,
        ),
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => ImageDialogWidget(imageUrl: proof),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.r12),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.network(
                  proof,
                  width: double.infinity,
                  height: Dimensions.h180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return SizedBox(
                      height: Dimensions.h180,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: Dimensions.h180,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: theme.hintColor,
                        ),
                        SizedBox(height: Dimensions.h8),
                        Text(
                          'wallet_proof_unavailable'.tr,
                          style: textRegular().copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.h10,
                    ),
                    color: Colors.black.withOpacity(0.55),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: Dimensions.w6),
                        Text(
                          'wallet_payout_proof'.tr,
                          style: textMedium().copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fs12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(context);
    final proof = item.payoutProofUrl;

    final account = [
      item.methodName,
      item.accountSummary,
    ].where((value) => value.isNotEmpty).join(' · ');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.r24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: Dimensions.h12,
                bottom: Dimensions.h8,
              ),
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w20,
                vertical: Dimensions.h8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(
                        Dimensions.r12,
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: theme.colorScheme.primary,
                      size: 23,
                    ),
                  ),
                  SizedBox(width: Dimensions.w12),
                  Expanded(
                    child: Text(
                      'wallet_withdraw_details'.tr,
                      style: textBold().copyWith(
                        fontSize: Dimensions.fs16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.dividerColor.withOpacity(0.4),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Dimensions.w20,
                  Dimensions.h16,
                  Dimensions.w20,
                  Dimensions.h24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount and status
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Dimensions.w20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.055),
                        borderRadius: BorderRadius.circular(
                          Dimensions.r16,
                        ),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'wallet_withdraw_details'.tr,
                            style: textRegular().copyWith(
                              color: theme.hintColor,
                              fontSize: Dimensions.fs12,
                            ),
                          ),
                          SizedBox(height: Dimensions.h8),
                          Text(
                            PriceConverterHelper.convertPrice(item.amount),
                            textDirection: TextDirection.ltr,
                            style: textBold().copyWith(
                              fontSize: Dimensions.fs24,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: Dimensions.h16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.w12,
                              vertical: Dimensions.h8,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _statusIcon(),
                                  size: 17,
                                  color: statusColor,
                                ),
                                SizedBox(width: Dimensions.w6),
                                Text(
                                  _statusText,
                                  style: textSemiBold().copyWith(
                                    color: statusColor,
                                    fontSize: Dimensions.fs12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimensions.h20),

                    // Request information
                    _sectionCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            context,
                            'wallet_withdraw_details'.tr,
                            Icons.receipt_outlined,
                          ),
                          _detailRow(
                            context,
                            label: 'wallet_requested_at'.tr,
                            value: _fmt(item.requestedAt),
                            icon: Icons.calendar_today_outlined,
                            ltr: true,
                          ),
                          if (item.status == 'paid')
                            _detailRow(
                              context,
                              label: 'wallet_paid_at'.tr,
                              value: _fmt(item.paidAt),
                              icon: Icons.event_available_outlined,
                              ltr: true,
                            ),
                          _detailRow(
                            context,
                            label: 'wallet_account'.tr,
                            value: account,
                            icon: Icons.account_balance_outlined,
                          ),
                          _detailRow(
                            context,
                            label: 'wallet_note'.tr,
                            value: item.note,
                            icon: Icons.sticky_note_2_outlined,
                          ),
                          if (item.status == 'paid') ...[
                            _detailRow(
                              context,
                              label: 'wallet_payout_method'.tr,
                              value: item.payoutMethodLabel,
                              icon: Icons.payments_outlined,
                            ),
                            _detailRow(
                              context,
                              label: 'wallet_reference'.tr,
                              value: item.payoutReference,
                              icon: Icons.tag_rounded,
                              ltr: true,
                            ),
                            _detailRow(
                              context,
                              label: 'wallet_admin_note'.tr,
                              value: item.adminNote,
                              icon: Icons.support_agent_rounded,
                            ),
                          ],
                          if (item.status == 'rejected') ...[
                            _detailRow(
                              context,
                              label: 'wallet_rejection_reason'.tr,
                              value: item.rejectionReason,
                              icon: Icons.info_outline_rounded,
                            ),
                            _detailRow(
                              context,
                              label: 'wallet_admin_note'.tr,
                              value: item.adminNote,
                              icon: Icons.support_agent_rounded,
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (proof != null && proof.isNotEmpty) ...[
                      SizedBox(height: Dimensions.h20),
                      _buildProof(context, proof),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
