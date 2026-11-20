import 'package:doghree_rider/helper/order_ringing.dart';

/// Records the Android ringing calls. No platform channel is used.
class FakeRingingClient extends RingingClient {
  bool running;
  bool failIsRunning = false;
  int stopCalls = 0;
  final List<String> deletedChannels = [];

  FakeRingingClient({this.running = true});

  @override
  Future<bool> isRunning() async {
    if (failIsRunning) throw StateError('platform error');
    return running;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    running = false;
  }

  @override
  Future<void> deleteChannel(String id) async => deletedChannels.add(id);
}
