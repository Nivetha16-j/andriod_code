import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/providers/language_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomAppBar({Key? key, this.scaffoldKey}) : super(key: key);

  static const Color accentGold = Color(0xFFD49E00);
  static const Color textGold = Color(0xFFE5B537);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  // ------------------------------------------------------------
  // TICKER TRANSLATION STATE
  // ------------------------------------------------------------

  String _translatedTicker = '';
  String _lastTicker = '';
  TranslateLanguage? _lastLanguage;

  bool _isTranslatingTicker = false;

  // ------------------------------------------------------------
  // TRANSLATE TICKER
  // ------------------------------------------------------------

  Future<void> _translateTicker(String ticker) async {
    if (_isTranslatingTicker) {
      return;
    }

    final languageProvider = context.read<LanguageProvider>();

    final currentLanguage = languageProvider.selectedLanguage;

    // Already translated for this exact ticker + language
    if (_lastTicker == ticker && _lastLanguage == currentLanguage) {
      return;
    }

    // English does not need translation
    if (currentLanguage == TranslateLanguage.english) {
      if (!mounted) return;

      setState(() {
        _translatedTicker = ticker;
        _lastTicker = ticker;
        _lastLanguage = currentLanguage;
      });

      return;
    }

    _isTranslatingTicker = true;

    try {
      final result = await languageProvider.translate(ticker);

      if (!mounted) return;

      // Check again because language may have changed
      // while translation was running.
      if (context.read<LanguageProvider>().selectedLanguage !=
          currentLanguage) {
        return;
      }

      setState(() {
        _translatedTicker = result;
        _lastTicker = ticker;
        _lastLanguage = currentLanguage;
      });

      log('Ticker translated:');
      log('Original: $ticker');
      log('Translated: $result');
      log('Language: $currentLanguage');
    } catch (e) {
      log('Ticker translation failed: $e');

      if (!mounted) return;

      setState(() {
        _translatedTicker = ticker;
        _lastTicker = ticker;
        _lastLanguage = currentLanguage;
      });
    } finally {
      _isTranslatingTicker = false;
    }
  }

  // ------------------------------------------------------------
  // LANGUAGE DROPDOWN
  // ------------------------------------------------------------

  TranslateLanguage _getMlKitLanguage(String code) {
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

      // case 'ms':
      //   return TranslateLanguage.malay;

      case 'es':
        return TranslateLanguage.spanish;

      case 'ta':
        return TranslateLanguage.tamil;

      default:
        return TranslateLanguage.english;
    }
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final List<Map<String, String>> languages = [
      {'name': 'Arabic', 'code': 'ar'},
      {'name': 'English', 'code': 'en'},
      {'name': 'German', 'code': 'de'},
      {'name': 'Hindi', 'code': 'hi'},
      {'name': 'Italian', 'code': 'it'},
      // {
      //   'name': 'Malayalam',
      //   'code': 'ml',
      // },
      {'name': 'Spanish', 'code': 'es'},
      {'name': 'Tamil', 'code': 'ta'},
    ];

    return PopupMenuButton<String>(
      onSelected: (String code) async {
        final language = languages.firstWhere((lang) => lang['code'] == code);

        final mlKitLanguage = _getMlKitLanguage(code);

        log('Selected language: ${language['name']}');
        log('Language code: $code');

        await context.read<LanguageProvider>().changeLanguage(mlKitLanguage);

        if (!mounted) return;

        log(
          'Current language: '
          '${context.read<LanguageProvider>().selectedLanguageName}',
        );

        // The LanguageProvider change will rebuild this widget.
        // The ticker translation will then be triggered automatically.
      },
      offset: const Offset(0, 38),
      color: Colors.white,
      elevation: 5,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      itemBuilder: (context) {
        return languages.map((language) {
          return PopupMenuItem<String>(
            value: language['code']!,
            height: 28,
            child: Text(
              '›${language['name']}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        height: 28,
        width: 145,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Row(
          children: [
            const Text(
              'G',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4285F4),
              ),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Text(
                languageProvider.selectedLanguageName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (languageProvider.isLoading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              )
            else
              const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    final ticker =
        homeProvider.homeData?['data']?['spot_prices']?['ticker'] ??
        'Loading...';

    final languageProvider = context.watch<LanguageProvider>();

    // ----------------------------------------------------------
    // TRANSLATE TICKER WHEN:
    // 1. Ticker changes
    // 2. Language changes
    // ----------------------------------------------------------

    if (_lastTicker != ticker ||
        _lastLanguage != languageProvider.selectedLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _translateTicker(ticker);
      });
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --------------------------------------------------
            // TOP TICKER BAR
            // --------------------------------------------------
            SizedBox(
              height: 20,
              child: Marquee(
                text: _translatedTicker.isEmpty ? ticker : _translatedTicker,
                style: const TextStyle(
                  color: CustomAppBar.textGold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 40,
                velocity: 30,
                pauseAfterRound: Duration.zero,
              ),
            ),

            // --------------------------------------------------
            // MAIN NAVIGATION BAR
            // --------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  // ------------------------------------------------
                  // LOGO
                  // ------------------------------------------------
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainScreen(initialIndex: 0),
                        ),
                        (route) => false,
                      );
                    },
                    child: Image.asset('assets/logo/logo.png', height: 40),
                  ),

                  const Spacer(),

                  // ------------------------------------------------
                  // CART ICON
                  // ------------------------------------------------
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      final count = cartProvider.cartItems.length;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(initialIndex: 2),
                            ),
                            (route) => false,
                          );
                        },
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/shopping-cart.png',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              if (count > 0)
                                Positioned(
                                  right: -8,
                                  top: -4,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      count > 99 ? '99+' : count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  // ------------------------------------------------
                  // LANGUAGE DROPDOWN
                  // ------------------------------------------------
                  _buildLanguageDropdown(context, languageProvider),

                  const SizedBox(width: 12),

                  // ------------------------------------------------
                  // MENU ICON
                  // ------------------------------------------------
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                    onPressed: () async {
                      widget.scaffoldKey?.currentState?.openDrawer();

                      log('sssssssss ${widget.scaffoldKey}');

                      log(
                        'ssssscccc '
                        '${widget.scaffoldKey?.currentState}',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
