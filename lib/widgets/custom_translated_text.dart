import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/language_provider.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.softWrap,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String _translatedText = '';
  TranslateLanguage? _lastLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageProvider = context.watch<LanguageProvider>();

    final currentLanguage = languageProvider.selectedLanguage;

    if (_lastLanguage != currentLanguage) {
      _lastLanguage = currentLanguage;

      _translate(languageProvider, currentLanguage);
    }
  }

  Future<void> _translate(
    LanguageProvider languageProvider,
    TranslateLanguage language,
  ) async {
    try {
      if (language == TranslateLanguage.english) {
        if (!mounted) return;

        setState(() {
          _translatedText = widget.text;
        });

        return;
      }

      final result = await languageProvider.translate(widget.text);

      if (!mounted) return;

      if (context.read<LanguageProvider>().selectedLanguage != language) {
        return;
      }

      setState(() {
        _translatedText = result;
      });

      debugPrint('Translated: "${widget.text}" → "$result"');
    } catch (e) {
      debugPrint('Translation failed for "${widget.text}": $e');

      if (!mounted) return;

      setState(() {
        _translatedText = widget.text;
      });
    }
  }

  @override
  void didUpdateWidget(covariant TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      final languageProvider = context.read<LanguageProvider>();

      _translate(languageProvider, languageProvider.selectedLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    return Text(
      _translatedText.isEmpty ? widget.text : _translatedText,
      textAlign: widget.textAlign,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
    );
  }
}
