import 'dart:developer';

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();

  factory TranslationService() {
    return _instance;
  }

  TranslationService._internal();

  OnDeviceTranslator? _translator;

  TranslateLanguage? _sourceLanguage;
  TranslateLanguage? _targetLanguage;

  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  /// Check whether a language model is already downloaded.
  Future<bool> isModelDownloaded(TranslateLanguage language) async {
    return await _modelManager.isModelDownloaded(language.bcpCode);
  }

  /// Download a language model if it is not already available.
  Future<void> downloadModel(TranslateLanguage language) async {
    final downloaded = await isModelDownloaded(language);

    log('${language.bcpCode} model downloaded: $downloaded');

    if (!downloaded) {
      log('Downloading ${language.bcpCode} model...');

      await _modelManager.downloadModel(language.bcpCode);

      log('${language.bcpCode} model download completed');
    }
  }

  /// Initialize the translator.
  Future<void> initialize({
    required TranslateLanguage sourceLanguage,
    required TranslateLanguage targetLanguage,
  }) async {
    // If the same translator is already initialized,
    // don't create another one.
    if (_translator != null &&
        _sourceLanguage == sourceLanguage &&
        _targetLanguage == targetLanguage) {
      return;
    }

    // Close previous translator.
    await _translator?.close();

    // Make sure both models are available.
    await downloadModel(sourceLanguage);
    await downloadModel(targetLanguage);

    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    _sourceLanguage = sourceLanguage;
    _targetLanguage = targetLanguage;
  }

  /// Translate text.
  Future<String> translate(String text) async {
    if (text.trim().isEmpty) {
      return text;
    }

    if (_translator == null) {
      throw Exception('TranslationService has not been initialized.');
    }

    return await _translator!.translateText(text);
  }

  /// Close translator.
  Future<void> dispose() async {
    await _translator?.close();

    _translator = null;
    _sourceLanguage = null;
    _targetLanguage = null;
  }
}
