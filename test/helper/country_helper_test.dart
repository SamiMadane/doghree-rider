import 'package:country_code_picker/country_code_picker.dart';
import 'package:doghree_rider/helper/country_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

/// D-12, C9: the phone fields' country never throws and is never null.
void main() {
  tearDown(() {
    CountryHelper.byIso = CountryCode.fromCountryCode;
    CountryHelper.byDial = CountryCode.fromDialCode;
  });

  test('Y1 no country in the config: the +970 country', () {
    final CountryCode c = CountryHelper.countryFromConfig(null);
    expect(c.dialCode, AppConstants.fallbackDialCode);
    expect(c.code, 'PS');
  });

  test('Y2 an empty country: the +970 country', () {
    expect(CountryHelper.countryFromConfig('  ').dialCode, '+970');
  });

  test('Y3 an unknown ISO code: the +970 country, no throw', () {
    expect(CountryHelper.countryFromConfig('ZZ').dialCode, '+970');
  });

  test('Y4 guard: a known ISO code is used as is', () {
    final CountryCode c = CountryHelper.countryFromConfig('SA');
    expect(c.code, 'SA');
    expect(c.dialCode, '+966');
  });

  test('Y5 both lookups fail: the hard-coded Palestine entry', () {
    CountryHelper.byIso = (_) => throw StateError('iso');
    CountryHelper.byDial = (_) => throw StateError('dial');

    final CountryCode c = CountryHelper.countryFromConfig('SA');

    expect(c.code, 'PS');
    expect(c.dialCode, '+970');
    expect(c.flagUri, 'flags/ps.png');
    expect(identical(c, CountryHelper.lastResort), isTrue);
  });
}
