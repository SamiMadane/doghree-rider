// ignore_for_file: empty_catches
// Read-only audit: finds Dart files, asset files and pubspec packages that
// nothing seems to use. It never deletes or edits anything.
//
//   dart run tool/find_unused.dart
//   dart run tool/find_unused.dart --entry=lib/main.dart --entry=lib/other_main.dart
//
// Output: printed on screen + build/unused_report.txt, and plain lists in
// build/unused_files.txt and build/unused_assets.txt (build/ is git-ignored).
import 'dart:io';

final RegExp _directive = RegExp(
    r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
    multiLine: true);
final RegExp _conditional = RegExp(r'''\bif\s*\([^)]*\)\s*['"]([^'"]+)['"]''');
final RegExp _stringConst = RegExp(
    r'''(?:const|final)\s+(?:String\s+)?(\w+)\s*=\s*['"]([^'"]*)['"]\s*;''');
final RegExp _dynamicAsset =
    RegExp(r'''['"][^'"\n]*assets/[^'"\n]*\$[^'"\n]*['"]''');

void main(List<String> args) {
  if (!File('pubspec.yaml').existsSync() || !Directory('lib').existsSync()) {
    stderr.writeln('Run this from the project root (where pubspec.yaml is).');
    exit(1);
  }

  final String pubspec = File('pubspec.yaml').readAsStringSync();
  final String pkg = RegExp(r'^name:\s*(\S+)', multiLine: true)
          .firstMatch(pubspec)
          ?.group(1) ??
      '';
  final List<String> entries = [
    for (final String a in args)
      if (a.startsWith('--entry=')) a.substring(8),
  ];
  if (entries.isEmpty) entries.add('lib/main.dart');

  final StringBuffer report = StringBuffer();
  void out(String s) {
    stdout.writeln(s);
    report.writeln(s);
  }

  final Map<String, String> lib = _readDart('lib');
  final Map<String, String> tests = {
    ..._readDart('test'),
    ..._readDart('integration_test'),
  };

  final List<String> deadFiles =
      _reportFiles(out, lib, tests, entries, pkg);
  final List<String> deadAssets = _reportAssets(out, pubspec, lib, tests);
  _reportPackages(out, pubspec, lib, tests);

  Directory('build').createSync(recursive: true);
  File('build/unused_report.txt').writeAsStringSync(report.toString());
  File('build/unused_files.txt').writeAsStringSync(deadFiles.join('\n'));
  File('build/unused_assets.txt').writeAsStringSync(deadAssets.join('\n'));
  stdout.writeln('\nSaved: build/unused_report.txt, build/unused_files.txt, '
      'build/unused_assets.txt');
}

// ---------------------------------------------------------------------------
// 1) Dart files
// ---------------------------------------------------------------------------

List<String> _reportFiles(void Function(String) out, Map<String, String> lib,
    Map<String, String> tests, List<String> entries, String pkg) {
  out('== 1) Dart files not reachable from ${entries.join(', ')} ==');

  final List<String> starts = [];
  for (final String e in entries) {
    final String n = _norm(e);
    if (lib.containsKey(n)) {
      starts.add(n);
    } else {
      out('  (entry not found: $e)');
    }
  }

  final Set<String> fromMain = _reach(lib, starts, pkg);

  final Set<String> testStarts = {};
  for (final MapEntry<String, String> t in tests.entries) {
    for (final String r in _directImports(t.key, t.value, pkg)) {
      if (lib.containsKey(r)) testStarts.add(r);
    }
  }
  final Set<String> fromTests = _reach(lib, testStarts, pkg);

  final List<String> dead =
      lib.keys.where((String f) => !fromMain.contains(f)).toList()..sort();
  final List<String> usedByTests =
      dead.where((String f) => fromTests.contains(f)).toList();
  final List<String> truly =
      dead.where((String f) => !fromTests.contains(f)).toList();

  for (final String f in truly) {
    out('  $f');
  }
  out('  -> ${truly.length} files (of ${lib.length}).');
  if (usedByTests.isNotEmpty) {
    out('\n  Only used by tests (delete together with their tests):');
    for (final String f in usedByTests) {
      out('  $f');
    }
  }
  out('  Note: a file used only through a "part" or by reflection/code '
      'generation may still show up here. Delete in small batches and build.\n');
  return truly;
}

