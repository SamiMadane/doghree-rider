import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/common/widgets/load_failed_widget.dart';
import 'package:doghree_rider/common/widgets/session_expired_bottom_sheet.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/auth/domain/services/auth_service_interface.dart';
import 'package:doghree_rider/features/dashboard/widgets/lottie_bottom_sheet_order_request.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/order/widgets/info_card_section.dart';
import 'package:doghree_rider/features/order/widgets/location_card_widget.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/request_path_harness.dart';

/// Audit rows 94-100 (D-16): the request card and Order Details failure
/// paths. Every accept and ignore goes through the real confirm sheet with
/// real taps; only the HTTP transport is faked.
class _LoggedInAuthService implements AuthServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    switch (invocation.memberName) {
      case #isNotificationActive:
      case #isLoggedIn:
        return true;
      case #clearSharedData:
        return Future<bool>.value(true);
    }
    return super.noSuchMethod(invocation);
  }
}

/// The alarm of the push sheet never reaches a platform player in tests.
class _HeldAudioCache extends AudioCache {
  @override
  Future<String> loadPath(String fileName) => Completer<String>().future;
}

const Reply _serverError = Reply(500, {
  'errors': [
    {'code': 'server', 'message': 'Server error'}
  ]
});

Map<String, dynamic> _line({Object? itemDetails, Object? price = 10}) => {
      'id': 1,
      'order_id': 101,
      'item_details': itemDetails,
      'price': price,
      'quantity': 1,
      'discount_on_item': 0,
      'variation': [],
      'add_ons': [],
    };

