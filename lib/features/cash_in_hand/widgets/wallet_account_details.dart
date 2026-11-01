import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

/// One account field: its display name and its value.
class WalletAccountField {
  final String label;
  final String value;

  const WalletAccountField({required this.label, required this.value});
}

/// Turns the account fields (key -> value) into labelled fields.
///
/// The display name of each key comes from the payout method configuration
/// (matched by input_name). If the method is not configured any more, the
/// key itself is shown in readable form (account_name -> account name).
List<WalletAccountField> walletAccountFields(
  String methodName,
  Map<String, String> fields,
) {
  final WalletModel? wallet = Get.find<CashInHandController>().wallet;
  final WalletMethod? method =
      wallet?.methods.firstWhereOrNull((m) => m.methodName == methodName);

  String labelFor(String key) =>
      method?.fields.firstWhereOrNull((f) => f.inputName == key)?.label ??
      key.replaceAll('_', ' ');

  return <WalletAccountField>[
    for (final MapEntry<String, String> e in fields.entries)
      if (e.value.trim().isNotEmpty)
        WalletAccountField(label: labelFor(e.key), value: e.value.trim()),
  ];
}

/// Account details as labelled rows (field name -> value).
class WalletAccountDetails extends StatelessWidget {
  final String methodName;
  final Map<String, String> fields;

  const WalletAccountDetails({
    super.key,
    required this.methodName,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final WalletAccountField f in walletAccountFields(methodName, fields))
          _DetailRow(label: f.label, value: f.value),
      ],
    );
  }
}

/// Field name on one side, its value on the other.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.h6),
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
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textMedium().copyWith(
                fontSize: Dimensions.fs14,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}