import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

/// The real type of an upload, read from its first bytes (audit row 45).
/// The server stores a file by the type it detects from the content
/// (API guide v3), so the app labels it the same way, never by extension.
enum UploadFormat { jpeg, png, webp, pdf, heic, gif, unknown }

class UploadFormats {
  UploadFormats._();

  /// How many leading bytes [sniff] needs.
  static const int headLength = 16;

  static const List<String> _heifBrands = [
    'heic', 'heix', 'hevc', 'hevx', 'heim', 'heis', 'mif1', 'msf1', 'avif',
  ];

  static UploadFormat sniff(List<int> head) {
    bool at(int offset, List<int> bytes) {
      if (head.length < offset + bytes.length) return false;
      for (int i = 0; i < bytes.length; i++) {
        if (head[offset + i] != bytes[i]) return false;
      }
      return true;
    }

    if (at(0, const [0xFF, 0xD8, 0xFF])) return UploadFormat.jpeg;
    if (at(0, const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return UploadFormat.png;
    }
    if (at(0, 'RIFF'.codeUnits) && at(8, 'WEBP'.codeUnits)) {
      return UploadFormat.webp;
    }
    if (at(0, '%PDF-'.codeUnits)) return UploadFormat.pdf;
    if (at(0, 'GIF8'.codeUnits)) return UploadFormat.gif;
    if (at(4, 'ftyp'.codeUnits)) {
      for (final String brand in _heifBrands) {
        if (at(8, brand.codeUnits)) return UploadFormat.heic;
      }
    }
    return UploadFormat.unknown;
  }

  /// The images the app may upload (the server whitelist minus pdf).
  static bool isUploadableImage(UploadFormat f) =>
      f == UploadFormat.jpeg || f == UploadFormat.png || f == UploadFormat.webp;

  static MediaType mediaTypeFor(UploadFormat f) {
    switch (f) {
      case UploadFormat.jpeg:
        return MediaType('image', 'jpeg');
      case UploadFormat.png:
        return MediaType('image', 'png');
      case UploadFormat.webp:
        return MediaType('image', 'webp');
      case UploadFormat.pdf:
        return MediaType('application', 'pdf');
      case UploadFormat.heic:
        return MediaType('image', 'heic');
      case UploadFormat.gif:
        return MediaType('image', 'gif');
      case UploadFormat.unknown:
        return MediaType('application', 'octet-stream');
    }
  }

  /// [name] with the extension of its real content. Unknown content keeps
  /// the original name.
  static String fileNameFor(String name, UploadFormat f) {
    final String? ext = switch (f) {
      UploadFormat.jpeg => '.jpg',
      UploadFormat.png => '.png',
      UploadFormat.webp => '.webp',
      UploadFormat.pdf => '.pdf',
      UploadFormat.heic => '.heic',
      UploadFormat.gif => '.gif',
      UploadFormat.unknown => null,
    };
    if (ext == null) return name;
    final String current = p.extension(name).toLowerCase();
    if (current == ext || (ext == '.jpg' && current == '.jpeg')) return name;
    return '${p.basenameWithoutExtension(name)}$ext';
  }
}
