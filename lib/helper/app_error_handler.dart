import 'package:doghree_rider/api/log_sanitizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The app-wide safety net (D-12).
///
/// - Framework errors (build, layout, paint) go to [FlutterError.onError].
/// - Uncaught async errors go to [PlatformDispatcher.onError], which returns
///   true so the app keeps running.
/// - In release, a widget that fails to build shows an empty box instead of
///   the grey error block.
///
/// Logs are debug only and always pass through [LogSanitizer]: error text can
/// carry a request URL with a token in it. [report] is the single place to
/// plug a crash reporter in later.
class AppErrorHandler {
  AppErrorHandler._();

  /// Where log lines go. Replaced in tests to read what would be printed.
  @visibleForTesting
  static void Function(String line) sink = _debugSink;

  static void _debugSink(String line) {
    if (kDebugMode) debugPrint(line);
  }

  static void install({bool release = kReleaseMode}) {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) FlutterError.presentError(details);
      report(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = handlePlatformError;
    if (release) ErrorWidget.builder = releaseErrorWidget;
  }

  /// Handler for [PlatformDispatcher.onError]. Returns true: handled.
  static bool handlePlatformError(Object error, StackTrace stack) {
    report(error, stack);
    return true;
  }

  /// Release replacement for the error widget: no text, no grey block.
  static Widget releaseErrorWidget(FlutterErrorDetails details) {
    return const ColoredBox(color: Colors.transparent);
  }

  /// One sanitized line: the error type and its text. The stack is not
  /// logged (it adds nothing a debugger cannot show).
  static void report(Object error, [StackTrace? stack]) {
    try {
      sink(LogSanitizer.text('App error ${error.runtimeType}: $error'));
    } catch (_) {}
  }

  /// A sanitized debug line for a handled failure (background isolate,
  /// start-up step).
  static void log(String message) {
    try {
      sink(LogSanitizer.text(message));
    } catch (_) {}
  }
}
