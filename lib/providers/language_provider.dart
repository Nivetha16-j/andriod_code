import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  TranslateLanguage _selectedLanguage = TranslateLanguage.english;

  bool _isLoading = false;

  TranslateLanguage get selectedLanguage => _selectedLanguage;

  bool get isLoading => _isLoading;

  String get selectedLanguageName {
    switch (_selectedLanguage) {
      case TranslateLanguage.arabic:
        return 'Arabic';

      case TranslateLanguage.english:
        return 'English';

      case TranslateLanguage.german:
        return 'German';

      case TranslateLanguage.hindi:
        return 'Hindi';

      case TranslateLanguage.italian:
        return 'Italian';

      case TranslateLanguage.spanish:
        return 'Spanish';

      case TranslateLanguage.tamil:
        return 'Tamil';

      default:
        return 'English';
    }
  }

  /// ------------------------------------------------------------
  /// INITIALIZE LANGUAGE
  /// ------------------------------------------------------------

  Future<void> initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedLanguage = prefs.getString(_languageKey);

      log('Saved language: $savedLanguage');

      if (savedLanguage == null || savedLanguage.isEmpty) {
        _selectedLanguage = TranslateLanguage.english;
        return;
      }

      final language = _languageFromCode(savedLanguage);

      if (language != null) {
        _selectedLanguage = language;

        log('Restored language: ${selectedLanguageName}');
      }
    } catch (e, stackTrace) {
      log('Failed to restore language: $e', stackTrace: stackTrace);

      _selectedLanguage = TranslateLanguage.english;
    }

    notifyListeners();
  }

  /// ------------------------------------------------------------
  /// CHANGE LANGUAGE
  /// ------------------------------------------------------------

  Future<void> changeLanguage(TranslateLanguage language) async {
    if (_selectedLanguage == language) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _selectedLanguage = language;

      final prefs = await SharedPreferences.getInstance();

      final languageCode = _languageToCode(language);

      if (languageCode != null) {
        await prefs.setString(_languageKey, languageCode);

        log('Language saved: $languageCode');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      log('Failed to save language: $e', stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ------------------------------------------------------------
  /// TRANSLATE TEXT
  /// ------------------------------------------------------------

  Future<String> translate(String text) async {
    if (text.trim().isEmpty) {
      return text;
    }

    if (_selectedLanguage == TranslateLanguage.english) {
      return text;
    }

    try {
      final onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: _selectedLanguage,
      );

      final translated = await onDeviceTranslator.translateText(text);

      await onDeviceTranslator.close();

      return translated;
    } catch (e, stackTrace) {
      log('Translation failed: $e', stackTrace: stackTrace);

      return text;
    }
  }

  /// ------------------------------------------------------------
  /// LANGUAGE -> CODE
  /// ------------------------------------------------------------

  String? _languageToCode(TranslateLanguage language) {
    switch (language) {
      case TranslateLanguage.arabic:
        return 'ar';

      case TranslateLanguage.english:
        return 'en';

      case TranslateLanguage.german:
        return 'de';

      case TranslateLanguage.hindi:
        return 'hi';

      case TranslateLanguage.italian:
        return 'it';

      case TranslateLanguage.spanish:
        return 'es';

      case TranslateLanguage.tamil:
        return 'ta';

      default:
        return 'en';
    }
  }

  /// ------------------------------------------------------------
  /// CODE -> LANGUAGE
  /// ------------------------------------------------------------

  TranslateLanguage? _languageFromCode(String code) {
    switch (code) {
      case 'ar':
        return TranslateLanguage.arabic;

      case 'en':
        return TranslateLanguage.english;

      case 'de':
        return TranslateLanguage.german;

      case 'hi':
        return TranslateLanguage.hindi;

      case 'it':
        return TranslateLanguage.italian;

      case 'es':
        return TranslateLanguage.spanish;

      case 'ta':
        return TranslateLanguage.tamil;

      default:
        return TranslateLanguage.english;
    }
  }
}
