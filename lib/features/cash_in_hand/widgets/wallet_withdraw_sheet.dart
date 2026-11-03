import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_text_field_widget.dart';
import 'package:doghree_rider/common/widgets/widget_with_label.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/cash_in_hand/widgets/wallet_common_widgets.dart';
import 'package:doghree_rider/helper/price_converter_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/styles.dart';

void showWithdrawSheet() {
  Get.bottomSheet(const WalletWithdrawSheet(),
      isScrollControlled: true, backgroundColor: Colors.transparent);
}

class WalletWithdrawSheet extends StatefulWidget {
  const WalletWithdrawSheet({super.key});

  @override
  State<WalletWithdrawSheet> createState() => _WalletWithdrawSheetState();
}

class _WalletWithdrawSheetState extends State<WalletWithdrawSheet> {
  late final TextEditingController _amount;
  final TextEditingController _note = TextEditingController();
  final FocusNode _amountNode = FocusNode();
  final FocusNode _noteNode = FocusNode();
  String? _amountError;
  String? _formError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final available =
        Get.find<CashInHandController>().wallet?.availableBalance ?? 0;
    _amount = TextEditingController(text: available.toStringAsFixed(2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CashInHandController>().clearWithdrawError();
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _amountNode.dispose();
    _noteNode.dispose();
    super.dispose();
  }

  /// يقبل أرقاماً عربية وبنغالية وفاصلة عشرية بأشكالها
  double? _parse(String raw) {
    var s = raw.trim().replaceAll(',', '.').replaceAll('٫', '.');
    const ar = '٠١٢٣٤٥٦٧٨٩';
    const bn = '০১২৩৪৫৬৭৮৯';
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(ar[i], '$i').replaceAll(bn[i], '$i');
    }
    return double.tryParse(s);
  }

  Future<void> _submit() async {
    final c = Get.find<CashInHandController>();
    final WalletModel? w = c.wallet;
    if (w == null) return;
    final WalletAccount? account = w.defaultAccount;
    if (account == null) {
      setState(() => _formError = 'wallet_withdraw_add_account_first'.tr);
      return;
    }
    final double? parsed = _parse(_amount.text);
    if (parsed == null || parsed <= 0) {
      setState(() => _amountError = 'wallet_withdraw_invalid_amount'.tr);
      return;
    }
    final double amount = double.parse(parsed.toStringAsFixed(2));
    if (amount > w.availableBalance + 0.0001) {
      setState(() => _amountError = 'wallet_withdraw_exceeds'.tr);
      return;
    }
    setState(() {
      _amountError = null;
      _formError = null;
    });

    final bool? confirmed = await Get.dialog<bool>(AlertDialog(
      // هوامش أقل = ديالوج أعرض (الافتراضي 40)
      insetPadding: EdgeInsets.symmetric(horizontal: Dimensions.w16),
      title: Text('wallet_withdraw_confirm_title'.tr),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(PriceConverterHelper.convertPrice(amount),
                style: textBold().copyWith(fontSize: Dimensions.fs18),
                textDirection: TextDirection.ltr),
            SizedBox(height: Dimensions.h10),
            Text('${'wallet_withdraw_to'.tr}: ${account.methodName}',
                style: textMedium()),
            if (account.summary.isNotEmpty)
              Text(account.summary, style: textRegular()),
            SizedBox(height: Dimensions.h16),
            Text(
              'wallet_withdraw_confirm_note'.tr,
              style: textMedium().copyWith(
                fontSize: Dimensions.fs13,
                height: 1.5,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('wallet_cancel'.tr)),
        CustomButtonWidget(
          buttonText: 'wallet_withdraw_submit'.tr,
          autoWidth: true,
          onPressed: () => Get.back(result: true),
        ),
      ],
    ));
    if (confirmed != true || !mounted) return;

    final bool ok = await c.requestWithdraw(
      amount: amount,
      accountId: account.id,
      note: _note.text,
    );
    if (!ok || !mounted) return;

    // الزر يضل بحالة تحميل لحد ما تسكّر. Navigator بدل Get.back():
    // هاي بتسكّر الـ snackbar المفتوح (رسالة النجاح) بدل الـ sheet.
    setState(() => _submitted = true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return GetBuilder<CashInHandController>(builder: (c) {
      final WalletAccount? account = c.wallet?.defaultAccount;
      final String? serverError = c.withdrawError;

      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w20, vertical: Dimensions.h20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(Dimensions.r20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('wallet_request_withdraw'.tr,
                      style: textBold().copyWith(fontSize: Dimensions.fs16)),
                ),
                SizedBox(height: Dimensions.h20),
                if (account != null) ...[
                  Text('wallet_withdraw_to'.tr,
                      style: textMedium().copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: Dimensions.fs14)),
                  SizedBox(height: Dimensions.h8),
                  CustomCard(
                    padding: EdgeInsets.all(Dimensions.w16),
                    fillColor: theme.scaffoldBackgroundColor,
                    child: WalletMethodHeader(
                      name: account.methodName,
                      logoUrl: account.logoUrl,
                      subtitle: account.summary,
                      size: Dimensions.w20 * 2.4,
                    ),
                  ),
                  SizedBox(height: Dimensions.h16),
                ],
                WidgetWithLabel(
                  label: 'wallet_withdraw_amount'.tr,
                  textField: CustomTextFieldWidget(
                    controller: _amount,
                    labelText: 'wallet_withdraw_amount'.tr,
                    hintText: '0.00',
                    inputType:
                        const TextInputType.numberWithOptions(decimal: true),
                    errorText: _amountError,
                    onChanged: (_) {
                      if (_amountError != null) {
                        setState(() => _amountError = null);
                      }
                      if (_formError != null) {
                        setState(() => _formError = null);
                      }
                      c.clearWithdrawError();
                    },
                    isRequired: true,
                    focusNode: _amountNode,
                    nextFocus: _noteNode,
                    inputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: Dimensions.h8),
                Text('wallet_withdraw_one_per_week'.tr,
                    style: textRegular().copyWith(
                        color: theme.hintColor, fontSize: Dimensions.fs12)),
                SizedBox(height: Dimensions.h16),
                WidgetWithLabel(
                  label: 'wallet_withdraw_note'.tr,
                  textField: CustomTextFieldWidget(
                    controller: _note,
                    labelText: 'wallet_withdraw_note'.tr,
                    hintText: 'wallet_withdraw_note'.tr,
                    inputType: TextInputType.text,
                    focusNode: _noteNode,
                    inputAction: TextInputAction.done,
                  ),
                ),
                SizedBox(height: Dimensions.h25),
                if ((_formError ?? serverError) != null) ...[
                  Text((_formError ?? serverError)!,
                      style: textRegular().copyWith(
                          color: scheme.error, fontSize: Dimensions.fs12)),
                  SizedBox(height: Dimensions.h8),
                ],
                CustomButtonWidget(
                  buttonText: 'wallet_withdraw_submit'.tr,
                  isLoading: c.withdrawBusy || _submitted,
                  onPressed: _submitted ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}