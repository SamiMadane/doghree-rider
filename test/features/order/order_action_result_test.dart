import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Backend docs Doghri-App-Screens R3 (accept-order) and R4
/// (update-order-status, GET order). Status and errors[0].code only.
void main() {
  group('C1 classifyAccept (R3)', () {
    test('200 accepted', () {
      expect(classifyAccept(200, null), AcceptOutcome.accepted);
    });
    test('404 order and 409 order_already_taken: taken', () {
      expect(classifyAccept(404, 'order'), AcceptOutcome.taken);
      expect(classifyAccept(409, 'order_already_taken'), AcceptOutcome.taken);
    });
    test('404 active_status: offline', () {
      expect(classifyAccept(404, 'active_status'), AcceptOutcome.offline);
    });
    test('every 405 code: refused (card kept)', () {
      for (final code in [
        'dm_maximum_order_exceed',
        'vehicle_out_of_range',
        'store_transfer',
        'deposit_required',
        'trust_ramp_limit',
        'deposit_cover_exceeded',
        'dm_maximum_hand_in_cash',
        null,
      ]) {
        expect(classifyAccept(405, code), AcceptOutcome.refused, reason: code);
      }
    });
    test('no internet', () {
      expect(classifyAccept(1, null), AcceptOutcome.noInternet);
    });
    test('403 order_id, unknown 404/409 codes, 0 and 500: failed', () {
      expect(classifyAccept(403, 'order_id'), AcceptOutcome.failed);
      expect(classifyAccept(404, null), AcceptOutcome.failed);
      expect(classifyAccept(404, 'something'), AcceptOutcome.failed);
      expect(classifyAccept(409, null), AcceptOutcome.failed);
      expect(classifyAccept(0, null), AcceptOutcome.failed);
      expect(classifyAccept(500, null), AcceptOutcome.failed);
      expect(classifyAccept(null, null), AcceptOutcome.failed);
    });
  });

  group('C2 classifyStatus (R4)', () {
    test('200 updated', () {
      expect(classifyStatus(200, null), StatusOutcome.updated);
    });
    test('403 invalid_status_transition / not_found, 404 order: orderChanged',
        () {
      expect(classifyStatus(403, 'invalid_status_transition'),
          StatusOutcome.orderChanged);
      expect(classifyStatus(403, 'not_found'), StatusOutcome.orderChanged);
      expect(classifyStatus(404, 'order'), StatusOutcome.orderChanged);
    });
    test('406 error: notDelivered; 406 otp: otpMismatch', () {
      expect(classifyStatus(406, 'error'), StatusOutcome.notDelivered);
      expect(classifyStatus(406, 'otp'), StatusOutcome.otpMismatch);
    });
    test('1: noInternet; 403 status, 500, 0: failed', () {
      expect(classifyStatus(1, null), StatusOutcome.noInternet);
      expect(classifyStatus(403, 'status'), StatusOutcome.failed);
      expect(classifyStatus(403, 'delivery-man'), StatusOutcome.failed);
      expect(classifyStatus(500, null), StatusOutcome.failed);
      expect(classifyStatus(0, null), StatusOutcome.failed);
    });
  });

  group('C3 classifyFetch (R4 GET order)', () {
    test('200 Map found, 200 non-Map failed', () {
      expect(classifyFetch(200, {'id': 1}), OrderFetch.found);
      expect(classifyFetch(200, 'html'), OrderFetch.failed);
      expect(classifyFetch(200, []), OrderFetch.failed);
    });
    test('404 and 204 notFound', () {
      expect(classifyFetch(404, null), OrderFetch.notFound);
      expect(classifyFetch(204, ''), OrderFetch.notFound);
    });
    test('1 and 500 failed', () {
      expect(classifyFetch(1, null), OrderFetch.failed);
      expect(classifyFetch(500, null), OrderFetch.failed);
    });
  });

  group('C4 riderMayMoveTo (R4 transition map)', () {
    test('allowed moves', () {
      for (final from in ['accepted', 'confirmed', 'processing', 'handover']) {
        expect(riderMayMoveTo(from, 'picked_up', isParcel: false), isTrue,
            reason: from);
      }
      expect(riderMayMoveTo('picked_up', 'delivered', isParcel: false), isTrue);
      expect(riderMayMoveTo('handover', 'picked_up', isParcel: true), isTrue);
      expect(riderMayMoveTo('accepted', 'handover', isParcel: true), isTrue);
      expect(riderMayMoveTo('accepted', 'canceled', isParcel: false), isTrue);
    });
    test('refused moves', () {
      expect(riderMayMoveTo('accepted', 'delivered', isParcel: false), isFalse);
      expect(riderMayMoveTo('handover', 'delivered', isParcel: true), isFalse);
      expect(riderMayMoveTo('accepted', 'handover', isParcel: false), isFalse);
      expect(riderMayMoveTo('picked_up', 'canceled', isParcel: false), isFalse);
      for (final to in ['picked_up', 'delivered', 'handover', 'canceled']) {
        expect(riderMayMoveTo('delivered', to, isParcel: true), isFalse,
            reason: to);
      }
      expect(
          riderMayMoveTo('accepted', 'processing', isParcel: false), isFalse);
    });
    test('unknown local status: the server decides', () {
      expect(riderMayMoveTo(null, 'canceled', isParcel: false), isTrue);
    });
  });
}
