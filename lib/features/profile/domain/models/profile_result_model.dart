import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';

/// Outcome of a profile fetch, used to tell a real session end apart from
/// a temporary failure (offline, timeout, server error).
enum SessionStatus { valid, expired, offline, unverified }

/// 200 → valid. 401 → expired (rider auth middleware answers 401 auth-001
/// for no/unknown token, suspended and not-approved riders).
/// 1 → offline (socket, timeout, client exception in ApiClient).
/// Anything else (0, 403, 5xx, other 4xx, null) → unverified.
SessionStatus sessionStatusFromCode(int? statusCode) {
  switch (statusCode) {
    case 200:
      return SessionStatus.valid;
    case 401:
      return SessionStatus.expired;
    case 1:
      return SessionStatus.offline;
    default:
      return SessionStatus.unverified;
  }
}

class ProfileResult {
  final ProfileModel? profile;
  final SessionStatus status;

  const ProfileResult({this.profile, required this.status});
}
