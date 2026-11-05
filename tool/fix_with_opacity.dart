// Replaces `.withOpacity(X)` with `.withValues(alpha: X)` in lib/.
//   dart run tool/fix_with_opacity.dart            -> dry run
//   dart run tool/fix_with_opacity.dart --apply    -> write changes
import 'dart:io';

const String _needle = '.withOpacity(';

void main(List<String> args) {
  final bool apply = args.contains('--apply');
  int total = 0;
  final files = Directory('lib')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final File f in files) {
    final String s = f.readAsStringSync();
    final StringBuffer out = StringBuffer();
    int last = 0;
    int n = 0;
    int from = 0;
    while (true) {
      final int i = s.indexOf(_needle, from);
      if (i < 0) break;
      final int open = i + _needle.length - 1;
      final int close = _match(s, open);
      if (close < 0) {
        from = i + 1;
        continue;
      }
      final String arg = s.substring(open + 1, close).trim();
      out.write(s.substring(last, i));
      out.write('.withValues(alpha: $arg)');
      last = close + 1;
      from = close + 1;
      n++;
    }
    if (n == 0) continue;
    out.write(s.substring(last));
    total += n;
    stdout.writeln('${n.toString().padLeft(3)}  ${f.path.replaceAll('\\', '/')}');
    if (apply) f.writeAsStringSync(out.toString());
  }
  stdout.writeln('\n${apply ? 'Changed' : 'Would change'} $total places.');
  if (!apply) stdout.writeln('DRY RUN. Re-run with --apply.');
  if (apply) stdout.writeln('Next: dart format lib && flutter analyze');
}

int _skipStr(String s, int i) {
  final String q = s[i];
  int p = i + 1;
  while (p < s.length) {
    if (s[p] == '\\') {
      p += 2;
      continue;
    }
    if (s[p] == q) return p + 1;
    p++;
  }
  return p;
}

int _match(String s, int open) {
  int depth = 0;
  int p = open;
  while (p < s.length) {
    final String c = s[p];
    if (c == "'" || c == '"') {
      p = _skipStr(s, p);
      continue;
    }
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return p;
    }
    p++;
  }
  return -1;
}