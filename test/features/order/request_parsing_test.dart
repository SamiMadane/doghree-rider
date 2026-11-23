import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Audit rows 96 and 100 (D-16): the card's date text and the order JSON
/// accept the shapes the backend may send, and never throw.
void main() {
  setUpAll(() => initializeDateFormatting('en'));
  setUp(() => Get.testMode = true);

  group('row 96: dates', () {
    final DateFormat usual = DateFormat('yyyy-MM-dd HH:mm:ss');

    test('D1 timeAgo reads the usual format and ISO 8601 alike', () {
      final DateTime fiveMinAgo =
          DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateConverterHelper.timeAgo(usual.format(fiveMinAgo)),
          '5 mins_ago');
      expect(
          DateConverterHelper.timeAgo(fiveMinAgo.toUtc().toIso8601String()),
          '5 mins_ago');
    });

    test('D2 timeAgo gives empty text for empty or unreadable dates', () {
      expect(DateConverterHelper.timeAgo(''), '');
      expect(DateConverterHelper.timeAgo('not a date'), '');
    });

    test('D3 the date-only texts read date-only and ISO values', () {
      expect(DateConverterHelper.dateTimeStringToDateOnly('2026-11-01'),
          '01 Nov 2026');
      expect(
          DateConverterHelper.dateTimeStringToDateOnly('2026-11-01T10:00:00'),
          '01 Nov 2026');
      expect(DateConverterHelper.dateTimeStringToDateOnly(''), '');
      expect(DateConverterHelper.dateTimeStringToDateTime(''), '');
    });

    test('D4 guard: the usual format gives the same text as before', () {
      expect(
          DateConverterHelper.dateTimeStringToDateOnly('2026-11-01 10:00:00'),
          '01 Nov 2026');
      final DateTime old = DateTime.now().subtract(const Duration(days: 10));
      expect(DateConverterHelper.timeAgo(usual.format(old)),
          DateFormat('dd MMM yyyy', 'en').format(old));
    });
  });

  group('row 96: order numbers and flags', () {
    test('O1 numbers as text, 1/0 flags and a numeric date are read', () {
      final OrderModel o = OrderModel.fromJson({
        'id': '103',
        'user_id': '57',
        'store_id': '9',
        'order_amount': '64.5',
        'delivery_charge': '5',
        'dm_tips': 'x',
        'is_guest': 1,
        'cutlery': '0',
        'prescription_order': 0,
        'chat_permission': '1',
        'created_at': 20261120,
      });
      expect(o.id, 103);
      expect(o.userId, 57);
      expect(o.storeId, 9);
      expect(o.orderAmount, 64.5);
      expect(o.deliveryCharge, 5.0);
      expect(o.dmTips, isNull);
      expect(o.isGuest, isTrue);
      expect(o.cutlery, isFalse);
      expect(o.prescriptionOrder, isFalse);
      expect(o.storeChatPermission, 1);
      expect(o.createdAt, '20261120');
    });

    test('O2 a nested object of the wrong type is dropped, not fatal', () {
      final OrderModel o = OrderModel.fromJson({
        'id': 5,
        'delivery_address': 'x',
        'customer': 3,
        'parcel_category': [],
      });
      expect(o.id, 5);
      expect(o.deliveryAddress, isNull);
      expect(o.customer, isNull);
      expect(o.parcelCategory, isNull);
    });

    test('O3 guard: the documented shape reads exactly as before', () {
      final OrderModel o = OrderModel.fromJson({
        'id': 101,
        'user_id': 57,
        'order_amount': 64.5,
        'delivery_charge': 5,
        'dm_tips': 2,
        'order_status': 'confirmed',
        'created_at': '2026-10-08 13:10:04',
        'is_guest': false,
        'cutlery': true,
        'prescription_order': false,
        'chat_permission': 1,
        'additional_charge': 1.5,
        'tax_status': 'included',
      });
      expect(o.id, 101);
      expect(o.userId, 57);
      expect(o.orderAmount, 64.5);
      expect(o.deliveryCharge, 5.0);
      expect(o.dmTips, 2.0);
      expect(o.orderStatus, 'confirmed');
      expect(o.createdAt, '2026-10-08 13:10:04');
      expect(o.isGuest, isFalse);
      expect(o.cutlery, isTrue);
      expect(o.prescriptionOrder, isFalse);
      expect(o.storeChatPermission, 1);
      expect(o.additionalCharge, 1.5);
      expect(o.taxStatus, isTrue);
    });
  });

  group('row 100: contact number', () {
    test('A1 a null number stays null, never the text "null"', () {
      final DeliveryAddress a =
          DeliveryAddress.fromJson({'contact_person_number': null});
      expect(a.contactPersonNumber, isNull);
    });

    test('A2 a bad zone id is dropped, not fatal', () {
      expect(DeliveryAddress.fromJson({'zone_id': 'x'}).zoneId, isNull);
      expect(DeliveryAddress.fromJson({'zone_id': '5'}).zoneId, 5);
    });

    test('A3 guard: a number or a text number gives the same text', () {
      expect(
          DeliveryAddress.fromJson({'contact_person_number': '0100000000'})
              .contactPersonNumber,
          '0100000000');
      expect(
          DeliveryAddress.fromJson({'contact_person_number': 100000000})
              .contactPersonNumber,
          '100000000');
    });
  });
}
