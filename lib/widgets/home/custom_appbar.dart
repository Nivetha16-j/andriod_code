import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/currency_provider.dart';

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
  String _translatedTicker = '';

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    final ticker =
        homeProvider.homeData?['data']?['spot_prices']?['ticker'] ??
        'Loading...';

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
            SizedBox(
              height: 20,
              child: Marquee(
                text: _translatedTicker.isEmpty ? ticker : _translatedTicker,

                style: const TextStyle(
                  color: AppColors.white,
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

            Padding(
              padding: const EdgeInsets.all(12),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.scaffoldKey?.currentState?.openDrawer();
                    },

                    child: const Icon(
                      Icons.menu,
                      size: 24,
                      color: AppColors.white,
                    ),
                  ),

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

                    child: SvgPicture.asset(
                      'assets/logo/logo.svg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),

                  _buildCurrencySelector(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    const List<String> currencies = [
      'USD',
      'SGD',
      'CAD',
      'INR',
      'EUR',
      'AED',
      'CNY',
    ];

    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        final String selectedCurrency =
            currencies.contains(currencyProvider.selectedCurrency)
            ? currencyProvider.selectedCurrency
            : currencies.first;

        return Container(
          height: 38,

          padding: const EdgeInsets.symmetric(horizontal: 6),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency,

              isDense: true,

              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: 20,
              ),

              dropdownColor: Colors.white,

              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),

              onChanged: (String? value) {
                if (value == null) return;

                debugPrint('Currency changed to: $value');

                currencyProvider.changeCurrency(value);
              },

              items: currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency,

                  child: Text(
                    currency,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
