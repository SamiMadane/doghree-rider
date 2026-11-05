// Removes standalone print(...) / debugPrint(...) statements from lib/.
//
//   dart run tool/remove_prints.dart            -> dry run (report only)
//   dart run tool/remove_prints.dart --apply    -> write the changes
//   dart run tool/remove_prints.dart lib/features --apply   (limit to a folder)
//
// Safe by design: only whole statements that start a line and end with ';' are
// removed. Anything ambiguous (braceless if/else, arrow functions, inline
// callbacks, code after the call on the same line) is left untouched and
// listed so you can handle it by hand.
import 'dart:io';

final RegExp _stmtStart =
    RegExp(r'^[ \t]*(print|debugPrint)\(', multiLine: true);
final RegExp _anyCall = RegExp(r'(?<![\w.$])(print|debugPrint)\s*\(');

class _Range {
  final int start;
  final int end;
  _Range(this.start, this.end);
}

class _Note {
  final int line;
  final String text;
  _Note(this.line, this.text);
}

class _Result {
  final String output;
  final int removed;
  final List<_Note> skipped = [];
  final List<int> emptyBlocks = [];
  final List<_Note> remaining = [];
  _Result(this.output, this.removed);
}

void main(List<String> args) {
  final bool apply = args.contains('--apply');
  final List<String> paths = args.where((a) => !a.startsWith('--')).toList();
  final String root = paths.isEmpty ? 'lib' : paths.first;

  final Directory dir = Directory(root);
  if (!dir.existsSync()) {
    stderr.writeln('Folder "$root" not found. Run this from the project root.');
    exit(1);
  }

  int totalRemoved = 0;
  int touchedFiles = 0;
  final List<String> manual = [];
  final List<String> emptyBlocks = [];

  final List<File> files = dir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) {
    final String p = f.path.replaceAll('\\', '/');
    return p.endsWith('.dart') &&
        !p.endsWith('.g.dart') &&
        !p.endsWith('.freezed.dart');
  }).toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final File file in files) {
    final String path = file.path.replaceAll('\\', '/');
    final String? text = _tryRead(file);
    if (text == null) {
      stderr.writeln('Skipped (cannot read as UTF-8): $path');
      continue;
    }

    final _Result r = _process(text);

    for (final _Note n in r.skipped) {
      manual.add('$path:${n.line}  [${n.text}]  ${_snippet(text, n.line)}');
    }
    for (final _Note n in r.remaining) {
      manual.add('$path:${n.line}  [${n.text}]  ${_snippet(text, n.line)}');
    }
    for (final int line in r.emptyBlocks) {
      emptyBlocks.add('$path:$line');
    }

    if (r.removed > 0) {
      totalRemoved += r.removed;
      touchedFiles++;
      stdout.writeln('${r.removed.toString().padLeft(3)}  $path');
      if (apply) file.writeAsStringSync(r.output);
    }
  }

  stdout.writeln('');
  stdout.writeln('${apply ? 'Removed' : 'Would remove'} $totalRemoved '
      'statements in $touchedFiles files.');

  if (emptyBlocks.isNotEmpty) {
    stdout.writeln('\nBlocks that are now empty (check that nothing is swallowed silently):');
    for (final String s in emptyBlocks) {
      stdout.writeln('  $s');
    }
  }

  if (manual.isNotEmpty) {
    stdout.writeln('\nLeft untouched, handle by hand (${manual.length}):');
    for (final String s in manual) {
      stdout.writeln('  $s');
    }
  }

  if (!apply) {
    stdout.writeln('\nDRY RUN: nothing was written. Re-run with --apply.');
  } else {
    stdout.writeln('\nNext: dart fix --apply   (removes unused imports)');
    stdout.writeln('      flutter analyze');
  }
}

String? _tryRead(File file) {
  try {
    return file.readAsStringSync();
  } catch (_) {
    return null;
  }
}

String _snippet(String text, int line) {
  final List<String> lines = text.split('\n');
  final String l = lines[line - 1].trim();
  return l.length > 90 ? '${l.substring(0, 90)}...' : l;
}

int _lineOf(String s, int index) {
  int line = 1;
  for (int i = 0; i < index && i < s.length; i++) {
    if (s.codeUnitAt(i) == 10) line++;
  }
  return line;
}

