import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Result of the earnings statement download (audit row 41). [bytes] are the
/// raw response bytes, never text decoded and re-encoded.
class InvoiceDownload {
  final int? statusCode;
  final Uint8List? bytes;

  /// The server message of a failed response, if any.
  final String? message;

  const InvoiceDownload({this.statusCode, this.bytes, this.message});

  /// True only for a 200 whose bytes start with the PDF signature `%PDF-`.
  bool get isPdf => statusCode == 200 && looksLikePdf(bytes);

  static bool looksLikePdf(List<int>? bytes) {
    const List<int> signature = [0x25, 0x50, 0x44, 0x46, 0x2D]; // %PDF-
    if (bytes == null || bytes.length < signature.length) return false;
    for (int i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return true;
  }
}

/// Writes the statement to disk and opens it. Replaced in tests.
abstract class InvoiceSaver {
  /// Returns true when a viewer opened the file. Throws when writing fails.
  Future<bool> saveAndOpen(String fileName, Uint8List bytes);
}

class FileInvoiceSaver implements InvoiceSaver {
  const FileInvoiceSaver();

  @override
  Future<bool> saveAndOpen(String fileName, Uint8List bytes) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/$fileName';
    await File(path).writeAsBytes(bytes, flush: true);
    final OpenResult result = await OpenFilex.open(path);
    return result.type == ResultType.done;
  }
}
