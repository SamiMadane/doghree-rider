import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/splash/domain/services/splash_service_interface.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:doghree_rider/features/wallet/domain/models/wallet_model.dart';
import 'package:doghree_rider/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:doghree_rider/features/wallet/widgets/balance_overviwe_section.dart';
import 'package:doghree_rider/features/wallet/widgets/wallet_withdraw_sheet.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// D-10 owner decision Q1: the server decides the balance rules. The button
/// follows only `can_request_withdraw` / `withdraw_block`, and an amount above
/// the shown balance is a hint that never blocks the request.

class _WalletService implements WalletServiceInterface {
  WalletModel? next;

  @override
  Future<WalletModel?> getWallet() async => next;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ConfigService implements SplashServiceInterface {
  @override
  Future<Response> getConfigData() async =>
      Response(statusCode: 200, body: {'currency_symbol': r'$'});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoProfileService implements ProfileServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletModel _wallet({required double balance, bool canRequest = true}) =>
    WalletModel.fromJson({
      'available_balance': balance,
      'total_earning': 10,
      'can_request_withdraw': canRequest,
      'accounts': [
        {
          'id': 3,
          'withdrawal_method_id': 1,
          'method_name': 'Bank',
          'fields': {'iban': 'x'},
          'is_default': true,
        }
      ],
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _WalletService walletService;

  setUp(() async {
    Get.testMode = false;
    walletService = _WalletService();
    Get.put(WalletController(walletServiceInterface: walletService));
    final splash = SplashController(
        navigationHandlerServiceInterface: _ConfigService());
    await splash.getConfigData();
    Get.put(splash);
  });

  tearDown(() {
    Get.reset();
    Get.testMode = true;
  });

  Future<void> load(WalletModel wallet) async {
    walletService.next = wallet;
    await Get.find<WalletController>().getWallet();
  }

  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(376, 812) * 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(376, 812),
      builder: (_, __) => GetMaterialApp(
        theme: light,
        home: Scaffold(body: SingleChildScrollView(child: home)),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Q1a balance 0 but the server allows it: the button opens the sheet',
      (tester) async {
    await load(_wallet(balance: 0));
    await pumpApp(
        tester,
        BalanceOverviewSection(
            profileController:
                ProfileController(profileServiceInterface: _NoProfileService())));

    await tester.tap(find.text('wallet_request_withdraw'));
    await tester.pumpAndSettle();

    expect(find.byType(WalletWithdrawSheet), findsOneWidget);
  });

  testWidgets('Q1b (guard) the server blocks it: the button opens no sheet',
      (tester) async {
    await load(_wallet(balance: 50, canRequest: false));
    await pumpApp(
        tester,
        BalanceOverviewSection(
            profileController:
                ProfileController(profileServiceInterface: _NoProfileService())));

    await tester.tap(find.text('wallet_request_withdraw'));
    await tester.pumpAndSettle();

    expect(find.byType(WalletWithdrawSheet), findsNothing);
  });

  testWidgets('Q1c an amount above the balance shows a hint while typing',
      (tester) async {
    await load(_wallet(balance: 10));
    await pumpApp(tester, const WalletWithdrawSheet());

    await tester.enterText(find.byType(TextField).first, '50');
    await tester.pump();

    expect(find.text('wallet_withdraw_exceeds'), findsOneWidget);
  });

  testWidgets('Q1d an amount above the balance still reaches the confirm step',
      (tester) async {
    await load(_wallet(balance: 10));
    await pumpApp(tester, const WalletWithdrawSheet());

    await tester.enterText(find.byType(TextField).first, '50');
    await tester.pump();
    await tester.ensureVisible(find.text('wallet_withdraw_submit'));
    await tester.tap(find.text('wallet_withdraw_submit'));
    await tester.pumpAndSettle();

    expect(find.text('wallet_withdraw_confirm_title'), findsOneWidget);
  });

  testWidgets('Q1e (guard) an amount within the balance shows no hint',
      (tester) async {
    await load(_wallet(balance: 10));
    await pumpApp(tester, const WalletWithdrawSheet());

    await tester.enterText(find.byType(TextField).first, '5');
    await tester.pump();

    expect(find.text('wallet_withdraw_exceeds'), findsNothing);
  });
}
