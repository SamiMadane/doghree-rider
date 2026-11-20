import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/widgets/order_item_widget.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/splash/domain/services/splash_service_interface.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _ConfigService implements SplashServiceInterface {
  final Response response;
  _ConfigService(this.response);

  @override
  Future<Response> getConfigData() async => response;

  @override
  Future<bool> initSharedData() async => true;

  @override
  Future<bool> removeSharedData() async => true;
}

Map<String, dynamic> _config({Object? moduleConfig}) => {
      'currency_symbol': r'$',
      'toggle_veg_non_veg': true,
      if (moduleConfig != null) 'module_config': moduleConfig,
    };

Future<SplashController> _loaded(Map<String, dynamic> body) async {
  final controller = SplashController(
      navigationHandlerServiceInterface:
          _ConfigService(Response(statusCode: 200, body: body)));
  expect(await controller.getConfigData(), isTrue);
  return controller;
}

void main() {
  tearDown(Get.reset);

  group('getModule never throws (audit row 30)', () {
    test('S1 a null or unknown module type gives the empty fallback',
        () async {
      final c = await _loaded(_config(moduleConfig: {
        'module_type': ['grocery'],
        'grocery': {'unit': true, 'veg_non_veg': false},
      }));

      final nullType = c.getModule(null);
      final unknown = c.getModule('no_such_module');

      expect(nullType.unit, isNull);
      expect(nullType.vegNonVeg, isNull);
      expect(unknown.unit, isNull);
    });

    test('S2 getModule before the config has loaded gives the fallback', () {
      final c = SplashController(
          navigationHandlerServiceInterface:
              _ConfigService(const Response(statusCode: 500)));
      expect(c.getModule('grocery').unit, isNull);
      expect(c.getModule(null).unit, isNull);
    });

    test('S3 a config without module_config, or a broken entry, gives the fallback',
        () async {
      final none = await _loaded(_config());
      expect(none.getModule('grocery').unit, isNull);

      final broken = await _loaded(_config(moduleConfig: {
        'module_type': ['grocery'],
        'grocery': 'not a map',
      }));
      expect(broken.getModule('grocery').unit, isNull);

      final wrongType = await _loaded(_config(moduleConfig: 'oops'));
      expect(wrongType.getModule('grocery').unit, isNull);
    });

    test('G4 a configured module still returns its flags', () async {
      final c = await _loaded(_config(moduleConfig: {
        'module_type': ['grocery'],
        'grocery': {'unit': true, 'veg_non_veg': false, 'order_attachment': true},
      }));

      final module = c.getModule('grocery');

      expect(module.unit, isTrue);
      expect(module.vegNonVeg, isFalse);
      expect(module.orderAttachment, isTrue);
    });
  });

  group('the item row never shows a red screen (audit row 30)', () {
    Future<void> pumpItem(WidgetTester tester, String? moduleType) async {
      final controller = await _loaded(_config(moduleConfig: {
        'module_type': ['grocery'],
        'grocery': {'unit': true, 'veg_non_veg': true},
      }));
      Get.put<SplashController>(controller);

      final order = OrderModel(id: 1, moduleType: moduleType, detailsCount: 1);
      final line = OrderDetailsModel(
        id: 1,
        price: 10,
        discountOnItem: 0,
        quantity: 2,
        variation: [],
        foodVariation: [],
        itemDetails: ItemDetails(name: 'Milk', unitType: 'L', veg: 1),
      );

      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(376, 812),
        builder: (_, __) => GetMaterialApp(
          theme: light,
          home: Scaffold(
            body: OrderItemWidget(order: order, orderDetails: line),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('W1 a null module_type builds the row without the unit tag',
        (tester) async {
      await pumpItem(tester, null);

      expect(tester.takeException(), isNull);
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('L'), findsNothing);
    });

    testWidgets('W1b an unknown module_type builds the row too',
        (tester) async {
      await pumpItem(tester, 'no_such_module');

      expect(tester.takeException(), isNull);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('G12 a configured module shows its unit tag', (tester) async {
      await pumpItem(tester, 'grocery');

      expect(tester.takeException(), isNull);
      expect(find.text('L'), findsOneWidget);
    });
  });
}