List<String> _directImports(String file, String text, String pkg) {
  final List<String> uris = [
    for (final RegExpMatch m in _directive.allMatches(text)) m.group(1)!,
    for (final RegExpMatch m in _conditional.allMatches(text)) m.group(1)!,
  ];
  final List<String> resolved = [];
  for (final String u in uris) {
    final String? t = _resolve(file, u, pkg);
    if (t != null) resolved.add(t);
  }
  return resolved;
}

Set<String> _reach(
    Map<String, String> files, Iterable<String> starts, String pkg) {
  final Set<String> seen = {};
  final List<String> queue = [...starts];
  while (queue.isNotEmpty) {
    final String f = queue.removeLast();
    if (!seen.add(f)) continue;
    final String? text = files[f];
    if (text == null) continue;
    for (final String t in _directImports(f, text, pkg)) {
      if (files.containsKey(t) && !seen.contains(t)) queue.add(t);
    }
  }
  return seen;
}

String? _resolve(String from, String uri, String pkg) {
  if (uri.startsWith('dart:')) return null;
  if (uri.startsWith('package:')) {
    final String prefix = 'package:$pkg/';
    return uri.startsWith(prefix) ? 'lib/${uri.substring(prefix.length)}' : null;
  }
  if (uri.contains(':')) return null;
  return Uri.parse(from).resolve(uri).path;
}

// ---------------------------------------------------------------------------
// 2) Assets
// ---------------------------------------------------------------------------

List<String> _reportAssets(void Function(String) out, String pubspec,
    Map<String, String> lib, Map<String, String> tests) {
  out('== 2) Asset files that nothing seems to use ==');

  final List<File> assets = _assetFiles(_declaredAssetEntries(pubspec));
  if (assets.isEmpty) {
    out('  (no assets found in pubspec.yaml)\n');
    return [];
  }

  final String dartText = [...lib.values, ...tests.values].join('\n');

  // Everything that may mention an asset: Dart, pubspec (except the asset
  // list itself), Android and iOS sources.
  final StringBuffer all = StringBuffer(dartText);
  for (final String line in pubspec.split('\n')) {
    if (!line.trim().startsWith('- ')) all.writeln(line);
  }
  all.writeln(_readText('android/app/src/main',
      {'xml', 'kt', 'java', 'gradle', 'kts'}));
  all.writeln(_readText('ios/Runner', {'plist', 'swift', 'm', 'h'}));
  final String allText = all.toString();

  final Map<String, String> constants = {};
  for (final RegExpMatch m in _stringConst.allMatches(dartText)) {
    constants[m.group(1)!] = m.group(2)!;
  }

  final List<MapEntry<String, int>> unused = [];
  final Map<String, String> why = {};

  for (final File f in assets) {
    final String path = _norm(f.path);
    final String base = path.split('/').last;
    if (base == '.DS_Store') continue;

    final int occurrences = base.allMatches(allText).length;
    if (occurrences == 0) {
      unused.add(MapEntry(path, f.lengthSync()));
      why[path] = 'not referenced anywhere';
      continue;
    }

    final List<String> consts = [
      for (final MapEntry<String, String> e in constants.entries)
        if (e.value == base || e.value.endsWith('/$base')) e.key,
    ];
    if (consts.isEmpty) continue; // referenced some other way: assume used
    if (occurrences > consts.length) continue; // also referenced elsewhere

    final bool anyUse = consts.any((String n) =>
        RegExp('\\b${RegExp.escape(n)}\\b').allMatches(dartText).length > 1);
    if (!anyUse) {
      unused.add(MapEntry(path, f.lengthSync()));
      why[path] = 'only declared as ${consts.join(', ')}, never used';
    }
  }

  unused.sort((a, b) => b.value.compareTo(a.value));
  int total = 0;
  for (final MapEntry<String, int> u in unused) {
    total += u.value;
    out('  ${(u.value / 1024).toStringAsFixed(1).padLeft(8)} KB  ${u.key}'
        '   (${why[u.key]})');
  }
  out('  -> ${unused.length} files, ${(total / 1024).toStringAsFixed(1)} KB '
      '(of ${assets.length} assets).');

  final List<String> dynamicHits = [
    for (final RegExpMatch m in _dynamicAsset.allMatches(dartText)) m.group(0)!,
  ];
  if (dynamicHits.isNotEmpty) {
    out('\n  Assets built dynamically (not detectable, check manually):');
    for (final String s in dynamicHits.take(8)) {
      out('    $s');
    }
  }
  out('  Note: assets used only by native code, or loaded by a computed name, '
      'can show up here. Review the list before deleting.\n');
  return unused.map((MapEntry<String, int> e) => e.key).toList();
}

