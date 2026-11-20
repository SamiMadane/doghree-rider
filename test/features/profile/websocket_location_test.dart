import 'dart:async';

import 'package:doghree_rider/common/models/config_model.dart';
import 'package:doghree_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:doghree_rider/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../helpers/fake_api_client.dart';

class _FakeSink implements WebSocketSink {
  final List<dynamic> added = [];
  int closes = 0;
  bool failAdd = false;

  @override
  void add(dynamic data) {
    if (failAdd) throw StateError('add failed');
    added.add(data);
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closes++;
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<dynamic> stream) async {}

  @override
  Future<void> get done => Future<void>.value();
}

class _FakeChannel
    implements WebSocketChannel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final _FakeSink fakeSink = _FakeSink();
  final StreamController<dynamic> events = StreamController<dynamic>();
  Future<void> readyFuture = Future<void>.value();

  @override
  Stream<dynamic> get stream => events.stream;

  @override
  WebSocketSink get sink => fakeSink;

  @override
  Future<void> get ready => readyFuture;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;
}

/// Audit row 39: the WebSocket location path is safe (it is off live).
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;
  late _FakeChannel channel;
  late List<Uri> connected;
  ConfigModel? config;
  bool factoryThrows = false;

  ProfileRepository repo() => ProfileRepository(
        apiClient: api,
        sharedPreferences: prefs,
        config: () => config,
        socketFactory: (Uri uri) {
          connected.add(uri);
          if (factoryThrows) throw StateError('connect failed');
          return channel;
        },
      );

  RecordLocationBodyModel body() =>
      RecordLocationBodyModel(latitude: 31.5, longitude: 34.4, location: 'x');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
    channel = _FakeChannel();
    connected = [];
    factoryThrows = false;
    config = ConfigModel(
      webSocketStatus: true,
      webSocketUri: 'ws://socket.local',
      webSocketPort: 6001,
      webSocketKey: 'k',
    );
  });

  test('W1 a connect error does not escape and returns false', () async {
    factoryThrows = true;
    expect(await repo().recordWebSocketLocation(body()), isFalse);
  });

  test('W2 a missing config or field opens nothing', () async {
    config = null;
    expect(await repo().recordWebSocketLocation(body()), isFalse);

    config = ConfigModel(webSocketUri: 'ws://socket.local', webSocketPort: 1);
    expect(await repo().recordWebSocketLocation(body()), isFalse);

    config = ConfigModel(
        webSocketUri: '', webSocketPort: 1, webSocketKey: 'k');
    expect(await repo().recordWebSocketLocation(body()), isFalse);

    expect(connected, isEmpty);
  });

  test('W3 a stream error after connect is swallowed', () async {
    final bool ok = await repo().recordWebSocketLocation(body());
    channel.events.addError(StateError('late socket error'));
    await Future<void>.delayed(Duration.zero);
    expect(ok, isTrue);
  });

  test('W4 the socket is closed on success, on a failed ready and on a failed add',
      () async {
    expect(await repo().recordWebSocketLocation(body()), isTrue);
    expect(channel.fakeSink.closes, 1);

    channel = _FakeChannel()
      ..readyFuture = Future<void>.error(StateError('refused'));
    expect(await repo().recordWebSocketLocation(body()), isFalse);
    expect(channel.fakeSink.closes, 1);
    expect(channel.fakeSink.added, isEmpty);

    channel = _FakeChannel()..fakeSink.failAdd = true;
    expect(await repo().recordWebSocketLocation(body()), isFalse);
    expect(channel.fakeSink.closes, 1);
  });

  test('G3 guard: a good tick sends the body once, and clears the token',
      () async {
    final b = body();
    expect(await repo().recordWebSocketLocation(b), isTrue);
    expect(channel.fakeSink.added, hasLength(1));
    expect(channel.fakeSink.added.single as String, contains('"latitude":31.5'));
    expect(connected.single.toString(),
        'ws://socket.local:6001/delivery-man/live-location?appKey=k');
    expect(b.token, isNull);
  });
}
