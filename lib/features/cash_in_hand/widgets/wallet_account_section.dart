import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/common/widgets/custom_drop_down_button.dart';
import 'package:doghree_rider/common/widgets/custom_text_field_widget.dart';
import 'package:doghree_rider/common/widgets/widget_with_label.dart';
import 'package:doghree_rider/features/cash_in_hand/controllers/cash_in_hand_controller.dart';
import 'package:doghree_rider/features/cash_in_hand/domain/models/wallet_model.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

void showWalletAccountSheet() =>
    showCustomBottomSheet(child: const WalletAccountSheet());

void _confirmDeleteAccount(BuildContext context, int id) {
  showCustomBottomSheet(
    child: ConfirmationBottomSheet(
      title: 'wallet_delete_account'.tr,
      description: 'wallet_delete_account_confirm'.tr,
      acceptText: 'wallet_delete'.tr,
      acceptColor: Theme.of(context).colorScheme.error,
      cancelText: 'wallet_cancel'.tr,
      onCancel: () => Navigator.of(context).pop(),
      onAccept: () {
        Navigator.of(context).pop();
        Get.find<CashInHandController>().deleteWalletAccount(id);
      },
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// Section
// ═══════════════════════════════════════════════════════════════

class WalletAccountSection extends StatelessWidget {
  const WalletAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashInHandController>(builder: (c) {
      final wallet = c.wallet;

      // لسا ما انحمّلت المحفظة (أو فشل التحميل)
      if (wallet == null) {
        return _WalletUnavailableCard(
          isLoading: c.walletLoading,
          onRetry: () => c.getWallet(),
        );
      }

      if (wallet.accounts.isEmpty) return const _EmptyAccountCard();

      final account = wallet.accounts.firstWhere((a) => a.isDefault,
          orElse: () => wallet.accounts.first);
      final method = wallet.methods
          .firstWhereOrNull((m) => m.methodName == account.methodName);

      return _AccountCard(
        account: account,
        fieldLabels: method?.fields.map((f) => f.label).toList(),
        onDelete: () => _confirmDeleteAccount(context, account.id),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// Shared bits
// ═══════════════════════════════════════════════════════════════

class _WalletCard extends StatelessWidget {
  final Widget child;

  const _WalletCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(Dimensions.w16),
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'wallet_payout_account'.tr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textMedium().copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: Dimensions.fs14,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Cards
// ═══════════════════════════════════════════════════════════════

class _WalletUnavailableCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const _WalletUnavailableCard({
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return _WalletCard(
      child: Row(
        children: [
          const Expanded(child: _CardTitle()),
          if (isLoading)
            SizedBox(
              width: Dimensions.w20,
              height: Dimensions.h20,
              child: CircularProgressIndicator(strokeWidth: Dimensions.w2),
            )
          else
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.refresh, color: scheme.onSurfaceVariant),
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}

class _EmptyAccountCard extends StatelessWidget {
  const _EmptyAccountCard();

  @override
  Widget build(BuildContext context) {
    return _WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(),
          SizedBox(height: Dimensions.h12),
          Text(
            'wallet_no_account'.tr,
            style: textBold().copyWith(
              fontSize: Dimensions.fs20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: Dimensions.h12),
          CustomButtonWidget(
            buttonText: 'wallet_add_account'.tr,
            height: Dimensions.h40,
            radius: Dimensions.r20,
            fontSize: Dimensions.fs14,
            onPressed: showWalletAccountSheet,
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final WalletAccount account;

  /// أسماء الحقول بنفس ترتيب القيم في summary (ممكن تكون null)
  final List<String>? fieldLabels;
  final VoidCallback onDelete;

  const _AccountCard({
    required this.account,
    required this.onDelete,
    this.fieldLabels,
  });

  @override
  Widget build(BuildContext context) {
    // القيم مفصولة بـ "·" مثل: sami madane · palestine · 41179854
    final List<String> values = account.summary
        .split('·')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // نربط الاسم بالقيمة فقط إذا العدد متطابق
    final List<String>? labels =
        fieldLabels?.length == values.length ? fieldLabels : null;

    return _WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AccountHeader(onDelete: onDelete),
          SizedBox(height: Dimensions.h12),
          _MethodRow(name: account.methodName),
          if (values.isNotEmpty) SizedBox(height: Dimensions.h12),
          for (int i = 0; i < values.length; i++)
            _DetailRow(label: labels?[i], value: values[i]),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  final VoidCallback onDelete;

  const _AccountHeader({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _CardTitle()),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: onDelete,
          child: Padding(
            padding: EdgeInsets.all(Dimensions.w4),
            child: Icon(
              Icons.delete_outline,
              size: Dimensions.w22,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  final String name;

  const _MethodRow({required this.name});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.w8),
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            ManagerAssets.walletWithdrawIcon,
            width: Dimensions.w24,
            height: Dimensions.h24,
            colorFilter: ColorFilter.mode(ManagerColors.black, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: Dimensions.w12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              name,
              style: textBold().copyWith(
                fontSize: Dimensions.fs20,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// صف تفصيلة: اسم الحقل ع جهة وقيمته ع الجهة الثانية.
/// إذا ما في label بنعرض القيمة لحالها.
class _DetailRow extends StatelessWidget {
  final String? label;
  final String value;

  const _DetailRow({required this.value, this.label});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.h4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: textRegular().copyWith(
                fontSize: Dimensions.fs13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: Dimensions.w16),
          ],
          Expanded(
            child: Text(
              value,
              textAlign: label != null ? TextAlign.end : TextAlign.start,
              style: textMedium().copyWith(
                fontSize: Dimensions.fs14,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Add-account sheet
// ═══════════════════════════════════════════════════════════════

class WalletAccountSheet extends StatefulWidget {
  const WalletAccountSheet({super.key});

  @override
  State<WalletAccountSheet> createState() => _WalletAccountSheetState();
}

class _WalletAccountSheetState extends State<WalletAccountSheet> {
  // حروف من أي لغة + تشكيل + مسافة + . ' - ، بدون أرقام أو رموز
  static final RegExp _nameRegex =
      RegExp(r"^[\p{L}\p{M}\s.'’\-]+$", unicode: true);

  final CashInHandController _controller = Get.find<CashInHandController>();

  WalletMethod? _method;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _nodes = {};
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    final methods = _controller.wallet?.methods ?? [];
    if (methods.isNotEmpty) _setMethod(methods.first);
    // امسح أي خطأ سيرفر قديم من فتحة سابقة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.clearAccountError();
    });
  }

  @override
  void dispose() {
    _disposeFields();
    super.dispose();
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
    _errors.clear();
  }

  void _setMethod(WalletMethod method) {
    _disposeFields();
    _method = method;
    for (final f in method.fields) {
      _controllers[f.inputName] = TextEditingController();
      _nodes[f.inputName] = FocusNode();
    }
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

  /// يرجّع رسالة الخطأ أو null إذا الحقل سليم
  String? _validate(WalletMethodField f, String value) {
    if (value.isEmpty) {
      return f.isRequired ? 'required_fields_can_not_be_empty'.tr : null;
    }
    final bool isName = f.inputName.toLowerCase().contains('name');
    if (isName && !_nameRegex.hasMatch(value)) {
      return 'wallet_name_invalid'.tr;
    }
    return null;
  }

  Future<void> _submit() async {
    final method = _method;
    if (method == null) return;

    final Map<String, String> values = {};
    final Map<String, String?> errors = {};

    for (final f in method.fields) {
      final value = _controllers[f.inputName]!.text.trim();
      final error = _validate(f, value);
      if (error != null) errors[f.inputName] = error;
      values[f.inputName] = value;
    }

    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      _nodes[errors.keys.first]?.requestFocus();
      return;
    }
    setState(_errors.clear);

    final ok = await _controller.saveWalletAccount(
      methodId: method.id,
      fields: values,
      isDefault: _controller.wallet?.accounts.isEmpty ?? true,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  void _onMethodChanged(WalletMethod method) {
    _controller.clearAccountError();
    setState(() => _setMethod(method));
  }

  void _onFieldChanged(String inputName) {
    if (_errors[inputName] != null) {
      setState(() => _errors[inputName] = null);
    }
    _controller.clearAccountError();
  }

  Widget _buildField(List<WalletMethodField> fields, int i) {
    final f = fields[i];
    final bool isLast = i == fields.length - 1;

    return Padding(
      padding: EdgeInsets.only(top: Dimensions.h16),
      child: WidgetWithLabel(
        label: f.label,
        // بدون labelText: الـ label فوق الحقل كافي
        textField: CustomTextFieldWidget(
          controller: _controllers[f.inputName]!,
          hintText: f.label,
          inputType: _keyboard(f.inputType),
          isRequired: f.isRequired,
          focusNode: _nodes[f.inputName],
          errorText: _errors[f.inputName],
          onChanged: (_) => _onFieldChanged(f.inputName),
          nextFocus: isLast ? null : _nodes[fields[i + 1].inputName],
          inputAction: isLast ? TextInputAction.done : TextInputAction.next,
        ),
      ),
    );
  }

  List<Widget> _buildForm(
    CashInHandController c,
    List<WalletMethod> methods,
  ) {
    final fields = _method?.fields ?? <WalletMethodField>[];
    final String? serverError = c.accountError;

    return [
      _MethodDropdown(
        methods: methods,
        selected: _method,
        onChanged: _onMethodChanged,
      ),
      for (int i = 0; i < fields.length; i++) _buildField(fields, i),
      SizedBox(height: Dimensions.h25),
      if (serverError != null) ...[
        Text(
          serverError,
          textAlign: TextAlign.center,
          style: textRegular().copyWith(
            color: Theme.of(context).colorScheme.error,
            fontSize: Dimensions.fs12,
          ),
        ),
        SizedBox(height: Dimensions.h8),
      ],
      CustomButtonWidget(
        buttonText: 'save_changes'.tr,
        isLoading: c.accountBusy,
        onPressed: _submit,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return GetBuilder<CashInHandController>(builder: (c) {
      final methods = c.wallet?.methods ?? <WalletMethod>[];
      if (_method == null && methods.isNotEmpty) _setMethod(methods.first);

      // الـ handle والخلفية وزر الإغلاق من showCustomBottomSheet
      return Flexible(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    'wallet_add_account'.tr,
                    style: textBold().copyWith(
                      fontSize: Dimensions.fs16,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.h20),
                if (methods.isEmpty)
                  Text(
                    'wallet_no_methods'.tr,
                    style: textRegular().copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: Dimensions.fs14,
                    ),
                  )
                else
                  ..._buildForm(c, methods),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _MethodDropdown extends StatelessWidget {
  final List<WalletMethod> methods;
  final WalletMethod? selected;
  final ValueChanged<WalletMethod> onChanged;

  const _MethodDropdown({
    required this.methods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return WidgetWithLabel(
      label: 'wallet_select_method'.tr,
      textField: CustomDropdownButton(
        hintText: 'wallet_select_method'.tr,
        dropdownMenuItems: methods
            .map((m) => DropdownMenuItem<String>(
                  value: m.id.toString(),
                  child: Text(
                    m.methodName,
                    style: textRegular().copyWith(
                      fontSize: Dimensions.fs14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ))
            .toList(),
        isBorder: true,
        backgroundColor: theme.cardColor,
        selectedValue: selected?.id.toString(),
        onChanged: (value) => onChanged(methods.firstWhere(
          (m) => m.id.toString() == value,
          orElse: () => methods.first,
        )),
      ),
    );
  }
}