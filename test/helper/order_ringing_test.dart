import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/helper/notification_helper.dart';
import 'package:doghree_rider/helper/order_ringing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_ringing_client.dart';

/// Audit rows 36 and 37: the ringing helper, the title and the channels.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeRingingClient client;

  setUp(() {
    client = FakeRingingClient();
    OrderRinging.client = client;
  });

  tearDown(() => OrderRinging.client = const RingingClient());

  group('stop (row 36)', () {
    test('R1 stops a running service', () async {
      await OrderRinging.stop();
      expect(client.stopCalls, 1);
    });

    test('R2 does nothing when nothing rings', () async {
      client.running = false;
      await OrderRinging.stop();
      expect(client.stopCalls, 0);
    });

    test('R3 a platform error is swallowed', () async {
      client.failIsRunning = true;
      await OrderRinging.stop();
      expect(client.stopCalls, 0);
    });

    test('R3b stopping twice stops once', () async {
      await OrderRinging.stop();
      await OrderRinging.stop();
      expect(client.stopCalls, 1);
    });

    test('R4 resuming the app stops the ringing, other states do not',
        () async {
      final observer = OrderRingingObserver();
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future<void>.delayed(Duration.zero);
      expect(client.stopCalls, 0);

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);
      expect(client.stopCalls, 1);
    });
  });

  group('cap (row 36)', () {
    test('R11 stops at 12 rings (60 s at 5 s), not before', () {
      expect(OrderRinging.shouldStopAfter(0), isFalse);
      expect(OrderRinging.shouldStopAfter(11), isFalse);
      expect(OrderRinging.shouldStopAfter(12), isTrue);
      expect(OrderRinging.shouldStopAfter(13), isTrue);
    });
  });

  group('title (row 37)', () {
    test('R8 an assign push without an id has no (null)', () {
      final title = OrderRinging.title(NotificationType.order, null);
      expect(title, 'You have been assigned a new order');
      expect(title.contains('null'), isFalse);
    });

    test('R9 an assign push with an id shows it', () {
      expect(OrderRinging.title(NotificationType.order, 7),
          'You have been assigned a new order (7)');
    });

    test('R10 a request title never carries the id', () {
      expect(OrderRinging.title(NotificationType.order_request, null),
          'Order Notification');
      expect(OrderRinging.title(NotificationType.order_request, 7),
          'Order Notification');
    });
  });

  group('channels (row 37)', () {
    test('R12 the legacy helper deletes only the exact stackfood id', () async {
      client.running = false;
      expect(await OrderRinging.retireLegacyChannel(id: 'doghree_rider'),
          isFalse);
      expect(await OrderRinging.retireLegacyChannel(id: '6ammart'), isFalse);
      expect(await OrderRinging.retireLegacyChannel(id: 'doghree_rider_ringing'),
          isFalse);
      expect(client.deletedChannels, isEmpty);

      expect(await OrderRinging.retireLegacyChannel(), isTrue);
      expect(client.deletedChannels, ['stackfood']);
    });

    test('R13 it never deletes while the service runs', () async {
      client.running = true;
      expect(await OrderRinging.retireLegacyChannel(), isFalse);
      expect(client.deletedChannels, isEmpty);
    });

    test('G4 guard: the server channel constants are unchanged', () {
      expect(NotificationHelper.channelId, 'doghree_rider');
      expect(OrderRinging.channelId, isNot('doghree_rider'));
      expect(OrderRinging.channelId, isNot('stackfood'));
      expect(OrderRinging.legacyChannelId, 'stackfood');
    });
  });
}
