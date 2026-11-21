import 'package:country_code_picker/country_code_picker.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter/foundation.dart';

/// The rider's country for the phone fields (D-12, C9).
class CountryHelper {
  CountryHelper._();

  /// Lookups used by [countryFromConfig]. Replaced in tests only, to force
  /// a miss.
  @visibleForTesting
  static CountryCode Function(String iso) byIso = CountryCode.fromCountryCode;
  @visibleForTesting
  static CountryCode Function(String dial) byDial = CountryCode.fromDialCode;

  /// Built directly, the same entry the country_code_picker list holds for
  /// [AppConstants.fallbackDialCode], so it needs no lookup at all.
  static final CountryCode lastResort = CountryCode(
    name: 'فلسطين',
    code: 'PS',
    dialCode: AppConstants.fallbackDialCode,
    flagUri: 'flags/ps.png',
  );

  /// The country from the config's ISO code. A missing, empty or unknown
  /// code falls back to [AppConstants.fallbackDialCode], and if even that
  /// lookup fails, to [lastResort]. Never throws, never null.
  static CountryCode countryFromConfig(String? iso) {
    if (iso != null && iso.trim().isNotEmpty) {
      try {
        return byIso(iso.trim());
      } catch (_) {}
    }
    try {
      return byDial(AppConstants.fallbackDialCode);
    } catch (_) {
      return lastResort;
    }
  }
}
