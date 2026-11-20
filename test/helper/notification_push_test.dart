import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/helper/notification_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Audit rows 6 and 34: push data to NotificationBodyModel never throws.
void main() {
  group('convertNotification (audit row 34)', () {
    test('N1 a non-numeric conversation_id gives a null id', () {
      final body = NotificationHelper.convertNotification(
          {'type': 'message', 'conversation_id': 'abc', 'sender_type': 'user'});
      expect(body!.notificationType, NotificationType.message);
      expect(body.conversationId, isNull);
    });

    test('N2 an int conversation_id is read as that id', () {
      final body = NotificationHelper.convertNotification(
          {'type': 'message', 'conversation_id': 12, 'sender_type': 'user'});
      expect(body!.conversationId, 12);
    });

    test('G1 the withdraw push (order_id empty) gives withdraw, no order id',
        () {
      final body = NotificationHelper.convertNotification(
          {'type': 'withdraw', 'order_id': ''});
      expect(body!.notificationType, NotificationType.withdraw);
      expect(body.orderId, isNull);
    });
  });

  group('NotificationBodyModel.fromJson (audit rows 31, 34)', () {
    test('N10 string ids in a payload are read, not a cast error', () {
      final body = NotificationBodyModel.fromJson({
        'order_notification': 'NotificationType.order',
        'order_id': '12',
        'conversation_id': '7',
      });
      expect(body.notificationType, NotificationType.order);
      expect(body.orderId, 12);
      expect(body.conversationId, 7);
    });
  });
}
