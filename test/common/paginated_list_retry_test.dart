import 'package:doghree_rider/common/widgets/paginated_list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_phone.dart';

/// D-13: a failed page is asked again on the next scroll, never by itself.
/// Compiles against the old code too.
void main() {
  Future<ScrollController> pumpList(
      WidgetTester tester, Future<bool> Function(int? offset) onPaginate) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpPhone(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            controller: controller,
            child: PaginatedListViewWidget(
              scrollController: controller,
              totalSize: 30,
              offset: null,
              onPaginate: onPaginate,
              productView: Column(
                  children: List.generate(
                      40, (i) => SizedBox(height: 50, child: Text('row $i')))),
            ),
          ),
        ));
    return controller;
  }

  Future<void> scrollToEnd(WidgetTester tester, ScrollController c) async {
    c.jumpTo(0);
    await tester.pump();
    c.jumpTo(c.position.maxScrollExtent);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('P1 a failed page is asked again on the next scroll',
      (tester) async {
    final List<int?> asked = [];
    bool fail = true;
    final ScrollController c = await pumpList(tester, (offset) async {
      asked.add(offset);
      return !fail;
    });

    await scrollToEnd(tester, c);
    expect(asked, [2]);

    fail = false;
    await scrollToEnd(tester, c);
    expect(asked, [2, 2]);
  });

  testWidgets('P2 a page that throws is asked again too', (tester) async {
    final List<int?> asked = [];
    final ScrollController c = await pumpList(tester, (offset) async {
      asked.add(offset);
      if (asked.length == 1) throw StateError('page');
      return true;
    });

    await scrollToEnd(tester, c);
    await scrollToEnd(tester, c);

    expect(asked, [2, 2]);
  });

  testWidgets('P3 guard: a loaded page moves on, no automatic retry',
      (tester) async {
    final List<int?> asked = [];
    final ScrollController c = await pumpList(tester, (offset) async {
      asked.add(offset);
      return true;
    });

    await scrollToEnd(tester, c);
    await tester.pump(const Duration(seconds: 1));
    expect(asked, [2]);

    await scrollToEnd(tester, c);
    expect(asked, [2, 3]);
  });
}
