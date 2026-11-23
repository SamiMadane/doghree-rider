import 'package:doghree_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/order/widgets/location_card_widget.dart';
import 'package:doghree_rider/features/order/widgets/order_slider_button.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/request_path_harness.dart';

/// Audit row 93 (D-16): the confirm sheet of the request cards and of the
/// Order Details slider. Every step presses the real buttons; nothing calls
/// the sheet's callbacks directly, because that would hide a sheet that
/// cannot build.
void main() {
  final Harness h = Harness();

  Future<void> open(WidgetTester t, String button, {int at = 0}) async {
    await t.tap(find.text(button).at(at));
    await settle(t, 3);
  }

  group('list card (Requests tab)', () {
    testWidgets('S1 Accept, then No: only the sheet closes, nothing is sent',
        (t) async {
      await h.setUp(t);
      await h.loadList([orderJson(101)]);
      await h.pumpApp(t);

      await open(t, 'accept');
      final List<String> built = drain(t);
      await t.tap(find.text('no_cancel'));
      await settle(t);

      expect(built, isEmpty, reason: 'sheet build: $built');
      expect(drain(t), isEmpty);
      expect(find.byType(ConfirmationBottomSheet), findsNothing);
      expect(find.byType(RequestsHost), findsOneWidget);
      expect(find.text('Store 101'), findsOneWidget);
      expect(h.api.count(AppConstants.acceptOrderUri), 0);
      await h.tearDown(t);
    });

    testWidgets('S2 Ignore, then No: only the sheet closes, nothing ignored',
        (t) async {
      await h.setUp(t);
      await h.loadList([orderJson(101)]);
      await h.pumpApp(t);

      await open(t, 'ignore');
      final List<String> built = drain(t);
      await t.tap(find.text('no_cancel'));
      await settle(t);

      expect(built, isEmpty, reason: 'sheet build: $built');
      expect(find.byType(ConfirmationBottomSheet), findsNothing);
      expect(find.text('Store 101'), findsOneWidget);
      expect(h.orders.ignoredRequests, isEmpty);
      await h.tearDown(t);
    });

    testWidgets('S3 Accept, then Yes: one request, Order Details opens',
        (t) async {
      await h.setUp(t);
      await h.loadList([orderJson(101)]);
      h.api.on(AppConstants.acceptOrderUri, [okMessage]);
      h.api.on(AppConstants.currentOrderUri,
          [Reply(200, orderJson(101, status: 'accepted'))]);
      h.api.on(AppConstants.orderDetailsUri, [const Reply(200, [])]);
      h.api.on(AppConstants.currentOrdersUri, [const Reply(200, [])]);
      await h.pumpApp(t);

      await open(t, 'accept');
      final List<String> built = drain(t);
      await t.tap(find.text('yes_accept'));
      await settle(t);

      expect(built, isEmpty, reason: 'sheet build: $built');
      expect(drain(t), isEmpty);
      expect(h.api.count(AppConstants.acceptOrderUri), 1);
      expect(find.byType(OrderDetailsScreen), findsOneWidget);
      await h.tearDown(t);
    });

    testWidgets('S4 Ignore, then Yes: that order is ignored, one message',
        (t) async {
      await h.setUp(t);
      await h.loadList([orderJson(101)]);
      await h.pumpApp(t);

      await open(t, 'ignore');
      final List<String> built = drain(t);
      await t.tap(find.text('yes_ignore'));
      await settle(t);

      expect(built, isEmpty, reason: 'sheet build: $built');
      expect(find.byType(ConfirmationBottomSheet), findsNothing);
      expect(h.orders.ignoredRequests.map((i) => i.id), [101]);
      expect(toasts, ['order_ignored']);
      await h.tearDown(t);
    });
  });

  group('map card (Order location screen)', () {
    Future<void> pumpMapCard(WidgetTester t) async {
      await h.loadList([orderJson(101)]);
      await h.pumpApp(t,
          home: Scaffold(
            body: GetBuilder<OrderController>(builder: (c) {
              final List<OrderModel> list = c.latestOrderList ?? [];
              return list.isEmpty
                  ? const SizedBox()
                  : LocationCardWidget(
                      orderModel: list.first,
                      orderController: c,
                      index: 0,
                      onTap: () {});
            }),
          ));
      // Only layout reports of the card itself (raw key texts are longer
      // than the translations) are dropped here; the sheet is checked after.
      final List<String> layout = drain(t);
      expect(layout.where((e) => !e.contains('overflowed')), isEmpty,
          reason: 'map card build: $layout');
    }

    testWidgets('S5 Accept and Ignore, then No: only the sheet closes',
        (t) async {
      await h.setUp(t);
      await pumpMapCard(t);

      await open(t, 'accept');
      final List<String> acceptBuilt = drain(t);
      await t.tap(find.text('no_cancel'));
      await settle(t);
      expect(find.byType(ConfirmationBottomSheet), findsNothing);

      await open(t, 'ignore');
      final List<String> ignoreBuilt = drain(t);
      await t.tap(find.text('no_cancel'));
      await settle(t);

      expect(acceptBuilt, isEmpty, reason: 'accept sheet: $acceptBuilt');
      expect(ignoreBuilt, isEmpty, reason: 'ignore sheet: $ignoreBuilt');
      expect(find.byType(ConfirmationBottomSheet), findsNothing);
      expect(find.byType(LocationCardWidget), findsOneWidget);
      expect(h.api.count(AppConstants.acceptOrderUri), 0);
      expect(h.orders.ignoredRequests, isEmpty);
      await h.tearDown(t);
    });

    testWidgets('S6 Ignore, then Yes: that order is ignored', (t) async {
      await h.setUp(t);
      await pumpMapCard(t);

      await open(t, 'ignore');
      final List<String> built = drain(t);
      await t.tap(find.text('yes_ignore'));
      await settle(t);

      expect(built, isEmpty, reason: 'sheet build: $built');
      expect(h.orders.ignoredRequests.map((i) => i.id), [101]);
      await h.tearDown(t);
    });
  });

  group('Order Details slider (parcel accepted, confirm handover)', () {
    final OrderModel parcel =
        OrderModel(id: 7, orderStatus: 'accepted', orderType: 'parcel');

    Future<void> pumpSlider(WidgetTester t) async {
      await h.pumpApp(t,
          home: Scaffold(
            body: Center(
              child: OrderSliderButton(
                order: parcel,
                parcel: true,
                accepted: true,
                pickedUp: false,
                handover: false,
                orderVerificationActive: false,
                cancelPermission: false,
                fromLocationScreen: false,
              ),
            ),
          ));
    }

    Future<void> swipe(WidgetTester t) async {
      await t.drag(find.byType(Dismissible), const Offset(600, 0));
      await settle(t, 3);
    }

    testWidgets('S7 swipe, then No: only the sheet closes, no status sent',
        (t) async {
      await h.setUp(t);
      await pumpSlider(t);

      await swipe(t);
      expect(find.byType(ConfirmationBottomSheet), findsOneWidget);
      final List<String> built = drain(t);
      await t.tap(find.text('no'));
      await settle(t);

      expect(built, isEmpty, reason: 'sheet build: $built');
      expect(find.byType(ConfirmationBottomSheet), findsNothing);
      expect(find.byType(OrderSliderButton), findsOneWidget);
      expect(h.api.count(AppConstants.updateOrderStatusUri), 0);
      await h.tearDown(t);
    });

    testWidgets('S8 swipe, then Yes: exactly one handover request',
        (t) async {
      await h.setUp(t);
      h.api.on(AppConstants.updateOrderStatusUri, [okMessage]);
      h.api.on(AppConstants.currentOrdersUri, [const Reply(200, [])]);
      await pumpSlider(t);

      await swipe(t);
      final List<String> built = drain(t);
      await t.tap(find.text('yes'));
      await settle(t);

      expect(built, isEmpty, reason: 'sheet build: $built');
      final hits = h.api.hits
          .where((x) => x.path == AppConstants.updateOrderStatusUri)
          .toList();
      expect(hits.length, 1);
      expect((hits.single.body as Map)['status'], AppConstants.handover);
      await h.tearDown(t);
    });
  });
}
