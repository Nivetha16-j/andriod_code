import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:junubullion/services/translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  final TranslationService _translationService = TranslationService();

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
      // case TranslateLanguage.malayalam:
      //   return 'Malayalam';
      case TranslateLanguage.spanish:
        return 'Spanish';
      case TranslateLanguage.tamil:
        return 'Tamil';
      default:
        return 'English';
    }
  }

  Future<void> changeLanguage(TranslateLanguage language) async {
    if (_selectedLanguage == language) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (language != TranslateLanguage.english) {
        await _translationService.initialize(
          sourceLanguage: TranslateLanguage.english,
          targetLanguage: language,
        );
      }

      _selectedLanguage = language;

      debugPrint('Language changed to: ${selectedLanguageName}');
    } catch (e) {
      debugPrint('Language change failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> translate(String text) async {
    if (_selectedLanguage == TranslateLanguage.english) {
      return text;
    }

    return await _translationService.translate(text);
  }

  @override
  void dispose() {
    _translationService.dispose();
    super.dispose();
  }
}
