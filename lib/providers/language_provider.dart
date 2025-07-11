import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';

  Locale _locale = const Locale('pt', 'BR');

  Locale get locale => _locale;

  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Português';
    }
  }

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        _locale = Locale(languageCode);
      } else {
        final systemLocale = PlatformDispatcher.instance.locale;
        if (['pt', 'en', 'es'].contains(systemLocale.languageCode)) {
          _locale = Locale(systemLocale.languageCode);
        } else {
          _locale = const Locale('pt');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar idioma: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        notifyListeners();
      } catch (e) {
        debugPrint('Erro ao salvar idioma: $e');
      }
    }
  }

  List<Map<String, String>> get supportedLanguages => [
    {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];
}