_Result _process(String s) {
  final List<_Range> ranges = [];
  final List<_Note> skipped = [];
  final List<int> empties = [];

  for (final RegExpMatch m in _stmtStart.allMatches(s)) {
    final int start = m.start;
    final int open = m.end - 1;
    final int line = _lineOf(s, start);

    final int close = _matchParen(s, open);
    if (close < 0) {
      skipped.add(_Note(line, 'unbalanced parentheses'));
      continue;
    }

    int e = close + 1;
    while (e < s.length && (s[e] == ' ' || s[e] == '\t')) {
      e++;
    }
    if (e >= s.length || s[e] != ';') {
      skipped.add(_Note(line, 'not a plain statement'));
      continue;
    }
    e++;
    while (e < s.length && (s[e] == ' ' || s[e] == '\t')) {
      e++;
    }
    if (s.startsWith('//', e)) {
      final int nl = s.indexOf('\n', e);
      e = nl < 0 ? s.length : nl;
    }
    if (e < s.length && s[e] == '\r') e++;
    if (e < s.length && s[e] == '\n') {
      e++;
    } else if (e < s.length) {
      skipped.add(_Note(line, 'code after the call on the same line'));
      continue;
    }

    // The previous code line must end a statement or open/close a block;
    // otherwise this print may be the body of a braceless if/else/for/while.
    final String prev = _prevCodeLine(s, start);
    if (prev.isNotEmpty && !';{}:'.contains(prev[prev.length - 1])) {
      skipped.add(_Note(line, 'maybe braceless if/else, previous line: $prev'));
      continue;
    }

    int b = start - 1;
    while (b >= 0 && ' \t\r\n'.contains(s[b])) {
      b--;
    }
    int a = e;
    while (a < s.length && ' \t\r\n'.contains(s[a])) {
      a++;
    }
    if (b >= 0 && a < s.length && s[b] == '{' && s[a] == '}') {
      empties.add(line);
    }

    ranges.add(_Range(start, e));
  }

  final StringBuffer out = StringBuffer();
  int last = 0;
  for (final _Range r in ranges) {
    out.write(s.substring(last, r.start));
    last = r.end;
  }
  out.write(s.substring(last));

  final _Result result = _Result(out.toString(), ranges.length);
  result.skipped.addAll(skipped);
  result.emptyBlocks.addAll(empties);

  // Every other print/debugPrint call that was not removed.
  final List<String> lines = s.split('\n');
  int offset = 0;
  for (int i = 0; i < lines.length; i++) {
    final String lineText = lines[i];
    final String trimmed = lineText.trim();
    if (!trimmed.startsWith('//')) {
      for (final RegExpMatch m in _anyCall.allMatches(lineText)) {
        final int abs = offset + m.start;
        final bool removed = ranges.any((r) => abs >= r.start && abs < r.end);
        final bool alreadyListed = skipped.any((n) => n.line == i + 1);
        if (!removed && !alreadyListed) {
          result.remaining.add(_Note(i + 1, 'inline call'));
        }
      }
    }
    offset += lineText.length + 1;
  }

  return result;
}

String _prevCodeLine(String s, int start) {
  int end = start;
  while (end > 0) {
    final int lineEnd = end - 1;
    final int lineStart = lineEnd == 0 ? 0 : s.lastIndexOf('\n', lineEnd - 1) + 1;
    final String line = s.substring(lineStart, lineEnd).trim();
    if (line.isNotEmpty && !line.startsWith('//')) return line;
    end = lineStart;
  }
  return '';
}

bool _isIdentChar(String s, int i) {
  if (i < 0) return false;
  final int u = s.codeUnitAt(i);
  return (u >= 48 && u <= 57) ||
      (u >= 65 && u <= 90) ||
      (u >= 97 && u <= 122) ||
      u == 95 ||
      u == 36;
}

/// Index of the ')' that closes the '(' at [open], or -1.
int _matchParen(String s, int open) {
  int depth = 0;
  int p = open;
  while (p < s.length) {
    final String c = s[p];
    if (s.startsWith('//', p)) {
      final int nl = s.indexOf('\n', p);
      if (nl < 0) return -1;
      p = nl;
      continue;
    }
    if (s.startsWith('/*', p)) {
      final int end = s.indexOf('*/', p + 2);
      if (end < 0) return -1;
      p = end + 2;
      continue;
    }
    if (c == 'r' &&
        p + 1 < s.length &&
        (s[p + 1] == "'" || s[p + 1] == '"') &&
        !_isIdentChar(s, p - 1)) {
      p = _skipString(s, p);
      continue;
    }
    if (c == "'" || c == '"') {
      p = _skipString(s, p);
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

/// Returns the index just after the string literal that starts at [i]
/// (at the quote, or at the 'r' of a raw string).
int _skipString(String s, int i) {
  int p = i;
  bool raw = false;
  if (s[p] == 'r') {
    raw = true;
    p++;
  }
  final String q = s[p];
  final bool triple = s.startsWith(q * 3, p);
  p += triple ? 3 : 1;
  while (p < s.length) {
    final String c = s[p];
    if (!raw && c == '\\') {
      p += 2;
      continue;
    }
    if (!raw && c == '\$' && p + 1 < s.length && s[p + 1] == '{') {
      p = _skipBraces(s, p + 1);
      continue;
    }
    if (triple) {
      if (s.startsWith(q * 3, p)) return p + 3;
    } else {
      if (c == q) return p + 1;
      if (c == '\n') return p; // unterminated: bail out
    }
    p++;
  }
  return p;
}

/// [i] points at the '{' of a "${...}" interpolation; returns the index after '}'.
int _skipBraces(String s, int i) {
  int depth = 0;
  int p = i;
  while (p < s.length) {
    final String c = s[p];
    if (c == "'" || c == '"') {
      p = _skipString(s, p);
      continue;
    }
    if (c == '{') depth++;
    if (c == '}') {
      depth--;
      if (depth == 0) return p + 1;
    }
    p++;
  }
  return p;
}