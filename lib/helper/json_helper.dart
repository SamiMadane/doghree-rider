import 'package:flutter/foundation.dart';

/// Defensive readers for server JSON (audit rows 52 and 53). None of them
/// throws. A wrong shape gives null, 0 or an empty list, so a loader never
/// hangs on an exception.
class JsonHelper {
  const JsonHelper._();

  /// An int, a whole number, or a numeric string. Anything else is null.
  static int? asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return _wholeNumber(value);
    if (value is String) {
      final String text = value.trim();
      return int.tryParse(text) ?? _wholeNumber(double.tryParse(text));
    }
    return null;
  }

  /// NaN and infinity have no int value (`toInt` would throw on them).
  static int? _wholeNumber(num? value) =>
      value != null && value.isFinite && value == value.toInt()
          ? value.toInt()
          : null;

  /// A number or a numeric string. Anything else is null.
  static double? asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  /// A String, or a number written as text. Anything else is null.
  static String? asString(dynamic value) {
    if (value is String) return value;
    if (value is num) return value.toString();
    return null;
  }

  /// A bool, 1/0, or the texts "true"/"false"/"1"/"0". Anything else is null.
  static bool? asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1 ? true : (value == 0 ? false : null);
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
          return true;
        case 'false':
        case '0':
          return false;
      }
    }
    return null;
  }

  /// A JSON object as a typed Map, or null for any other value.
  static Map<String, dynamic>? asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  /// A list of strings. A missing or wrong value gives an empty list, null
  /// items are dropped and other items are written as text.
  static List<String> stringList(dynamic value) {
    if (value is! List) return <String>[];
    final List<String> result = <String>[];
    for (final dynamic item in value) {
      if (item == null) continue;
      result.add(item.toString());
    }
    return result;
  }

  /// Parses a JSON list into models. A value that is not a List gives null
  /// (a failure, not an empty result). Items that are not Maps, or whose
  /// [parse] throws, are skipped. Only the list name and the number of
  /// skipped items are logged in debug, never the content.
  static List<T>? mapList<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) parse, {
    String name = 'list',
  }) {
    if (value is! List) return null;
    final List<T> result = <T>[];
    int skipped = 0;
    for (final dynamic item in value) {
      if (item is! Map) {
        skipped++;
        continue;
      }
      try {
        result.add(parse(Map<String, dynamic>.from(item)));
      } catch (_) {
        skipped++;
      }
    }
    if (skipped > 0 && kDebugMode) {
      debugPrint('$name: skipped $skipped item(s)');
    }
    return result;
  }
}
