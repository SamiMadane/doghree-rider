import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';

/// Makes sure only one splash load runs at a time and that the splash
/// navigates away at most once (Retry, reconnect and the first load can
/// otherwise overlap).
class SplashLoadGuard {
  bool _loading = false;
  bool _navigated = false;

  bool get isLoading => _loading;
  bool get hasNavigated => _navigated;

  /// Returns true when a new load may start. False while one is running or
  /// after the splash has already navigated.
  bool tryStartLoad() {
    if (_loading || _navigated) return false;
    _loading = true;
    return true;
  }

  void endLoad() {
    _loading = false;
  }

  /// Returns true only for the first navigation.
  bool tryNavigate() {
    if (_navigated) return false;
    _navigated = true;
    return true;
  }
}

/// What the splash Retry screen says (D-12).
enum SplashFailure { noInternet, serverProblem }

/// Only a connectivity failure (statusCode 1, or an offline profile check)
/// is "no internet". A 5xx, 403, an unknown error (0) or a body that is not
/// JSON is a server problem: telling the rider to check the internet would
/// be wrong.
SplashFailure splashFailureFor({int? configStatus, SessionStatus? session}) {
  if (session != null) {
    return session == SessionStatus.offline
        ? SplashFailure.noInternet
        : SplashFailure.serverProblem;
  }
  return configStatus == 1
      ? SplashFailure.noInternet
      : SplashFailure.serverProblem;
}
