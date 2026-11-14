import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns queued results; any other method is unused by these tests.
class _FakeProfileService implements ProfileServiceInterface {
  final List<ProfileResult> results;
  _FakeProfileService(this.results);

  @override
  Future<ProfileResult> getProfileInfo() async => results.removeAt(0);

  @override
  void checkPermission(Function callback, {bool showDialog = true}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('T9 guard: offline result keeps the loaded profile (audit row 3)',
      () async {
    final loaded = ProfileModel(id: 7, active: 0);
    final controller = ProfileController(
      profileServiceInterface: _FakeProfileService([
        ProfileResult(profile: loaded, status: SessionStatus.valid),
        const ProfileResult(status: SessionStatus.offline),
      ]),
    );

    expect(await controller.getProfile(), SessionStatus.valid);
    expect(controller.profileModel, same(loaded));

    expect(await controller.getProfile(), SessionStatus.offline);
    expect(controller.profileModel, same(loaded));
  });
}
