import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:junubullion/providers/language_provider.dart';

/// Runs heavy startup work after the first Flutter frame so the native
/// launch screen is not held while Firebase / Stripe / etc. initialize.
class AppBootstrap {
  AppBootstrap._();

  static Future<void>? _future;

  /// Completes when Firebase, env, Stripe, and language are ready.
  static Future<void> get ready => _future ?? Future.value();

  static void start(LanguageProvider languageProvider) {
    _future ??= _initialize(languageProvider);
  }

  static Future<void> _initialize(LanguageProvider languageProvider) async {
    try {
      await Firebase.initializeApp();
    } catch (e, stackTrace) {
      debugPrint('Firebase initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await dotenv.load(fileName: '.env');
      Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
      await Stripe.instance.applySettings();
    } catch (e, stackTrace) {
      debugPrint('Env / Stripe initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    await languageProvider.initializeLanguage();
  }
}
