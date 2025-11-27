import 'package:wefrh_rider/features/language/domain/models/language_model.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/language/domain/services/language_service_interface.dart';

class LocalizationController extends GetxController implements GetxService {
  final LanguageServiceInterface languageServiceInterface;
  LocalizationController({required this.languageServiceInterface}) {
    loadCurrentLanguage();
  }

  Locale _locale = Locale(AppConstants.languages[0].languageCode!,
      AppConstants.languages[0].countryCode);
  Locale get locale => _locale;

  bool _isLtr = true;
  bool get isLtr => _isLtr;

  int _selectedLanguageIndex = -1;
  int get selectedLanguageIndex => _selectedLanguageIndex;

  List<LanguageModel> _languages = [];
  List<LanguageModel> get languages => _languages;

  void setLanguage(Locale locale, {bool fromBottomSheet = false}) {
    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = languageServiceInterface.setLTR(_locale);
    languageServiceInterface.updateHeader(_locale);
    if (!fromBottomSheet) {
      saveLanguage(_locale);
    }
    update();
  }

Future<void> loadCurrentLanguage() async {
  Locale? savedLocale = languageServiceInterface.getLocaleFromSharedPref();

  if (savedLocale == null) {
    _selectedLanguageIndex = -1; // ما في لغة محفوظة → يظهر LanguageInitScreen
    _locale = Locale(AppConstants.languages[0].languageCode!,
        AppConstants.languages[0].countryCode);
  } else {
    _locale = savedLocale;
    _selectedLanguageIndex = languageServiceInterface.setSelectedLanguageIndex(
        AppConstants.languages, _locale);
  }

  _isLtr = _locale.languageCode != 'ar';
  _languages = [];
  _languages.addAll(AppConstants.languages);
  update();
}

  void saveCacheLanguage(Locale? locale) {
    languageServiceInterface.saveCacheLanguage(
        locale!);
  }

  void saveLanguage(Locale locale) async {
    languageServiceInterface.saveLanguage(locale);
  }

  void setSelectLanguageIndex(int index) {
    _selectedLanguageIndex = index;
    update();
  }

  Locale getCacheLocaleFromSharedPref() {
    return languageServiceInterface.getCacheLocaleFromSharedPref();
  }

  void searchSelectedLanguage() {
    for (var language in AppConstants.languages) {
      if (language.languageCode!
          .toLowerCase()
          .contains(_locale.languageCode.toLowerCase())) {
        _selectedLanguageIndex = AppConstants.languages.indexOf(language);
      }
    }
  }
}
