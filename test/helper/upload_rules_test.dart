import 'dart:io';

import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/helper/image_upload_rules.dart';
import 'package:doghree_rider/helper/upload_format.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Leading bytes of each format, padded to 16.
List<int> pad(List<int> b) => [...b, ...List<int>.filled(16, 0)].sublist(0, 16);
final List<int> jpegHead = pad([0xFF, 0xD8, 0xFF, 0xE0]);
final List<int> pngHead = pad([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
final List<int> webpHead = pad([...'RIFF'.codeUnits, 1, 2, 3, 4, ...'WEBP'.codeUnits]);
final List<int> pdfHead = pad('%PDF-1.7'.codeUnits);
final List<int> heicHead = pad([0, 0, 0, 24, ...'ftyp'.codeUnits, ...'heic'.codeUnits]);
final List<int> gifHead = pad('GIF89a'.codeUnits);

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('d09_'));
  tearDown(() async => dir.delete(recursive: true));

  Future<XFile> file(String name, List<int> head, {int size = 1024}) async {
    final File f = File('${dir.path}/$name');
    await f.writeAsBytes([...head, ...List<int>.filled(size - head.length, 7)]);
    return XFile(f.path);
  }

  group('UploadFormats.sniff', () {
    test('F1 jpeg', () => expect(UploadFormats.sniff(jpegHead), UploadFormat.jpeg));
    test('F2 png', () => expect(UploadFormats.sniff(pngHead), UploadFormat.png));
    test('F3 webp', () => expect(UploadFormats.sniff(webpHead), UploadFormat.webp));
    test('F4 pdf', () => expect(UploadFormats.sniff(pdfHead), UploadFormat.pdf));
    test('F5 heic', () => expect(UploadFormats.sniff(heicHead), UploadFormat.heic));
    test('F6 gif is not an uploadable image', () {
      expect(UploadFormats.sniff(gifHead), UploadFormat.gif);
      expect(UploadFormats.isUploadableImage(UploadFormat.gif), isFalse);
    });
    test('F7 short or empty input is unknown', () {
      expect(UploadFormats.sniff(const []), UploadFormat.unknown);
      expect(UploadFormats.sniff(const [0xFF, 0xD8]), UploadFormat.unknown);
      expect(UploadFormats.mediaTypeFor(UploadFormat.unknown).mimeType,
          'application/octet-stream');
    });
  });

  group('ImageUploadRules.check', () {
    test('I1 a small jpeg is ok', () async {
      expect(await ImageUploadRules.check(await file('a.jpg', jpegHead)),
          ImageCheck.ok);
    });
    test('I2 a small png is ok', () async {
      expect(await ImageUploadRules.check(await file('a.png', pngHead)),
          ImageCheck.ok);
    });
    test('I3 a webp is ok', () async {
      expect(await ImageUploadRules.check(await file('a.webp', webpHead)),
          ImageCheck.ok);
    });
    test('I4 heic content is unsupported, even named .jpg', () async {
      expect(await ImageUploadRules.check(await file('a.jpg', heicHead)),
          ImageCheck.unsupported);
    });
    test('I5 over 2 MB is too large', () async {
      final XFile big = await file('big.jpg', jpegHead,
          size: ImageUploadRules.maxImageBytes + 1);
      expect(await ImageUploadRules.check(big), ImageCheck.tooLarge);
      final XFile edge =
          await file('edge.jpg', jpegHead, size: ImageUploadRules.maxImageBytes);
      expect(await ImageUploadRules.check(edge), ImageCheck.ok);
    });
    test('I6 a missing or empty file is unreadable, never a throw', () async {
      expect(await ImageUploadRules.check(XFile('${dir.path}/gone.jpg')),
          ImageCheck.unreadable);
      final File empty = File('${dir.path}/empty.jpg')..writeAsBytesSync([]);
      expect(await ImageUploadRules.check(XFile(empty.path)),
          ImageCheck.unreadable);
    });
    test('I7 the limit is the one named constant: 2 MB', () {
      expect(ImageUploadRules.maxImageBytes, 2 * 1024 * 1024);
      expect(ImageUploadRules.messageKey(ImageCheck.tooLarge),
          'please_upload_lower_size_file');
      expect(ImageUploadRules.messageKey(ImageCheck.unsupported),
          'photo_format_not_supported');
    });
  });

  group('classifyPickError (codes only)', () {
    test('E1 camera denied', () {
      expect(classifyPickError(PlatformException(code: 'camera_access_denied')),
          PickFailure.cameraDenied);
    });
    test('E2 photo library denied', () {
      expect(classifyPickError(PlatformException(code: 'photo_access_denied')),
          PickFailure.galleryDenied);
    });
    test('E3 no camera', () {
      expect(classifyPickError(PlatformException(code: 'no_available_camera')),
          PickFailure.noCamera);
    });
    test('E4 anything else, whatever its text', () {
      expect(
          classifyPickError(PlatformException(
              code: 'x', message: 'camera_access_denied')),
          PickFailure.failed);
      expect(classifyPickError(StateError('boom')), PickFailure.failed);
      expect(pickFailureKey(PickFailure.failed), 'image_pick_failed');
    });
  });

  group('multipart labelling (audit row 45)', () {
    late ApiClient api;
    final List<http.MultipartFile> sent = [];

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      api = ApiClient(
          appBaseUrl: 'http://fake.local',
          sharedPreferences: await SharedPreferences.getInstance());
      sent.clear();
    });

    Future<void> upload(XFile f) => http.runWithClient(
          () => api.postMultipartData('/up', {'a': 'b'}, [MultipartBody('image', f)],
              handleError: false),
          () => MockClient.streaming((request, body) async {
            sent.addAll((request as http.MultipartRequest).files);
            await body.drain<void>();
            return http.StreamedResponse(Stream.value('{}'.codeUnits), 200);
          }),
        );

    test('M1 a HEIC file is not labelled image/jpeg', () async {
      await upload(await file('photo.heic', heicHead));
      expect(sent, hasLength(1));
      expect(sent.single.contentType.mimeType, isNot('image/jpeg'));
      expect(sent.single.contentType.mimeType, 'image/heic');
    });

    test('M2 JPEG bytes named .png are labelled by content', () async {
      await upload(await file('photo.png', jpegHead));
      expect(sent.single.contentType.mimeType, 'image/jpeg');
      expect(sent.single.filename, 'photo.jpg');
    });

    test('M3 guard: a real png keeps its name and type', () async {
      await upload(await file('photo.png', pngHead));
      expect(sent.single.contentType.mimeType, 'image/png');
      expect(sent.single.filename, 'photo.png');
    });
  });
}
