import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_drop_down_button.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_text_field_widget.dart';
import 'package:wefrh_rider/common/widgets/widget_with_label.dart';
import 'package:wefrh_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:wefrh_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/styles.dart';

void showWalletAccountSheet() {
  Get.bottomSheet(const WalletAccountSheet(),
      isScrollControlled: true, backgroundColor: Colors.transparent);
}
class WalletAccountSection extends StatelessWidget {
  const WalletAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashInHandController>(builder: (c) {
      final wallet = c.wallet;

      // لسا ما انحمّلت المحفظة (أو فشل التحميل)
      if (wallet == null) {
        return CustomCard(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w16, vertical: Dimensions.h16),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: Row(children: [
            Expanded(
              child: Text('wallet_payout_account'.tr,
                  style: textRegular().copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fs14)),
            ),
            c.walletLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => c.getWallet()),
          ]),
        );
      }

      final WalletAccount? account = wallet.accounts.isEmpty
          ? null
          : wallet.accounts.firstWhere((a) => a.isDefault,
              orElse: () => wallet.accounts.first);

      return CustomCard(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16, vertical: Dimensions.h16),
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('wallet_payout_account'.tr,
                  style: textRegular().copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fs14)),
              SizedBox(height: Dimensions.h8),
              Text(
                  account == null
                      ? 'wallet_no_account'.tr
                      : account.methodName,
                  style: textBold().copyWith(fontSize: Dimensions.fs16)),
              if (account != null && account.summary.isNotEmpty) ...[
                SizedBox(height: Dimensions.h4),
                Text(account.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textRegular().copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fs12)),
              ],
            ]),
          ),
          SizedBox(width: Dimensions.w10),
          account == null
              ? CustomButtonWidget(
                  buttonText: 'wallet_add_account'.tr,
                  autoWidth: true,
                  height: 40,
                  fontSize: Dimensions.fs14,
                  onPressed: showWalletAccountSheet,
                )
              : IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () => _confirmDelete(account.id),
                ),
        ]),
      );
    });
  }

  void _confirmDelete(int id) {
    Get.dialog(AlertDialog(
      title: Text('wallet_delete_account'.tr),
      content: Text('wallet_delete_account_confirm'.tr),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: Text('wallet_cancel'.tr)),
        TextButton(
          onPressed: () {
            Get.back();
            Get.find<CashInHandController>().deleteWalletAccount(id);
          },
          child: Text('wallet_delete'.tr),
        ),
      ],
    ));
  }
}

class WalletAccountSheet extends StatefulWidget {
  const WalletAccountSheet({super.key});

  @override
  State<WalletAccountSheet> createState() => _WalletAccountSheetState();
}

class _WalletAccountSheetState extends State<WalletAccountSheet> {
  WalletMethod? _method;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _nodes = {};

  @override
  void initState() {
    super.initState();
    final methods = Get.find<CashInHandController>().wallet?.methods ?? [];
    if (methods.isNotEmpty) _setMethod(methods.first);
  }

  void _disposeFields() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final n in _nodes.values) {
      n.dispose();
    }
    _controllers.clear();
    _nodes.clear();
  }

  void _setMethod(WalletMethod method) {
    _disposeFields();
    _method = method;
    for (final f in method.fields) {
      _controllers[f.inputName] = TextEditingController();
      _nodes[f.inputName] = FocusNode();
    }
  }

  @override
  void dispose() {
    _disposeFields();
    super.dispose();
  }

  TextInputType _keyboard(String type) {
    switch (type) {
      case 'phone':
        return TextInputType.phone;
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  Future<void> _submit() async {
    final method = _method;
    if (method == null) return;
    final Map<String, String> values = {};
    for (final f in method.fields) {
      final v = _controllers[f.inputName]!.text.trim();
      if (f.isRequired && v.isEmpty) {
        showCustomSnackBar('required_fields_can_not_be_empty'.tr);
        return;
      }
      values[f.inputName] = v;
    }
    final c = Get.find<CashInHandController>();
    final ok = await c.saveWalletAccount(
      methodId: method.id,
      fields: values,
      isDefault: c.wallet?.accounts.isEmpty ?? true,
    );
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final methods =
        Get.find<CashInHandController>().wallet?.methods ?? <WalletMethod>[];
    final fields = _method?.fields ?? <WalletMethodField>[];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w20, vertical: Dimensions.h20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(Dimensions.r20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('wallet_add_account'.tr,
                    style: textBold().copyWith(fontSize: Dimensions.fs16)),
              ),
              SizedBox(height: Dimensions.h20),
              if (methods.isEmpty)
                Text('wallet_no_methods'.tr, style: textRegular())
              else ...[
                WidgetWithLabel(
                  label: 'wallet_select_method'.tr,
                  textField: CustomDropdownButton(
                    hintText: 'wallet_select_method'.tr,
                    dropdownMenuItems: methods
                        .map((m) => DropdownMenuItem<String>(
                              value: m.id.toString(),
                              child: Text(m.methodName,
                                  style: textRegular()
                                      .copyWith(fontSize: Dimensions.fs14)),
                            ))
                        .toList(),
                    isBorder: true,
                    backgroundColor: Theme.of(context).cardColor,
                    selectedValue: _method?.id.toString(),
                    onChanged: (value) {
                      final m = methods.firstWhere(
                          (e) => e.id.toString() == value,
                          orElse: () => methods.first);
                      setState(() => _setMethod(m));
                    },
                  ),
                ),
                for (int i = 0; i < fields.length; i++) ...[
                  SizedBox(height: Dimensions.h16),
                  WidgetWithLabel(
                    label: fields[i].label,
                    textField: CustomTextFieldWidget(
                      controller: _controllers[fields[i].inputName]!,
                      labelText: fields[i].label,
                      hintText: fields[i].label,
                      inputType: _keyboard(fields[i].inputType),
                      isRequired: fields[i].isRequired,
                      focusNode: _nodes[fields[i].inputName],
                      nextFocus: i < fields.length - 1
                          ? _nodes[fields[i + 1].inputName]
                          : null,
                      inputAction: i < fields.length - 1
                          ? TextInputAction.next
                          : TextInputAction.done,
                    ),
                  ),
                ],
                SizedBox(height: Dimensions.h25),
                GetBuilder<CashInHandController>(
                  builder: (c) => CustomButtonWidget(
                    buttonText: 'save_changes'.tr,
                    isLoading: c.accountBusy,
                    onPressed: _submit,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}