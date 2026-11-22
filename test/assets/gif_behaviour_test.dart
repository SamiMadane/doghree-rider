import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// D-14, T3 (guard): the GIFs keep the behaviour ReplayImage relies on
/// (restart every 4 s). Values recorded from the originals with the Flutter
/// codec before D-14. Any re-encode must keep them exactly.
class _Gif {
  final String path;
  final int frames;
  final int repetitionCount; // -1 = forever, 0 = plays once
  final int frameMs;
  final int width;
  final int height;
  const _Gif(this.path, this.frames, this.repetitionCount, this.frameMs,
      this.width, this.height);
}

const List<_Gif> _gifs = [
  _Gif('assets/animations/doghree_rider.gif', 111, -1, 50, 794, 530),
  _Gif('assets/animations/delivered_success.gif', 61, 0, 50, 800, 800),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final _Gif g in _gifs) {
    test('T3 ${g.path}: frames, loop, timing and size unchanged', () async {
      final ui.Codec c =
          await ui.instantiateImageCodec(File(g.path).readAsBytesSync());
      expect(c.frameCount, g.frames);
      expect(c.repetitionCount, g.repetitionCount);
      for (int i = 0; i < g.frames; i++) {
        final ui.FrameInfo f = await c.getNextFrame();
        expect(f.duration, Duration(milliseconds: g.frameMs), reason: 'frame $i');
        expect([f.image.width, f.image.height], [g.width, g.height]);
        f.image.dispose();
      }
      c.dispose();
    });
  }
}
