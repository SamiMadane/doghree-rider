/// Why a first load failed, as the rider sees it (D-13).
///
/// The same split as the splash (`splashFailureFor`): statusCode 1 means the
/// phone has no internet; anything else means the server did not give a
/// usable answer (0, 403, 5xx, a 200 that is not the expected shape).
enum LoadFailure { noInternet, serverProblem }

class LoadFailures {
  LoadFailures._();

  /// The failure for a status code, or null when the screen shows nothing:
  /// a 401 is owned by ApiChecker (the session-expired sheet), so the screen
  /// adds no second message.
  static LoadFailure? fromStatus(int? statusCode) {
    if (statusCode == 401) return null;
    if (statusCode == 1) return LoadFailure.noInternet;
    return LoadFailure.serverProblem;
  }
}