List<String> _declaredAssetEntries(String pubspec) {
  final List<String> entries = [];
  bool inAssets = false;
  for (final String raw in pubspec.split('\n')) {
    final String line = raw.trimRight();
    if (!inAssets) {
      if (RegExp(r'^\s{2}assets:\s*$').hasMatch(line)) inAssets = true;
      continue;
    }
    final String t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final RegExpMatch? m = RegExp(r'^-\s+(.+?)\s*(#.*)?$').firstMatch(t);
    if (m == null) break;
    entries.add(m.group(1)!.replaceAll('"', '').replaceAll("'", ''));
  }
  return entries;
}

List<File> _assetFiles(List<String> entries) {
  final Set<String> seen = {};
  final List<File> files = [];
  for (final String e in entries) {
    if (e.endsWith('/')) {
      final Directory d = Directory(e);
      if (!d.existsSync()) continue;
      for (final FileSystemEntity f in d.listSync(followLinks: false)) {
        if (f is File && seen.add(_norm(f.path))) files.add(f);
      }
    } else {
      final File f = File(e);
      if (f.existsSync() && seen.add(_norm(f.path))) files.add(f);
    }
  }
  return files;
}

// ---------------------------------------------------------------------------
// 3) pubspec packages
// ---------------------------------------------------------------------------

void _reportPackages(void Function(String) out, String pubspec,
    Map<String, String> lib, Map<String, String> tests) {
  out('== 3) Packages in pubspec.yaml with no import in lib/ or test/ ==');

  const Set<String> implicit = {
    'flutter',
    'flutter_test',
    'flutter_localizations',
    'flutter_web_plugins',
    'integration_test',
    'cupertino_icons',
    'flutter_lints',
    'lints',
    'build_runner',
    'very_good_analysis',
  };

  final Map<String, String> deps = {};
  String? section;
  for (final String raw in pubspec.split('\n')) {
    final String line = raw.trimRight();
    if (line.isEmpty || line.trimLeft().startsWith('#')) continue;
    final RegExpMatch? top = RegExp(r'^([A-Za-z_]+):').firstMatch(line);
    if (top != null) {
      final String k = top.group(1)!;
      section = (k == 'dependencies' || k == 'dev_dependencies') ? k : null;
      continue;
    }
    if (section == null) continue;
    final RegExpMatch? d = RegExp(r'^  ([a-z0-9_]+):').firstMatch(line);
    if (d != null) deps[d.group(1)!] = section;
  }

  final String dartText = [...lib.values, ...tests.values].join('\n');
  final List<String> unused = [];
  for (final MapEntry<String, String> d in deps.entries) {
    final String name = d.key;
    if (implicit.contains(name)) continue;
    if (dartText.contains('package:$name/')) continue;
    // Tools configured with their own top-level pubspec key
    // (flutter_launcher_icons, flutter_native_splash, ...).
    if (RegExp('^$name:', multiLine: true).hasMatch(pubspec)) continue;
    unused.add('${d.value == 'dev_dependencies' ? 'dev ' : '    '} $name');
  }
  unused.sort();
  for (final String u in unused) {
    out('  $u');
  }
  out('  -> ${unused.length} packages.');
  out('  Note: remove ONE at a time, then run flutter pub get, build and test '
      'on a real device. Plugins that register native code, and dev tools '
      'like json_serializable, need no import and can look unused.\n');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _norm(String p) => p.replaceAll('\\', '/');

Map<String, String> _readDart(String dir) {
  final Map<String, String> files = {};
  final Directory d = Directory(dir);
  if (!d.existsSync()) return files;
  for (final FileSystemEntity e
      in d.listSync(recursive: true, followLinks: false)) {
    if (e is File && e.path.endsWith('.dart')) {
      try {
        files[_norm(e.path)] = e.readAsStringSync();
      } catch (_) {}
    }
  }
  return files;
}

String _readText(String dir, Set<String> extensions) {
  final Directory d = Directory(dir);
  if (!d.existsSync()) return '';
  final StringBuffer b = StringBuffer();
  for (final FileSystemEntity e
      in d.listSync(recursive: true, followLinks: false)) {
    if (e is! File) continue;
    final int dot = e.path.lastIndexOf('.');
    if (dot < 0 || !extensions.contains(e.path.substring(dot + 1))) continue;
    try {
      b.writeln(e.readAsStringSync());
    } catch (_) {}
  }
  return b.toString();
}