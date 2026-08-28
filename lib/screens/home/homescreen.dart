import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/screens/plans/gsp/gsp_dashboard.dart';
import 'package:junubullion/screens/plans/gsp/gsp_details.dart';
import 'package:junubullion/screens/plans/jsc/jsc_dashboard.dart';
import 'package:junubullion/screens/plans/jsc/jsc_details.dart';
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
      if (!mounted) return;

      final currencyProvider = context.read<CurrencyProvider>();
      final homeProvider = context.read<HomeProvider>();
      final cartProvider = context.read<CartProvider>();
      final exclusiveProductProvider = context.read<ExclusiveProductProvider>();

      final currency = currencyProvider.selectedCurrency;
      final unit = currencyProvider.selectedUnit;

      await homeProvider.fetchHomeData(currency: currency, unit: unit);

      if (!mounted) return;

      cartProvider.updateSelection(
        currency: currency,
        unit: unit.toLowerCase() == "ounce"
            ? "toz"
            : unit.toLowerCase() == "kilogram"
            ? "kg"
            : "gram",
      );

      await cartProvider.fetchCart();

      if (!mounted) return;

      await exclusiveProductProvider.fetchProducts(
        currency: currency,
        unit: unit,
      );
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
                if (!mounted) return;

                final currencyProvider = context.read<CurrencyProvider>();
                final homeProvider = context.read<HomeProvider>();
                final exclusiveProductProvider = context
                    .read<ExclusiveProductProvider>();
                final cartProvider = context.read<CartProvider>();

                currencyProvider.update(currency, unit);

                await Future.wait([
                  homeProvider.fetchHomeData(currency: currency, unit: unit),
                  exclusiveProductProvider.fetchProducts(
                    endpoint: "exclusive-products",
                    currency: currency,
                    unit: unit,
                  ),
                  cartProvider.fetchCart(),
                ]);

                if (!mounted) return;
              },
            ),
            const SizedBox(height: 5),

            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => JscDashboardScreen()));
              },
              child: InvestBanner(
                imagePath: "assets/jsc.png",
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => JscScreen()));
                },
              ),
            ),
            const SizedBox(height: 5),

            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => GspDashboardScreen()));
              },
              child: InvestBanner(
                imagePath: "assets/gsp.png",
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => GspScreen()));
                },
              ),
            ),
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
