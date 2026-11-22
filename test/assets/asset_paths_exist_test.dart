import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// D-14, T1 + T4: every asset path the app names exists on disk, and every
/// raster file under assets/image and assets/animations decodes.
/// Guards: they pass before and after the conversion.

const Map<String, String> _prefixes = {
  'imagePath': 'assets/image',
  'animationPath': 'assets/animations',
  'iconPath': 'assets/icon',
  'mapPath': 'assets/map',
};

/// Audit row 76: `languageBackground` points to a file that does not exist
/// (no code navigates to `/language`). Kept open on purpose.
const Set<String> _knownMissing = {'assets/image/language_bg.png'};

Map<String, String> managerAssetPaths() {
  final String src = File('lib/util/manager_assets.dart').readAsStringSync();
  final RegExp decl =
      RegExp(r"static const String (\w+)\s*=\s*'([^']+)'", multiLine: true);
  final Map<String, String> out = {};
  for (final RegExpMatch m in decl.allMatches(src)) {
    String path = m.group(2)!;
    _prefixes.forEach((k, v) => path = path.replaceAll('\$$k', v));
    out[m.group(1)!] = path;
  }
  return out;
}

Set<String> literalPathsInLib() {
  final RegExp lit = RegExp(r"'(assets/[^'$]+)'");
  final Set<String> out = {};
  for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      for (final RegExpMatch m in lit.allMatches(f.readAsStringSync())) {
        out.add(m.group(1)!);
      }
    }
  }
  return out;
}

Set<String> yamlImagePaths() {
  final RegExp img = RegExp(r'''(assets/[^\s"']+\.(?:png|jpg|webp))''');
  final Set<String> out = {};
  for (final String f in ['pubspec.yaml', 'flutter_native_splash.yaml']) {
    for (final RegExpMatch m in img.allMatches(File(f).readAsStringSync())) {
      out.add(m.group(1)!);
    }
  }
  return out;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('T1a every ManagerAssets path exists (only row 76 is known missing)',
      () {
    final Map<String, String> paths = managerAssetPaths();
    expect(paths.length, greaterThan(80));
    final Set<String> missing = {
      for (final String p in paths.values)
        if (!File(p).existsSync()) p,
    };
    expect(missing, _knownMissing);
  });

  test('T1b every literal assets/ path in lib exists', () {
    final Set<String> lits = literalPathsInLib();
    expect(lits, isNotEmpty);
    for (final String p in lits) {
      // The folder constants in manager_assets.dart ('assets/image', ...)
      // are directories; everything with an extension is a file.
      final bool isDir = !p.split('/').last.contains('.');
      expect(isDir ? Directory(p).existsSync() : File(p).existsSync(), isTrue,
          reason: p);
    }
  });

  test('T1c every image path in pubspec and native splash config exists', () {
    final Set<String> paths = yamlImagePaths();
    expect(paths, isNotEmpty);
    for (final String p in paths) {
      expect(File(p).existsSync(), isTrue, reason: p);
    }
  });

  test('T4 every raster asset decodes', () async {
    final RegExp raster = RegExp(r'\.(png|jpe?g|webp|gif)$');
    final List<File> files = [
      for (final String d in ['assets/image', 'assets/animations'])
        ...Directory(d)
            .listSync()
            .whereType<File>()
            .where((f) => raster.hasMatch(f.path)),
    ];
    expect(files, isNotEmpty);
    for (final File f in files) {
      final Uint8List bytes = f.readAsBytesSync();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0), reason: f.path);
      frame.image.dispose();
      codec.dispose();
    }
  });
}
