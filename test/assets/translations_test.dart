import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// D-15: the translation files stay valid and complete.
/// Guards (pass before and after D-15): JSON/BOM, duplicate keys, key sets,
/// placeholders, empty values.
/// Fail on the pre-D-15 files: missing statically referenced keys (17),
/// composed-key rules (Arabic "ago" values), glossary, location disclosure.

const List<String> _langs = ['en', 'ar'];

Map<String, String> _load(String lang) {
  final String raw = File('assets/language/$lang.json').readAsStringSync();
  return Map<String, String>.from(jsonDecode(raw) as Map);
}

final RegExp _placeholder = RegExp(r'@\w+');
List<String> _placeholders(String v) =>
    _placeholder.allMatches(v).map((m) => m.group(0)!).toList()..sort();

/// Every 'key'.tr / "key".tr / 'key'.trParams in lib/, also across a line
/// break ('key'\n    .tr).
Map<String, String> staticTrKeysInLib() {
  final RegExp tr =
      RegExp(r'''(['"])([A-Za-z0-9_]+)\1\s*\.tr(?:Params)?\b''');
  final Map<String, String> out = {};
  for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      for (final RegExpMatch m in tr.allMatches(f.readAsStringSync())) {
        out.putIfAbsent(m.group(2)!, () => f.path);
      }
    }
  }
  return out;
}

/// Keys the code joins with numbers, names or other keys. The code adds the
/// spaces, so the values must not carry their own.
const List<String> _composedKeys = [
  'mins_ago', 'hours_ago', 'days_ago', 'm', 'h', 'km_away', 'days', 'item',
  'items', 'show_items', 'join_as_a', 'delivery_man', 'i_agree_to_the',
  'terms_conditions', 'enter_the_verification_sent_to', 'allow_to',
  'to_run_notification_in_background', 'disable_background_notifications',
  'will_run_notification_service_in_the_background_always',
  'will_not_run_notification_service_in_the_background_always',
  'to_access_location', 'will_track_your_location_in_background',
  'sorry_cannot_view_this_conversation', 'may_have_been_removed_from',
  'deleted', 'customer', 'vendor', 'user', 'admin', 'passport',
  'driving_license', 'nid', 'number', 'charge_payer', 'sender', 'receiver',
  'order', 'street_number', 'house', 'floor', 'addons', 'variations',
  'could_not_launch', 'can_not_launch', 'resend', 'resend_it',
  'wallet_withdraw_to', 'id_label', 'today', 'yesterday',
];

/// Glossary decisions for D-15 (Arabic values shown to the rider).
const Map<String, String> _arGlossary = {
  'online': 'متاح',
  'offline': 'غير متاح',
  'customer': 'الزبون',
  'user': 'الزبون',
  'processing': 'قيد التحضير',
  'handover': 'جاهز للتسليم',
  'picked_up': 'تم الاستلام',
  'returned': 'مُرتجع',
  'refunded': 'تم الاسترداد',
  'canceled': 'تم الإلغاء',
  'item': 'منتج',
  'items': 'منتجات',
  'otp_verification': 'التحقق من الرمز',
};

void main() {
  test('T1 both files are valid JSON without BOM and without duplicate keys',
      () {
    for (final String lang in _langs) {
      final List<int> bytes =
          File('assets/language/$lang.json').readAsBytesSync();
      expect(bytes.take(3).toList(), isNot([0xEF, 0xBB, 0xBF]), reason: lang);
      final String raw = utf8.decode(bytes);
      final Map<String, String> map = _load(lang);
      final int keyLines =
          RegExp(r'^\s*"[^"]+"\s*:', multiLine: true).allMatches(raw).length;
      expect(keyLines, map.length, reason: '$lang has a duplicate key');
    }
  });

  test('T2 ar and en have the same key set', () {
    final Set<String> en = _load('en').keys.toSet();
    final Set<String> ar = _load('ar').keys.toSet();
    expect(en.difference(ar), isEmpty, reason: 'only in en');
    expect(ar.difference(en), isEmpty, reason: 'only in ar');
  });

  test('T3 the same placeholders per key in ar and en', () {
    final Map<String, String> en = _load('en');
    final Map<String, String> ar = _load('ar');
    for (final String k in en.keys) {
      expect(_placeholders(ar[k]!), _placeholders(en[k]!), reason: k);
    }
    expect(_placeholders(en['upload_identity_picture']!), ['@identity']);
  });

  test('T4 no empty values', () {
    for (final String lang in _langs) {
      _load(lang).forEach((k, v) {
        expect(v.trim(), isNotEmpty, reason: '$lang $k');
      });
    }
  });

  test('T5 every statically referenced .tr key in lib exists in both files',
      () {
    final Map<String, String> refs = staticTrKeysInLib();
    expect(refs.length, greaterThan(400));
    for (final String lang in _langs) {
      final Map<String, String> map = _load(lang);
      final Map<String, String> missing = {
        for (final MapEntry<String, String> r in refs.entries)
          if (!map.containsKey(r.key)) r.key: r.value,
      };
      expect(missing, isEmpty, reason: '$lang missing ${missing.length} keys');
    }
  });

  test('T6 composed keys carry no own spacing and keep the word order', () {
    for (final String lang in _langs) {
      final Map<String, String> map = _load(lang);
      for (final String k in _composedKeys) {
        expect(map.containsKey(k), isTrue, reason: '$lang $k');
        expect(map[k], map[k]!.trim(), reason: '$lang $k has edge spaces');
      }
    }
    // The number comes first ('5 ' + key), so the Arabic value cannot hold
    // a word that has to stand before the number.
    final Map<String, String> ar = _load('ar');
    for (final String k in ['mins_ago', 'hours_ago', 'days_ago', 'km_away']) {
      expect(ar[k]!.contains('قبل') || ar[k]!.contains('منذ') ||
          ar[k]!.contains('بعيد'), isFalse, reason: k);
    }
    expect(ar['reminder']!.startsWith(':'), isFalse);
  });

  test('T7 Arabic glossary decisions hold', () {
    final Map<String, String> ar = _load('ar');
    _arGlossary.forEach((k, v) => expect(ar[k], v, reason: k));
    expect(ar['delivery_man'], contains('مندوب'));
    expect(ar['delivery_man_tips'], contains('إكرامية'));
    expect(ar['delivery_tips'], contains('إكراميات'));
    expect(ar['forgot_password'], contains('كلمة المرور'));
  });

  test('T8 the shown location disclosure says closed / not in use and why',
      () {
    final Map<String, String> en = _load('en');
    final Map<String, String> ar = _load('ar');
    for (final String k in [
      'location_required_to_go_online',
      'for_better_experience_allow_always',
    ]) {
      expect(en[k], contains('closed or not in use'), reason: k);
      expect(ar[k], contains('مغلقًا أو غير مستخدم'), reason: k);
    }
    expect(en['location_required_to_go_online'], contains('orders'));
    expect(en['will_track_your_location_in_background'],
        contains('background'));
  });
}
