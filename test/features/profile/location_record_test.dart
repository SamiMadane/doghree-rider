import 'dart:async';

import 'package:doghree_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

Position _position(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime(2026),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

class _FakeService implements ProfileServiceInterface {
  Future<Position?> Function() position = () async => _position(31.5, 34.4);
  Completer<void>? sendGate;
  Object? sendError;
  int positionCalls = 0, httpCalls = 0, socketCalls = 0;
  final List<RecordLocationBodyModel> sent = [];

  @override
  Future<Position?> currentPositionOrNull() {
    positionCalls++;
    return position();
  }

  @override
  Future<String> addressPlaceMark(Position locationResult) async => 'place';

  @override
  Future<Response> recordLocation(RecordLocationBodyModel body) async {
    httpCalls++;
    sent.add(body);
    if (sendError != null) throw sendError!;
    if (sendGate != null) await sendGate!.future;
    return const Response(statusCode: 200);
  }

  @override
  Future<bool> recordWebSocketLocation(RecordLocationBodyModel body) async {
    socketCalls++;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Audit row 38: the 10 s location tick never throws and recovers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeService service;
  late ProfileController controller;

  setUp(() {
    service = _FakeService();
    controller = ProfileController(profileServiceInterface: service);
    // The tick only sends while the timer is active.
    controller.startLocationRecord();
  });

  tearDown(() {
    controller.stopLocationRecord();
    Get.reset();
  });

  test('L1 a position read that throws (GPS off) does not escape, sends nothing',
      () async {
    service.position = () => Future<Position?>.error(StateError('gps off'));
    await controller.recordLocation();
    expect(service.httpCalls, 0);
    expect(service.socketCalls, 0);
  });

  test('L2 no position: nothing is sent and the last real one is kept',
      () async {
    await controller.recordLocation();
    final RecordLocationBodyModel? real = controller.recordLocationBody;
    expect(real?.latitude, 31.5);

    service.position = () async => null;
    await controller.recordLocation();

    expect(service.httpCalls, 1);
    expect(controller.recordLocationBody, same(real));
  });

  test('L3 no config (nothing registered) uses the HTTP path without a throw',
      () async {
    expect(Get.isRegistered<SplashController>(), isFalse);
    await controller.recordLocation();
    expect(service.httpCalls, 1);
    expect(service.socketCalls, 0);
  });

  test('L4 a tick while one is running sends nothing extra', () async {
    service.sendGate = Completer<void>();
    final first = controller.recordLocation();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    final second = controller.recordLocation();
    service.sendGate!.complete();
    await first;
    await second;
    expect(service.httpCalls, 1);
    expect(service.positionCalls, 1);
  });

  test('L5 recovery: a failed tick, then a good one, records', () async {
    service.position = () => Future<Position?>.error(StateError('gps off'));
    await controller.recordLocation();
    expect(service.httpCalls, 0);

    service.position = () async => _position(31.6, 34.5);
    await controller.recordLocation();
    expect(service.httpCalls, 1);
    expect(service.sent.single.latitude, 31.6);
  });

  test('L6 a throwing send does not escape and the next tick still runs',
      () async {
    service.sendError = StateError('boom');
    await controller.recordLocation();
    service.sendError = null;
    await controller.recordLocation();
    expect(service.httpCalls, 2);
  });

  test('G1 guard: a real position is sent once with its coordinates',
      () async {
    await controller.recordLocation();
    expect(service.httpCalls, 1);
    expect(service.sent.single.latitude, 31.5);
    expect(service.sent.single.longitude, 34.4);
    expect(service.sent.single.location, 'place');
  });

  test('G2 guard: the HTTP body carries no token field', () {
    final body = RecordLocationBodyModel(
        latitude: 1, longitude: 2, location: 'x');
    expect(body.toJson().containsKey('token'), isFalse);
  });

  group('isUsableFix (never send fake coordinates)', () {
    test('L7 rejects null, NaN, infinite, out of range and 0/0', () {
      expect(ProfileService.isUsableFix(null, 1), isFalse);
      expect(ProfileService.isUsableFix(1, null), isFalse);
      expect(ProfileService.isUsableFix(double.nan, 1), isFalse);
      expect(ProfileService.isUsableFix(1, double.infinity), isFalse);
      expect(ProfileService.isUsableFix(91, 1), isFalse);
      expect(ProfileService.isUsableFix(1, 181), isFalse);
      expect(ProfileService.isUsableFix(0, 0), isFalse);
    });

    test('G5 guard: accepts a real pair, and an equator or meridian point', () {
      expect(ProfileService.isUsableFix(31.5, 34.4), isTrue);
      expect(ProfileService.isUsableFix(0, 34.4), isTrue);
      expect(ProfileService.isUsableFix(31.5, 0), isTrue);
    });
  });
}
