import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// D-14, T2: the converted assets listed in asset_conversion.json are in
/// place, smaller than their originals, decode, and keep the agreed pixel
/// size (never upscaled, at least the 3x floor). Fails on the pre-D-14 tree.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, dynamic> manifest = jsonDecode(
          File('test/assets/asset_conversion.json').readAsStringSync())
      as Map<String, dynamic>;
  final List<dynamic> files = manifest['files'] as List<dynamic>;

  test('T2a the manifest covers the 29 approved files', () {
    expect(files.length, 29);
  });

  for (final dynamic raw in files) {
    final Map<String, dynamic> e = raw as Map<String, dynamic>;
    final String path = e['path'] as String;
    final String original = e['original'] as String;

    test('T2 $path', () async {
      final File f = File(path);
      expect(f.existsSync(), isTrue, reason: 'converted file missing');
      if (path != original) {
        expect(File(original).existsSync(), isFalse,
            reason: 'original must be gone from assets/ (git history keeps it)');
      }
      final int bytes = f.lengthSync();
      expect(bytes, lessThan(e['originalBytes'] as int),
          reason: 'converted file must be smaller than the original');

      final ui.Codec codec = await ui.instantiateImageCodec(f.readAsBytesSync());
      final ui.FrameInfo frame = await codec.getNextFrame();
      final int w = frame.image.width, h = frame.image.height;
      frame.image.dispose();
      codec.dispose();

      final List<dynamic> px = e['px'] as List<dynamic>;
      final List<dynamic> orig = e['originalPx'] as List<dynamic>;
      expect([w, h], [px[0], px[1]]);
      expect(w, lessThanOrEqualTo(orig[0] as int), reason: 'never upscale');
      expect(h, lessThanOrEqualTo(orig[1] as int), reason: 'never upscale');
      expect(math.max(w, h), greaterThanOrEqualTo(e['minLongPx'] as int));
    });
  }
}
