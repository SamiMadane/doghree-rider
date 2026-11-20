import 'dart:async';

import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/services/order_service_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers each history page through [handler] and records the page numbers
/// it was asked for. A handler may return a future that the test completes
/// later, to hold a request in flight.
class _HistoryService implements OrderServiceInterface {
  final Future<PaginatedOrderModel?> Function(int page) handler;
  final List<int> requested = [];
  _HistoryService(this.handler);

  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset) {
    requested.add(offset);
    return handler(offset);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A page of orders. [ids] with `itemless` set have no items, so the phone
/// filters them out.
PaginatedOrderModel _page(int total, List<int> ids,
        {Set<int> itemless = const {}}) =>
    PaginatedOrderModel.fromJson({
      'total_size': total,
      'limit': '10',
      'offset': '1',
      'orders': [
        for (final id in ids)
          {
            'id': id,
            'order_type': 'delivery',
            'details_count': itemless.contains(id) ? 0 : 1,
          }
      ],
    });

List<int?> _shown(OrderController c) =>
    c.completedOrderList!.map((o) => o.id).toList();

void main() {
  group('history pages after page 1 (audit row 26)', () {
    test('P1 a failed page 2 stops the loader and shows the failed state',
        () async {
      final service = _HistoryService(
          (page) async => page == 1 ? _page(25, [1, 2]) : null);
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      await c.loadNextHistoryPage();

      expect(c.paginate, isFalse);
      expect(c.historyPageFailed, isTrue);
      expect(_shown(c), [1, 2]);
    });

    test('P2 page 2 without an orders list does not crash and ends the history',
        () async {
      final service = _HistoryService((page) async => page == 1
          ? _page(25, [1, 2])
          : PaginatedOrderModel.fromJson({'total_size': 25}));
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      await c.loadNextHistoryPage();

      expect(c.paginate, isFalse);
      expect(c.historyPageFailed, isFalse);
      expect(c.hasMoreHistory, isFalse);
      expect(_shown(c), [1, 2]);
    });

    test('P3 an exception on page 2 stops the loader', () async {
      final service = _HistoryService((page) async {
        if (page == 1) return _page(25, [1, 2]);
        throw const FormatException('bad page');
      });
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      await c.loadNextHistoryPage();

      expect(c.paginate, isFalse);
      expect(c.historyPageFailed, isTrue);
    });

    test('P4 Retry asks for the same page again and adds it once', () async {
      int attempts = 0;
      final service = _HistoryService((page) async {
        if (page == 1) return _page(25, [1, 2]);
        attempts++;
        return attempts == 1 ? null : _page(25, [3, 4]);
      });
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      await c.loadNextHistoryPage();
      expect(c.historyPageFailed, isTrue);

      await c.retryHistoryPage();

      expect(service.requested, [1, 2, 2]);
      expect(c.historyPageFailed, isFalse);
      expect(c.paginate, isFalse);
      expect(_shown(c), [1, 2, 3, 4]);
    });

    test('P5 an order that moves to the next page is shown once', () async {
      final service = _HistoryService((page) async =>
          page == 1 ? _page(25, [1, 2]) : _page(25, [2, 3]));
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      await c.loadNextHistoryPage();

      expect(_shown(c), [1, 2, 3]);
    });

    test('P6 a page that arrives after a refresh is thrown away', () async {
      final late = Completer<PaginatedOrderModel?>();
      int page1Loads = 0;
      final service = _HistoryService((page) {
        if (page == 1) {
          page1Loads++;
          return Future.value(_page(25, page1Loads == 1 ? [1, 2] : [9]));
        }
        return late.future;
      });
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      final Future<void> pending = c.loadNextHistoryPage();
      expect(c.paginate, isTrue);

      await c.getCompletedOrders(1); // pull to refresh
      late.complete(_page(25, [3, 4]));
      await pending;

      expect(_shown(c), [9]);
      expect(c.paginate, isFalse);
      expect(c.historyPageFailed, isFalse);
    });

    test('P11 never more than one page request in flight', () async {
      final hold = Completer<PaginatedOrderModel?>();
      final service = _HistoryService(
          (page) => page == 1 ? Future.value(_page(45, [1, 2])) : hold.future);
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      final first = c.loadNextHistoryPage();
      final second = c.loadNextHistoryPage();
      final third = c.loadNextHistoryPage();
      hold.complete(_page(45, [3]));
      await Future.wait([first, second, third]);

      expect(service.requested, [1, 2]);
      expect(_shown(c), [1, 2, 3]);
    });
  });

  group('page count follows the server pages (audit row 27)', () {
    test(
        'P7 pages load by the server total, not by the filtered list, and '
        'stop at the end', () async {
      final service = _HistoryService((page) async {
        switch (page) {
          case 1: // 10 rows from the server, 4 without items
            return _page(25, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                itemless: {1, 2, 3, 4});
          case 2:
            return _page(25, [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
          default:
            return _page(25, [21, 22, 23, 24, 25]);
        }
      });
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);
      expect(c.completedOrderList, hasLength(6));
      expect(c.hasMoreHistory, isTrue);

      await c.loadNextHistoryPage();
      await c.loadNextHistoryPage();
      expect(c.hasMoreHistory, isFalse);

      await c.loadNextHistoryPage(); // nothing left: no request
      await c.loadNextHistoryPage();

      expect(service.requested, [1, 2, 3]);
      expect(c.completedOrderList, hasLength(21));
    });

    test('P8 an empty page ends the history even if total_size claims more',
        () async {
      final service = _HistoryService((page) async =>
          page == 1 ? _page(99, [1, 2]) : _page(99, <int>[]));
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      await c.loadNextHistoryPage();
      expect(c.hasMoreHistory, isFalse);
      expect(c.historyNeedsFill(fillsScreen: false), isFalse);

      await c.loadNextHistoryPage();
      expect(service.requested, [1, 2]);
    });

    test('P9 after a failed page nothing loads by itself, only Retry does',
        () async {
      final service = _HistoryService(
          (page) async => page == 1 ? _page(45, [1, 2]) : null);
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);
      await c.loadNextHistoryPage();
      expect(c.historyPageFailed, isTrue);

      // The screen asks again (short list and scrolling): both refuse.
      expect(c.historyNeedsFill(fillsScreen: false), isFalse);
      await c.loadNextHistoryPage();
      await c.loadNextHistoryPage();
      expect(service.requested, [1, 2]);

      await c.retryHistoryPage();
      expect(service.requested, [1, 2, 2]);
    });

    test('P10 historyNeedsFill: only a short list with more pages and idle',
        () async {
      final hold = Completer<PaginatedOrderModel?>();
      final service = _HistoryService(
          (page) => page == 1 ? Future.value(_page(25, [1])) : hold.future);
      final c = OrderController(orderServiceInterface: service);

      expect(c.historyNeedsFill(fillsScreen: false), isFalse,
          reason: 'nothing loaded yet');

      await c.getCompletedOrders(1, willUpdate: false);
      expect(c.historyNeedsFill(fillsScreen: true), isFalse,
          reason: 'the list already scrolls');
      expect(c.historyNeedsFill(fillsScreen: false), isTrue);

      final pending = c.loadNextHistoryPage();
      expect(c.historyNeedsFill(fillsScreen: false), isFalse,
          reason: 'a page is in flight');
      hold.complete(_page(25, [2]));
      await pending;
    });

    test('G10 a page 1 of only itemless orders is an empty list, not failed',
        () async {
      final service = _HistoryService(
          (page) async => _page(1, [1], itemless: {1}));
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);

      expect(c.completedOrderList, isEmpty);
      expect(c.completedOrdersFailed, isFalse);
    });

    test('G11 pull to refresh restarts the paging from page 1', () async {
      final service = _HistoryService((page) async => _page(25, [page]));
      final c = OrderController(orderServiceInterface: service);
      await c.getCompletedOrders(1, willUpdate: false);
      await c.loadNextHistoryPage();
      expect(service.requested, [1, 2]);

      await c.getCompletedOrders(1);
      await c.loadNextHistoryPage();

      expect(service.requested, [1, 2, 1, 2]);
    });
  });
}
