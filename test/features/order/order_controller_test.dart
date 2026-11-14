import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns queued page-1 results; a queued Exception is thrown instead.
class _FakeOrderService implements OrderServiceInterface {
  final List<Object?> results;
  _FakeOrderService(this.results);

  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset) async {
    final Object? next = results.removeAt(0);
    if (next is Exception) throw next;
    return next as PaginatedOrderModel?;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PaginatedOrderModel _page() => PaginatedOrderModel.fromJson({
      'total_size': 1,
      'limit': 10,
      'offset': 1,
      'orders': [
        {'id': 7, 'order_type': 'parcel'},
      ],
    });

void main() {
  group('My Orders first load (audit row 13)', () {
    test('T8a a failed page 1 ends in the failed state, Retry recovers',
        () async {
      final controller = OrderController(
          orderServiceInterface: _FakeOrderService([null, _page()]));

      await controller.getCompletedOrders(1, willUpdate: false);
      expect(controller.completedOrderList, isNull);
      expect(controller.completedOrdersFailed, isTrue);

      await controller.getCompletedOrders(1);
      expect(controller.completedOrdersFailed, isFalse);
      expect(controller.completedOrderList?.map((o) => o.id), [7]);
    });

    test('T8b an exception on page 1 also stops the loader', () async {
      final controller = OrderController(
          orderServiceInterface:
              _FakeOrderService([Exception('parse'), _page()]));

      await controller.getCompletedOrders(1, willUpdate: false);
      expect(controller.completedOrdersFailed, isTrue);
      expect(controller.completedOrderList, isNull);

      await controller.getCompletedOrders(1);
      expect(controller.completedOrderList, hasLength(1));
    });
  });
}
