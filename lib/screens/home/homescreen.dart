import 'package:flutter/material.dart';
import 'package:junubullion/widgets/home/custom_banner.dart';
import 'package:junubullion/widgets/home/custom_brands.dart';
import 'package:junubullion/widgets/home/custom_exclusivecollections.dart';
import 'package:junubullion/widgets/home/custom_featuregrid.dart';
import 'package:junubullion/widgets/home/custom_livespot.dart';
import 'package:junubullion/widgets/home/custom_statscard.dart';
import 'package:junubullion/widgets/home/custom_testimonials.dart';
import 'package:junubullion/widgets/home/custom_trendingproducts.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? homeData;
  final VoidCallback onViewMoreTap;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;

  const HomeScreen({
    super.key,
    required this.homeData,
    required this.onViewMoreTap,
    required this.onRefresh,
    required this.scrollController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCurrency = "USD";
  String selectedUnit = "Gram";

  @override
  Widget build(BuildContext context) {
    final bannerData = widget.homeData?['data']?['banner'];

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
            const SizedBox(height: 30),

            // Pass the API spot_prices object here
            LiveSpotPriceCard(
              spotPricesData: widget.homeData?['data']?['spot_prices'],

              selectedCurrency: selectedCurrency,
              selectedUnit: selectedUnit,

              onSelectionChanged: (currency, unit) {
                setState(() {
                  selectedCurrency = currency;
                  selectedUnit = unit;
                });
              },
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Image.asset("assets/jsc.png", fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Image.asset("assets/gsp.png", fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),

            FeaturesGridSection(),
            const SizedBox(height: 30),

            TrendingProductsSection(
              products:
                  widget.homeData?['data']?['trending_products']
                      as List<dynamic>?,
              onSeeAllTap:
                  widget.onViewMoreTap, // Navigates to 4th tab (Product List)
              currency: selectedCurrency,
              unit: selectedUnit,
            ),
            const SizedBox(height: 30),

            StatsCardSection(),
            const SizedBox(height: 30),

            ExclusiveCollectionsSection(
              products:
                  widget.homeData?['data']?['exclusive_products']
                      as List<dynamic>?,
              onViewMoreTap:
                  widget.onViewMoreTap, // Navigates to 4th tab (Product List)
              currency: selectedCurrency,
              unit: selectedUnit,
            ),
            const SizedBox(height: 30),

            BrandsWeCarrySection(),
            const SizedBox(height: 30),

            TestimonialsSection(
              testimonialsData: widget.homeData?['data']?['testimonials'] ?? [],
              onViewMorePressed: () {},
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
