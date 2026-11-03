import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

class WalletAccountField {
  final String label;
  final String value;

  const WalletAccountField({required this.label, required this.value});
}

List<WalletAccountField> walletAccountFields(
  String methodName,
  Map<String, String> fields, {
  String? methodKey,
}) {
  final WalletModel? wallet = Get.find<WalletController>().wallet;

  WalletMethod? method;
  if (methodKey != null && methodKey.isNotEmpty) {
    method = wallet?.methods.firstWhereOrNull((m) => m.methodKey == methodKey);
  }
  method ??=
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
  final String? methodKey;
  final Map<String, String> fields;

  const WalletAccountDetails({
    super.key,
    required this.methodName,
    required this.fields,
    this.methodKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final WalletAccountField f
            in walletAccountFields(methodName, fields, methodKey: methodKey))
          _DetailRow(label: f.label, value: f.value),
      ],
    );
  }
}

// _DetailRow بدون أي تغيير

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
