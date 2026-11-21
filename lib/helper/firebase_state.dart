/// Whether `Firebase.initializeApp` succeeded at start-up (D-12).
///
/// A failed init must never block login, splash or logout: every Firebase
/// call checks [ready] first and skips (or fails softly) when it is false.
class FirebaseState {
  FirebaseState._();

  static bool ready = false;
}
