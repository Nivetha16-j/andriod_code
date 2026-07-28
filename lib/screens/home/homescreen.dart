import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/widgets/home/custom_banner.dart';
import 'package:junubullion/widgets/home/custom_brands.dart';
import 'package:junubullion/widgets/home/custom_exclusivecollections.dart';
import 'package:junubullion/widgets/home/custom_featuregrid.dart';
import 'package:junubullion/widgets/home/custom_investnowbutton.dart';
import 'package:junubullion/widgets/home/custom_livespot.dart';
import 'package:junubullion/widgets/home/custom_statscard.dart';
import 'package:junubullion/widgets/home/custom_testimonials.dart';
import 'package:junubullion/widgets/home/custom_trendingproducts.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/currency_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onViewMoreTap;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;

  const HomeScreen({
    super.key,
    required this.onViewMoreTap,
    required this.onRefresh,
    required this.scrollController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currencyProvider = context.read<CurrencyProvider>();

      await context.read<HomeProvider>().fetchHomeData(
        currency: currencyProvider.selectedCurrency,
        unit: currencyProvider.selectedUnit,
      );
      // final currency = context.read<CurrencyProvider>();
      context.read<CartProvider>().updateSelection(
        currency: currencyProvider.selectedCurrency,
        unit: currencyProvider.selectedUnit.toLowerCase() == "ounce"
            ? "toz"
            : currencyProvider.selectedUnit.toLowerCase() == "kilogram"
            ? "kg"
            : "gram",
      );

      await context.read<CartProvider>().fetchCart();

      context.read<ExclusiveProductProvider>().fetchProducts(
        currency: currencyProvider.selectedCurrency,
        unit: currencyProvider.selectedUnit,
      );
    });

    Future.microtask(() {
      // context.read<CartProvider>().fetchCart();.
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final exclusiveProductProvider = context.watch<ExclusiveProductProvider>();

    final currencyProvider = context.watch<CurrencyProvider>();
    final bannerData = homeProvider.homeData?['data']?['banner'];

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        controller: widget.scrollController, // Attached controller
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BannerSlider(bannerData: bannerData),
            const SizedBox(height: 5),

            // Pass the API spot_prices object here
            LiveSpotPriceCard(
              spotPricesData: homeProvider.homeData?['data']?['spot_prices'],
              selectedCurrency: currencyProvider.selectedCurrency,
              selectedUnit: currencyProvider.selectedUnit,
              onSelectionChanged: (currency, unit) async {
                // // Update selected currency & unit
                // context.read<CurrencyProvider>().update(currency, unit);

                // // Fetch fresh data from backend
                // await context.read<HomeProvider>().fetchHomeData(
                //   currency: currency,
                //   unit: unit,
                // );

                // context.read<CartProvider>().updateSelection(
                //   currency: currency,
                //   unit: unit.toLowerCase() == "ounce"
                //       ? "toz"
                //       : unit.toLowerCase() == "kilogram"
                //       ? "kg"
                //       : "gram",
                // );

                // await context.read<CartProvider>().fetchCart();

                // onSelectionChanged: (currency, unit) async {
                context.read<CurrencyProvider>().update(currency, unit);

                await Future.wait([
                  context.read<HomeProvider>().fetchHomeData(
                    currency: currency,
                    unit: unit,
                  ),

                  context.read<ExclusiveProductProvider>().fetchProducts(
                    endpoint: "exclusive-products",
                    currency: currency,
                    unit: unit,
                  ),

                  context.read<CartProvider>().fetchCart(
                    // currency: currency,
                    // unit: unit,
                  ),
                ]);
                // }
              },
            ),
            const SizedBox(height: 5),

            InvestBanner(imagePath: "assets/jsc.png", onTap: () {}),
            const SizedBox(height: 5),

            InvestBanner(imagePath: "assets/gsp.png", onTap: () {}),
            const SizedBox(height: 5),

            FeaturesGridSection(),
            const SizedBox(height: 5),

            TrendingProductsSection(
              products:
                  homeProvider.homeData?['data']?['trending_products']
                      as List<dynamic>?,
              onSeeAllTap:
                  widget.onViewMoreTap, // Navigates to 4th tab (Product List)
              currency: currencyProvider.selectedCurrency,
              unit: currencyProvider.selectedUnit,
            ),
            const SizedBox(height: 5),

            StatsCardSection(),
            const SizedBox(height: 5),

            ExclusiveCollectionsSection(
              products: exclusiveProductProvider.products,
              onViewMoreTap: widget.onViewMoreTap,
              currency: currencyProvider.selectedCurrency,
              unit: currencyProvider.selectedUnit,
            ),
            const SizedBox(height: 5),

            BrandsWeCarrySection(),
            const SizedBox(height: 5),

            TestimonialsSection(
              testimonialsData:
                  homeProvider.homeData?['data']?['testimonials'] ?? [],
              onViewMorePressed: () {},
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
