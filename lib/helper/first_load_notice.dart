import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
import 'package:get/get.dart';

/// The result of one silent list load, as the screen sees it (D-12).
class LoadAttempt {
  final bool ok;

  /// True when the list already held data before this load.
  final bool hadData;
  final int? statusCode;
  final String? message;

  const LoadAttempt(
      {required this.ok, required this.hadData, this.statusCode, this.message});
}

/// One rule for every list the rider waits for (D-12):
///
/// - data already on screen → silent;
/// - no data yet and the load failed → exactly one message, for all the
///   loads that ran together;
/// - a 401 → nothing here (the session-expired sheet already showed).
///
/// Resume and push refreshes never ask (they are always silent).
class FirstLoadNotice {
  FirstLoadNotice._();

  /// The one message for [attempts], or null for none. No internet wins
  /// over a server message, so the rider sees the cause they can fix.
  static String? pick(Iterable<LoadAttempt> attempts) {
    final List<LoadAttempt> failed =
        attempts.where((a) => !a.ok && !a.hadData).toList();
    if (failed.isEmpty) return null;
    if (attempts.any((a) => a.statusCode == 401)) return null;
    if (failed.any((a) => a.statusCode == 1)) {
      return ErrorMessages.getMessage(ErrorType.noInternet);
    }
    for (final LoadAttempt a in failed) {
      final String? m = a.message;
      if (m != null && m.trim().isNotEmpty) return m;
    }
    return 'error_occurred'.tr;
  }
}
