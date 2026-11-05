// Rewrites `color: X` inside SvgPicture.*(...) to
// `colorFilter: ColorFilter.mode(X, BlendMode.srcIn)`.
//   dart run tool/fix_svg_color.dart            -> dry run
//   dart run tool/fix_svg_color.dart --apply    -> write changes
import 'dart:io';

final RegExp _start =
    RegExp(r'SvgPicture\.(asset|network|string|file|memory)\(');

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
    for (final RegExpMatch m in _start.allMatches(s)) {
      if (m.start < last) continue;
      final int open = m.end - 1;
      final int close = _match(s, open);
      if (close < 0) continue;
      final List<Object>? r = _fix(s, open, close);
      if (r == null) continue;
      out.write(s.substring(last, r[0] as int));
      out.write(r[2] as String);
      last = r[1] as int;
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

bool _ws(String c) => c == ' ' || c == '\t' || c == '\n' || c == '\r';

/// Returns [start, end, replacement] for the `color:` argument, or null.
List<Object>? _fix(String s, int open, int close) {
  int depth = 0;
  String prev = '(';
  int p = open + 1;
  while (p < close) {
    final String c = s[p];
    if (c == "'" || c == '"') {
      p = _skipStr(s, p);
      prev = '"';
      continue;
    }
    if ('([{'.contains(c)) {
      depth++;
      prev = c;
      p++;
      continue;
    }
    if (')]}'.contains(c)) {
      depth--;
      prev = c;
      p++;
      continue;
    }
    if (depth == 0 &&
        s.startsWith('color:', p) &&
        (prev == '(' || prev == ',')) {
      int e = p + 6;
      while (e < close && _ws(s[e])) {
        e++;
      }
      final int exprStart = e;
      int d = 0;
      while (e < close) {
        final String x = s[e];
        if (x == "'" || x == '"') {
          e = _skipStr(s, e);
          continue;
        }
        if ('([{'.contains(x)) d++;
        if (')]}'.contains(x)) d--;
        if (d == 0 && x == ',') break;
        e++;
      }
      final String expr = s.substring(exprStart, e).trim();
      if (expr.isEmpty) return null;
      return [p, e, 'colorFilter: ColorFilter.mode($expr, BlendMode.srcIn)'];
    }
    if (!_ws(c)) prev = c;
    p++;
  }
  return null;
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