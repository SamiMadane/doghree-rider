import 'package:doghree_rider/features/html/domain/repositories/html_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// D-13: which raw bodies are a privacy or terms page.
void main() {
  test('H4 an empty body, "" and null are an empty page', () {
    expect(HtmlRepository.readHtmlText(null), '');
    expect(HtmlRepository.readHtmlText(''), '');
    expect(HtmlRepository.readHtmlText('  '), '');
    expect(HtmlRepository.readHtmlText('""'), '');
    expect(HtmlRepository.readHtmlText('null'), '');
  });

  test('H5 a JSON string is the page', () {
    expect(HtmlRepository.readHtmlText('"<p>Policy</p>"'), '<p>Policy</p>');
  });

  test('H6 raw HTML or another JSON shape is not the page', () {
    expect(HtmlRepository.readHtmlText('<html><body>Login</body></html>'),
        isNull);
    expect(HtmlRepository.readHtmlText('{"message":"x"}'), isNull);
    expect(HtmlRepository.readHtmlText('[1]'), isNull);
  });
}
