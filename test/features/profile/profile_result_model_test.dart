import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T8 sessionStatusFromCode maps codes (audit row 3)', () {
    expect(sessionStatusFromCode(200), SessionStatus.valid);
    expect(sessionStatusFromCode(401), SessionStatus.expired);
    expect(sessionStatusFromCode(403), SessionStatus.unverified);
    expect(sessionStatusFromCode(1), SessionStatus.offline);
    expect(sessionStatusFromCode(0), SessionStatus.unverified);
    expect(sessionStatusFromCode(500), SessionStatus.unverified);
    expect(sessionStatusFromCode(503), SessionStatus.unverified);
    expect(sessionStatusFromCode(404), SessionStatus.unverified);
    expect(sessionStatusFromCode(null), SessionStatus.unverified);
  });
}