void main() {
  final Harness h = Harness();

  Future<void> tapAccept(WidgetTester t, {int card = 0}) async {
    await t.tap(find.text('accept').at(card));
    await settle(t, 3);
    await t.tap(find.text('yes_accept'));
    await settle(t);
  }

  /// Accept from the list card with a running list already loaded, so the
  /// real Order Details opens and loads through the stubs.
  Future<void> acceptedOrder(WidgetTester t,
      {required Reply fetch, Reply details = const Reply(200, [])}) async {
    await h.setUp(t);
    h.api.on(AppConstants.currentOrdersUri, [const Reply(200, [])]);
    await h.orders.getCurrentOrders();
    await h.loadList([orderJson(101)]);
    h.api.on(AppConstants.acceptOrderUri, [okMessage]);
    h.api.on(AppConstants.currentOrderUri, [fetch]);
    h.api.on(AppConstants.orderDetailsUri, [details]);
    await h.pumpApp(t);
    await tapAccept(t);
  }

  group('row 94: GET order failure kind', () {
    testWidgets('W6 a 500 shows the server problem state, not No connection',
        (t) async {
      await acceptedOrder(t, fetch: _serverError);

      expect(drain(t), isEmpty);
      expect(find.byType(OrderDetailsScreen), findsOneWidget);
      expect(find.text('no_connection'), findsNothing);
      expect(find.text('server_problem'), findsOneWidget);
      expect(find.text('retry'), findsOneWidget);
      await h.tearDown(t);
    });

    testWidgets('W6b an HTML 200 shows the server problem state', (t) async {
      await acceptedOrder(t,
          fetch: const Reply(200, '<html><body>Bad gateway</body></html>'));

      expect(drain(t), isEmpty);
      expect(find.text('no_connection'), findsNothing);
      expect(find.text('server_problem'), findsOneWidget);
      await h.tearDown(t);
    });

    testWidgets('W6c a 401 shows the session-expired sheet, no failure state',
        (t) async {
      ApiChecker.resetDialogState();
      addTearDown(ApiChecker.resetDialogState);
      await h.setUp(t);
      Get.put<AuthController>(
          AuthController(authServiceInterface: _LoggedInAuthService()));
      h.api.on(AppConstants.currentOrdersUri, [const Reply(200, [])]);
      await h.orders.getCurrentOrders();
      await h.loadList([orderJson(101)]);
      h.api.on(AppConstants.acceptOrderUri, [okMessage]);
      h.api.on(AppConstants.currentOrderUri, [
        const Reply(401, {
          'errors': [
            {'code': 'auth', 'message': 'Unauthenticated'}
          ]
        })
      ]);
      await h.pumpApp(t);
      await tapAccept(t);

      expect(drain(t), isEmpty);
      expect(find.byType(SessionExpiredBottomSheet), findsOneWidget);
      expect(find.text('no_connection'), findsNothing);
      expect(find.text('server_problem'), findsNothing);
      await h.tearDown(t);
    });

    testWidgets('W4 guard: offline still shows No connection with Retry',
        (t) async {
      await acceptedOrder(t, fetch: const Reply.offline());

      expect(drain(t), isEmpty);
      expect(find.text('no_connection'), findsOneWidget);
      expect(find.text('retry'), findsOneWidget);
      await h.tearDown(t);
    });
  });

  group('row 95: order-details failure', () {
    testWidgets('W7 a 500 gives a Retry state; a poll does not hide it',
        (t) async {
      await acceptedOrder(t,
          fetch: Reply(200, orderJson(101, status: 'accepted')),
          details: _serverError);
      // One 10 s poll passes.
      await t.pump(const Duration(seconds: 11));
      await settle(t);

      expect(drain(t), isEmpty);
      expect(find.byType(CircularProgressIndicator), findsNothing,
          reason: 'endless spinner');
      expect(find.byType(LoadFailedWidget), findsOneWidget);
      expect(find.text('retry'), findsOneWidget);
      expect(toasts, isEmpty, reason: 'the Retry state is the one message');
      await h.tearDown(t);
    });

    testWidgets(
        'W7b Retry: a loader while in flight, one request per tap, a second '
        'failure returns to Retry, then success shows the order', (t) async {
      await acceptedOrder(t,
          fetch: Reply(200, orderJson(101, status: 'accepted')),
          details: _serverError);
      expect(find.text('retry'), findsOneWidget);
      final int before = h.api.sent(AppConstants.orderDetailsUri);

      // Retry 1, held in flight, then it fails again.
      h.api.on(AppConstants.orderDetailsUri, [_serverError]);
      h.api.hold(AppConstants.orderDetailsUri);
      await t.tap(find.text('retry'));
      await settle(t, 2);
      expect(find.byType(CircularProgressIndicator), findsWidgets,
          reason: 'loader while Retry is in flight');
      expect(find.byType(LoadFailedWidget), findsNothing,
          reason: 'the old failure state must not stay on screen');
      expect(find.text('retry'), findsNothing);
      expect(h.api.sent(AppConstants.orderDetailsUri), before + 1);

      h.api.release(AppConstants.orderDetailsUri);
      await settle(t);
      expect(find.byType(LoadFailedWidget), findsOneWidget);
      expect(h.api.sent(AppConstants.orderDetailsUri), before + 1);

      // Retry 2 succeeds.
      h.api.on(AppConstants.orderDetailsUri, [
        Reply(200, [_line(itemDetails: {'id': 3, 'name': 'Milk'})])
      ]);
      await t.tap(find.text('retry'));
      await settle(t);

      expect(drain(t), isEmpty);
      expect(h.api.sent(AppConstants.orderDetailsUri), before + 2);
      expect(find.byType(LoadFailedWidget), findsNothing);
      expect(find.text('store_details'), findsOneWidget);
      expect(toasts, isEmpty);
      await h.tearDown(t);
    });
  });

  group('row 96: created_at and number shapes on the card', () {
    testWidgets('W8 ISO, date-only, empty and the usual format all build',
        (t) async {
      await h.setUp(t);
      await h.loadList([
        orderJson(101, createdAt: '2026-11-20T10:00:00.000000Z'),
        orderJson(102, createdAt: '2026-11-20 10:00:00'),
        orderJson(103, createdAt: '2026-11-20'),
        orderJson(104, createdAt: ''),
      ]);
      await h.pumpApp(t);

      expect(drain(t), isEmpty);
      expect(h.orders.latestOrderList!.map((o) => o.id), [101, 102, 103, 104]);
      for (final int id in [101, 102, 103, 104]) {
        await t.scrollUntilVisible(find.text('Store $id'), 300);
        expect(find.textContaining('#$id', findRichText: true), findsOneWidget);
      }
      expect(drain(t), isEmpty);
      await h.tearDown(t);
    });

    testWidgets('H1 a card with numbers as text and odd flags still shows',
        (t) async {
      await h.setUp(t);
      await h.loadList([
        {
          ...orderJson(103, createdAt: 20261120),
          'id': '103',
          'user_id': '57',
          'store_id': '9',
          'order_amount': '64.5',
          'delivery_charge': '5',
          'original_delivery_charge': 5,
          'dm_tips': 'x',
          'is_guest': 1,
          'cutlery': '0',
          'prescription_order': 0,
          'chat_permission': '1',
          'delivery_address': {
            'contact_person_number': null,
            'zone_id': 'x',
            'address': 'Somewhere',
          },
        }
      ]);
      await h.pumpApp(t);

      expect(drain(t), isEmpty);
      expect(h.orders.latestOrderList!.map((o) => o.id), [103]);
      expect(find.text('Store 103'), findsOneWidget);
      await h.tearDown(t);
    });
  });

  group('row 97: ignore by order id', () {
    testWidgets('W9 list card: a poll while the sheet is open, then Yes',
        (t) async {
      await h.setUp(t);
      await h.loadList([orderJson(101), orderJson(102)]);
      await h.pumpApp(t);

      await t.tap(find.text('ignore').at(1)); // order 102
      await settle(t, 3);
      // A poll lands while the sheet is open: 101 was taken by another rider.
      await h.loadList([orderJson(102)]);
      await t.pump();
      await t.tap(find.text('yes_ignore'));
      await settle(t);

      expect(drain(t), isEmpty);
      expect(h.orders.ignoredRequests.map((i) => i.id), [102]);
      expect(h.orders.latestOrderList!.map((o) => o.id), isEmpty);
      expect(toasts, ['order_ignored']);
      await h.tearDown(t);
    });

    testWidgets('W9b map card: the list shrank since the map opened',
        (t) async {
      await h.setUp(t);
      await h.loadList([orderJson(101), orderJson(102)]);
      final OrderModel second = h.orders.latestOrderList![1];
      await h.pumpApp(t,
          home: Scaffold(
            body: LocationCardWidget(
                orderModel: second,
                orderController: h.orders,
                index: 1,
                onTap: () {}),
          ));
      drain(t); // layout reports of the card itself (see progress notes)

      await h.loadList([orderJson(102)]);
      await t.pump();
      await t.tap(find.text('ignore'));
      await settle(t, 3);
      await t.tap(find.text('yes_ignore'));
      await settle(t);

      final List<String> errors =
          drain(t).where((e) => !e.contains('overflowed')).toList();
      expect(errors, isEmpty);
      expect(h.orders.ignoredRequests.map((i) => i.id), [102]);
      expect(h.orders.latestOrderList, isEmpty);
      await h.tearDown(t);
    });
  });

  group('row 98: order lines', () {
    testWidgets('W10 a line whose item was deleted shows a neutral row',
        (t) async {
      await acceptedOrder(t,
          fetch: Reply(200, orderJson(101, status: 'accepted')),
          details: Reply(200, [_line()]));
      expect(find.text('show_items (1)'), findsOneWidget);

      await t.tap(find.text('show_items (1)'));
      await settle(t);

      expect(drain(t), isEmpty);
      expect(find.text('item_no_longer_available'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
      await h.tearDown(t);
    });

    testWidgets('W10b guard: a normal line shows its name and quantity',
        (t) async {
      await acceptedOrder(t,
          fetch: Reply(200, orderJson(101, status: 'accepted')),
          details: Reply(200, [
            _line(itemDetails: {'id': 3, 'name': 'Milk'})
          ]));
      await t.tap(find.text('show_items (1)'));
      await settle(t);

      expect(drain(t), isEmpty);
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
      expect(find.text('item_no_longer_available'), findsNothing);
      await h.tearDown(t);
    });
  });

  group('row 99: push request sheet', () {
    testWidgets('P1 it does not load or replace the open order lines',
        (t) async {
      await h.setUp(t);
      final AudioCache cache = AudioCache.instance;
      AudioCache.instance = _HeldAudioCache();
      addTearDown(() => AudioCache.instance = cache);
      final messenger = t.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'), (call) async {
        if (call.method == 'create') {
          final Object? id = (call.arguments as Map)['playerId'];
          messenger.setMockMethodCallHandler(
              MethodChannel('xyz.luan/audioplayers/events/$id'),
              (_) async => null);
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'), null));

      // Order 7 is open with its lines.
      h.api.on(AppConstants.orderDetailsUri, [
        Reply(200, [
          {..._line(itemDetails: {'id': 3, 'name': 'Milk'}), 'order_id': 7}
        ])
      ]);
      await h.orders.getOrderDetails(7, false);
      expect(h.orders.orderDetailsModel!.single.orderId, 7);

      // A push for order 9 arrives; its lines would 404 (not yet ours).
      h.api.on(AppConstants.orderDetailsUri, [
        const Reply(404, {
          'errors': [
            {'code': 'order', 'message': 'not found'}
          ]
        })
      ]);
      await h.pumpApp(t,
          home: Scaffold(
            body: LottieBottomSheetOrderRequest(
              isRequest: true,
              onAccept: () {},
              onReject: () {},
              orderId: 9,
              isParcel: false,
            ),
          ));
      await settle(t);

      expect(drain(t), isEmpty);
      expect(toasts, isEmpty);
      expect(h.api.count(AppConstants.orderDetailsUri), 1);
      expect(h.orders.orderDetailsModel!.single.orderId, 7);
      await h.tearDown(t);
    });
  });

  group('row 100: Call button', () {
    Future<void> pumpCard(WidgetTester t, String? phone) async {
      await h.setUp(t);
      await h.pumpApp(t,
          home: Scaffold(
            body: SingleChildScrollView(
              child: InfoCardSection(
                title: 'customer_details',
                image: '',
                name: 'Customer',
                address: DeliveryAddress(address: 'Somewhere'),
                phone: phone,
                latitude: null,
                longitude: null,
                showButton: true,
                order: OrderModel(id: 1),
                isChatAllow: false,
              ),
            ),
          ));
    }

    testWidgets('C1 null, empty or blank number: no Call button', (t) async {
      for (final String? phone in [null, '', '   ']) {
        await pumpCard(t, phone);
        expect(drain(t), isEmpty);
        expect(find.text('call'), findsNothing, reason: 'phone "$phone"');
        await h.tearDown(t);
      }
    });

    testWidgets('C2 guard: a real number shows Call', (t) async {
      await pumpCard(t, '0100000000');
      expect(find.text('call'), findsOneWidget);
      await h.tearDown(t);
    });
  });
}
