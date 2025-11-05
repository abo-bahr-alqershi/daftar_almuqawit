// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// محليّات التطبيق
class AppLocalizations {
  final Locale locale;
  Map<String, dynamic>? _localizedValues;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  Future<bool> load() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json'
      );
      _localizedValues = json.decode(jsonString);
      return true;
    } catch (e) {
      // في حالة فشل التحميل، استخدم قيم افتراضية
      _localizedValues = {};
      return false;
    }
  }
  
  String translate(String key) {
    return _localizedValues?[key] ?? key;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
