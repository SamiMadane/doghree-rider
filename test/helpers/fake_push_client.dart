import 'dart:async';

import 'package:doghree_rider/helper/push_client.dart';

/// Records every FCM call in order. No Firebase is used.
class FakePushClient extends PushClient {
  final List<String> log = [];
  String? token = 'device-token';
  bool failDeleteToken = false;
  bool failGetToken = false;

  /// When set, unsubscribe and deleteToken never complete (offline FCM).
  bool hang = false;

  /// Called before each recorded call, so a test can inspect app state at
  /// that moment.
  void Function(String call)? onCall;

  FakePushClient();

  Future<void> _maybeHang() =>
      hang ? Completer<void>().future : Future<void>.value();

  void _record(String call) {
    onCall?.call(call);
    log.add(call);
  }

  @override
  Future<bool> requestPermissionIos() async => true;

  @override
  Future<String?> getToken() async {
    _record('getToken');
    if (failGetToken) throw StateError('getToken failed');
    return token;
  }

  @override
  Future<void> subscribe(String topic) async => _record('subscribe:$topic');

  @override
  Future<void> unsubscribe(String topic) async {
    _record('unsubscribe:$topic');
    await _maybeHang();
  }

  @override
  Future<void> deleteToken() async {
    _record('deleteToken');
    await _maybeHang();
    if (failDeleteToken) throw StateError('deleteToken failed');
  }
}
