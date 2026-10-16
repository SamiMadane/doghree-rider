double _num(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
bool _bool(dynamic v) => v == true || v == 1 || v == '1';

class WalletModel {
  final double availableBalance;
  final double totalEarning;
  final double totalWithdrawn;
  final double pendingWithdraw;
  final double cashInHand;
  final double riderSharePercent;
  final String? weekStart;
  final String? weekEnd;
  final bool canRequestWithdraw;
  final WithdrawBlock? withdrawBlock;
  final List<WalletAccount> accounts;
  final List<WalletMethod> methods;

  WalletModel({
    required this.availableBalance,
    required this.totalEarning,
    required this.totalWithdrawn,
    required this.pendingWithdraw,
    required this.cashInHand,
    required this.riderSharePercent,
    this.weekStart,
    this.weekEnd,
    required this.canRequestWithdraw,
    this.withdrawBlock,
    this.accounts = const [],
    this.methods = const [],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final block = json['withdraw_block'];
    final accounts = json['accounts'];
    final methods = json['methods'];
    return WalletModel(
      availableBalance: _num(json['available_balance']),
      totalEarning: _num(json['total_earning']),
      totalWithdrawn: _num(json['total_withdrawn']),
      pendingWithdraw: _num(json['pending_withdraw']),
      cashInHand: _num(json['cash_in_hand']),
      riderSharePercent: _num(json['rider_share_percent']),
      weekStart: json['week_start']?.toString(),
      weekEnd: json['week_end']?.toString(),
      canRequestWithdraw: _bool(json['can_request_withdraw']),
      withdrawBlock: block is Map
          ? WithdrawBlock(
              code: block['code']?.toString(),
              message: block['message']?.toString())
          : null,
      accounts: accounts is List
          ? accounts
              .whereType<Map>()
              .map((e) => WalletAccount.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <WalletAccount>[],
      methods: methods is List
          ? methods
              .whereType<Map>()
              .map((e) => WalletMethod.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <WalletMethod>[],
    );
  }
}

class WithdrawBlock {
  final String? code;
  final String? message;
  WithdrawBlock({this.code, this.message});
}

class WalletAccount {
  final int id;
  final int withdrawalMethodId;
  final String methodName;
  final Map<String, String> fields;
  final bool isDefault;

  WalletAccount({
    required this.id,
    required this.withdrawalMethodId,
    required this.methodName,
    required this.fields,
    required this.isDefault,
  });

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    final raw = json['fields'];
    return WalletAccount(
      id: int.tryParse('${json['id']}') ?? 0,
      withdrawalMethodId: int.tryParse('${json['withdrawal_method_id']}') ?? 0,
      methodName: json['method_name']?.toString() ?? '',
      fields: raw is Map
          ? raw.map((k, v) => MapEntry('$k', '${v ?? ''}'))
          : <String, String>{},
      isDefault: _bool(json['is_default']),
    );
  }

  String get summary => fields.values.where((v) => v.isNotEmpty).join(' · ');
}

class WalletMethod {
  final int id;
  final String methodName;
  final List<WalletMethodField> fields;

  WalletMethod({required this.id, required this.methodName, required this.fields});

  factory WalletMethod.fromJson(Map<String, dynamic> json) {
    final raw = json['fields'];
    return WalletMethod(
      id: int.tryParse('${json['id']}') ?? 0,
      methodName: json['method_name']?.toString() ?? '',
      fields: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => WalletMethodField.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <WalletMethodField>[],
    );
  }
}

class WalletMethodField {
  final String inputName;
  final String inputType;
  final String placeholder;
  final bool isRequired;

  WalletMethodField({
    required this.inputName,
    required this.inputType,
    required this.placeholder,
    required this.isRequired,
  });

  factory WalletMethodField.fromJson(Map<String, dynamic> json) =>
      WalletMethodField(
        inputName: json['input_name']?.toString() ?? '',
        inputType: json['input_type']?.toString() ?? 'string',
        placeholder: json['placeholder']?.toString() ?? '',
        isRequired: _bool(json['is_required']),
      );

  String get label =>
      placeholder.isNotEmpty ? placeholder : inputName.replaceAll('_', ' ');
}