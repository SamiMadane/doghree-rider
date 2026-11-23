import 'package:doghree_rider/helper/json_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('J1 asInt reads ints, whole numbers and numeric strings', () {
    expect(JsonHelper.asInt(5), 5);
    expect(JsonHelper.asInt(5.0), 5);
    expect(JsonHelper.asInt('7'), 7);
    expect(JsonHelper.asInt(' 7 '), 7);
    expect(JsonHelper.asInt('7.0'), 7);
    expect(JsonHelper.asInt(5.5), isNull);
    expect(JsonHelper.asInt('x'), isNull);
    expect(JsonHelper.asInt(null), isNull);
    expect(JsonHelper.asInt(<int>[1]), isNull);
    expect(JsonHelper.asInt(double.nan), isNull);
  });

  test('J2 asDouble reads numbers and numeric strings', () {
    expect(JsonHelper.asDouble(2), 2.0);
    expect(JsonHelper.asDouble(2.5), 2.5);
    expect(JsonHelper.asDouble('2.5'), 2.5);
    expect(JsonHelper.asDouble('abc'), isNull);
    expect(JsonHelper.asDouble(null), isNull);
    expect(JsonHelper.asDouble(true), isNull);
  });

  test('J3 asString keeps strings, writes numbers, drops the rest', () {
    expect(JsonHelper.asString('a'), 'a');
    expect(JsonHelper.asString(31.5), '31.5');
    expect(JsonHelper.asString(null), isNull);
    expect(JsonHelper.asString(<String>['a']), isNull);
    expect(JsonHelper.asString(true), isNull);
  });

  test('J4 stringList never throws: a wrong value is an empty list', () {
    expect(JsonHelper.stringList(null), isEmpty);
    expect(JsonHelper.stringList('x'), isEmpty);
    expect(JsonHelper.stringList(<String, dynamic>{'a': 1}), isEmpty);
    expect(JsonHelper.stringList(<dynamic>[1, null, 'a']), ['1', 'a']);
    expect(JsonHelper.stringList(<dynamic>[]), isEmpty);
  });

  test('J5 mapList: only a real list gives a result, [] is empty not null',
      () {
    int parse(Map<String, dynamic> j) => j['id'] as int;
    expect(JsonHelper.mapList(null, parse), isNull);
    expect(JsonHelper.mapList('x', parse), isNull);
    expect(JsonHelper.mapList(<String, dynamic>{'id': 1}, parse), isNull);
    expect(JsonHelper.mapList(<dynamic>[], parse), isEmpty);
    expect(
        JsonHelper.mapList(<dynamic>[
          <String, dynamic>{'id': 1},
          <String, dynamic>{'id': 2}
        ], parse),
        [1, 2]);
  });

  test('J6 mapList skips bad items and keeps the good ones', () {
    int parse(Map<String, dynamic> j) => j['id'] as int;
    final result = JsonHelper.mapList(<dynamic>[
      'not a map',
      null,
      <String, dynamic>{'id': 'wrong type'},
      <String, dynamic>{'id': 3},
    ], parse);
    expect(result, [3]);
  });

  test('J7 the debug log names the list and the count, never the content',
      () {
    final List<String> logs = [];
    final DebugPrintCallback saved = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = saved);

    JsonHelper.mapList(<dynamic>[
      'SECRET-PHONE-0599',
      <String, dynamic>{'id': 'SECRET-TOKEN'},
      <String, dynamic>{'id': 1},
    ], (j) => j['id'] as int, name: 'current-orders');

    expect(logs, hasLength(1));
    expect(logs.single, contains('current-orders'));
    expect(logs.single, contains('2'));
    expect(logs.single, isNot(contains('SECRET')));
  });

  test('G7 nothing is logged when no item is skipped', () {
    final List<String> logs = [];
    final DebugPrintCallback saved = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = saved);

    JsonHelper.mapList(<dynamic>[<String, dynamic>{'id': 1}],
        (j) => j['id'] as int);
    expect(logs, isEmpty);
  });

  test('J8 asBool reads bools, 1/0 and their texts (D-16)', () {
    expect(JsonHelper.asBool(true), isTrue);
    expect(JsonHelper.asBool(false), isFalse);
    expect(JsonHelper.asBool(1), isTrue);
    expect(JsonHelper.asBool(0), isFalse);
    expect(JsonHelper.asBool('1'), isTrue);
    expect(JsonHelper.asBool(' false '), isFalse);
    expect(JsonHelper.asBool('TRUE'), isTrue);
    expect(JsonHelper.asBool(2), isNull);
    expect(JsonHelper.asBool('yes'), isNull);
    expect(JsonHelper.asBool(null), isNull);
  });

  test('J9 asMap keeps objects and drops every other value (D-16)', () {
    expect(JsonHelper.asMap(<dynamic, dynamic>{'a': 1}), {'a': 1});
    expect(JsonHelper.asMap('x'), isNull);
    expect(JsonHelper.asMap(<int>[]), isNull);
    expect(JsonHelper.asMap(null), isNull);
  });
}
