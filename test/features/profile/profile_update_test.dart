import 'dart:async';
import 'dart:io';

import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/repositories/profile_repository.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/helper/image_upload_rules.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

class _FakeProfileService implements ProfileServiceInterface {
  int updateCalls = 0;
  Completer<ResponseModel>? gate;
  ResponseModel next = ResponseModel(true, 'ok', statusCode: 200);
  Object? throwOnUpdate;
  final List<XFile?> images = [];

  @override
  Future<ResponseModel> updateProfile(ProfileModel model, XFile? data) async {
    updateCalls++;
    images.add(data);
    if (throwOnUpdate != null) throw throwOnUpdate!;
    if (gate != null) return gate!.future;
    return next;
  }

  ProfileModel? loaded;

  @override
  Future<ProfileResult> getProfileInfo() async =>
      ProfileResult(profile: loaded, status: SessionStatus.valid);

  @override
  void checkPermission(Function callback, {bool showDialog = true}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  group('repository (row 47)', () {
    late FakeApiClient api;
    late ProfileRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      api = FakeApiClient(sharedPreferences: prefs);
      repo = ProfileRepository(apiClient: api, sharedPreferences: prefs);
    });

    test('R1 a null email does not crash and is not sent', () async {
      await repo.updateProfile(ProfileModel(fName: 'A', lName: 'B'), null);
      final Map<String, String> body = api.last.body as Map<String, String>;
      expect(body.containsKey('email'), isFalse);
      expect(body['f_name'], 'A');
      expect(body['l_name'], 'B');
    });

    test('R2 fields, no token, and no image part without a photo', () async {
      await repo.updateProfile(
          ProfileModel(fName: 'A', lName: 'B', email: 'a@b.c'), null);
      final Map<String, String> body = api.last.body as Map<String, String>;
      expect(body.keys.toSet(), {'_method', 'f_name', 'l_name', 'email'});
      expect(api.multipartFiles.last, isEmpty);
      expect(api.last.uri, AppConstants.updateProfileUri);
    });

    test('R3a a failure carries its status and the server text', () async {
      api.nextResponse =
          const Response(statusCode: 403, statusText: 'email taken');
      final ResponseModel r =
          await repo.updateProfile(ProfileModel(fName: 'A'), null);
      expect(r.isSuccess, isFalse);
      expect(r.statusCode, 403);
      expect(r.message, 'email taken');
    });

    test('R3b a 401 goes to the session check (ApiChecker.checkSession)',
        () async {
      // The session path needs AuthController, which this unit test does not
      // register: reaching it proves checkSession ran on the 401.
      api.nextResponse =
          const Response(statusCode: 401, statusText: 'Unauthorized');
      await expectLater(
          repo.updateProfile(ProfileModel(fName: 'A'), null),
          throwsA(predicate((e) => '$e'.contains('AuthController'))));
    });

    test('G4 guard: the profile multipart is silent (handleError false)',
        () async {
      await repo.updateProfile(ProfileModel(fName: 'A'), null);
      expect(api.last.handleError, isFalse);
    });
  });

  group('controller (row 48)', () {
    late _FakeProfileService service;
    late ProfileController controller;
    late List<String?> toasts;

    setUp(() {
      service = _FakeProfileService();
      controller = ProfileController(profileServiceInterface: service);
      toasts = [];
      controller.toast = (String? m, {bool isError = true}) => toasts.add(m);
    });

    tearDown(Get.reset);

    test('U1 an exception stops the loader and gives one message', () async {
      service.throwOnUpdate = Exception('x');
      expect(await controller.updateUserInfo(ProfileModel(fName: 'A')), isFalse);
      expect(controller.isLoading, isFalse);
      expect(toasts, ['error_occurred']);
    });

    test('U2 a double tap sends one request', () async {
      service.gate = Completer<ResponseModel>();
      final first = controller.updateUserInfo(ProfileModel(fName: 'A'));
      final second = controller.updateUserInfo(ProfileModel(fName: 'A'));
      service.gate!.complete(ResponseModel(true, 'ok', statusCode: 200));
      await first;
      expect(await second, isFalse);
      expect(service.updateCalls, 1);
      expect(toasts, ['ok']);
    });

    test('U3 success keeps the loaded profile and changes only the edit',
        () async {
      final loaded = ProfileModel(
          id: 7, active: 1, fName: 'Old', lName: 'Name', email: 'o@x.y');
      service.loaded = loaded;
      await controller.getProfile();
      expect(controller.profileModel, same(loaded));

      expect(
          await controller.updateUserInfo(
              ProfileModel(fName: 'New', lName: 'Name', email: 'n@x.y')),
          isTrue);
      expect(controller.profileModel!.id, 7);
      expect(controller.profileModel!.active, 1);
      expect(controller.profileModel!.fName, 'New');
      expect(controller.profileModel!.email, 'n@x.y');
      expect(controller.isLoading, isFalse);
    });

    test('U4 a 403 shows the server message once', () async {
      service.next = ResponseModel(false, 'email taken', statusCode: 403);
      await controller.updateUserInfo(ProfileModel(fName: 'A'));
      expect(toasts, ['email taken']);
      expect(controller.isLoading, isFalse);
    });

    test('U5 a 401 shows nothing (the session sheet already did)', () async {
      service.next = ResponseModel(false, 'Unauthorized', statusCode: 401);
      await controller.updateUserInfo(ProfileModel(fName: 'A'));
      expect(toasts, isEmpty);
    });

    test('U6 a 200 without a message uses the local text', () async {
      service.next = ResponseModel(true, null, statusCode: 200);
      await controller.updateUserInfo(ProfileModel(fName: 'A'));
      expect(toasts, ['profile_updated']);
    });
  });

  group('profile photo (row 46)', () {
    late Directory dir;
    late ProfileController controller;
    late List<String?> toasts;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('d09p_');
      controller = ProfileController(profileServiceInterface: _FakeProfileService());
      toasts = [];
      controller.toast = (String? m, {bool isError = true}) => toasts.add(m);
    });
    tearDown(() async => dir.delete(recursive: true));

    XFile write(String name, List<int> head, int size) {
      final File f = File('${dir.path}/$name')
        ..writeAsBytesSync([...head, ...List<int>.filled(size - head.length, 1)]);
      return XFile(f.path);
    }

    test('P1 a 3 MB photo is refused and the old photo stays', () async {
      final ok = write('ok.jpg', [0xFF, 0xD8, 0xFF, 0xE0], 1000);
      expect(await controller.acceptProfileImage(ok), isTrue);
      final big = write('big.jpg', [0xFF, 0xD8, 0xFF, 0xE0], 3 * 1024 * 1024);
      expect(await controller.acceptProfileImage(big), isFalse);
      expect(controller.pickedFile!.path, ok.path);
      expect(toasts, ['please_upload_lower_size_file']);
    });

    test('P2 a HEIC photo is refused', () async {
      final heic = write('a.heic',
          [0, 0, 0, 24, ...'ftyp'.codeUnits, ...'heic'.codeUnits], 1000);
      expect(await controller.acceptProfileImage(heic), isFalse);
      expect(controller.pickedFile, isNull);
      expect(toasts, ['photo_format_not_supported']);
      expect(ImageUploadRules.maxImageBytes, 2 * 1024 * 1024);
    });
  });
}
