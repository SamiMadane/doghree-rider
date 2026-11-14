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
