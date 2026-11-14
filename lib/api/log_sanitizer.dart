import 'package:flutter/foundation.dart';

/// Removes tokens and personal data from debug log lines (audit row 8).
/// Values of sensitive query keys are replaced with `***`; paths and other
/// keys are kept so the log stays useful.
class LogSanitizer {
  LogSanitizer._();

  static const String mask = '***';

  static const Set<String> sensitiveKeys = {
    'token',
    'reset_token',
    'fcm_token',
    'phone',
    'number',
    'password',
    'otp',
    'email',
    'name',
    'session',
    'lat',
    'lng',
    'latitude',
    'longitude',
    'origin_lat',
    'origin_lng',
    'destination_lat',
    'destination_lng',
    'data',
    'user',
    'notification_body',
  };

  // key=value inside a query string: preceded by ? or &, value up to & # or whitespace.
  static final RegExp _pair = RegExp(r'([?&])([^=&#\s?]+)=([^&#\s]*)');

  /// Redacts sensitive query values in a URI or any text that contains one.
  static String text(String input) {
    return input.replaceAllMapped(_pair, (m) {
      final String key = m.group(2)!;
      if (sensitiveKeys.contains(key.toLowerCase())) {
        return '${m.group(1)}$key=$mask';
      }
      return m.group(0)!;
    });
  }

  /// Same as [text]; named for call sites that log a request URI.
  static String uri(String input) => text(input);

  /// GetX `logWriterCallback`: route logs carry query strings
  /// (for example the reset-password route), so they are redacted too.
  static void getxLog(String value, {bool isError = false}) {
    if (kDebugMode) debugPrint('[GETX] ${text(value)}');
  }
}
