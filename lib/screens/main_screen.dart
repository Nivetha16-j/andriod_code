import 'dart:async';
import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:provider/provider.dart';

import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/screens/home/homescreen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/product/custom_productlist.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // int _currentIndex = 0;

  Timer? _livePriceTimer;

  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _productListScrollController = ScrollController();

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyProvider = context.read<CurrencyProvider>();

      context.read<HomeProvider>().fetchHomeData(
        currency: currencyProvider.selectedCurrency,
        unit: currencyProvider.selectedUnit,
      );

      context.read<ExclusiveProductProvider>().fetchProducts();

      _startLivePriceTimer();
    });
  }

  @override
  void dispose() {
    _livePriceTimer?.cancel();
    _homeScrollController.dispose();
    _productListScrollController.dispose();
    super.dispose();
  }

  void _startLivePriceTimer() {
    _livePriceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currencyProvider = context.read<CurrencyProvider>();

      context.read<HomeProvider>().fetchHomeData(
        currency: currencyProvider.selectedCurrency,
        unit: currencyProvider.selectedUnit,
      );
    });
  }

  void _switchToTab(int index) {
    if (index == 0 && _homeScrollController.hasClients) {
      _homeScrollController.jumpTo(0);
    } else if (index == 3 && _productListScrollController.hasClients) {
      _productListScrollController.jumpTo(0);
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    if (homeProvider.isLoading && homeProvider.homeData == null) {
      return Scaffold(
        appBar: CustomAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (homeProvider.errorMessage != null && homeProvider.homeData == null) {
      return Scaffold(
        appBar: CustomAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(homeProvider.errorMessage!),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  final currencyProvider = context.read<CurrencyProvider>();

                  context.read<HomeProvider>().fetchHomeData(
                    currency: currencyProvider.selectedCurrency,
                    unit: currencyProvider.selectedUnit,
                  );
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final exclusiveProducts =
        homeProvider.homeData?['data']?['exclusive_products'] as List<dynamic>?;

    final pages = [
      HomeScreen(
        onViewMoreTap: () => _switchToTab(3),
        onRefresh: () {
          final currencyProvider = context.read<CurrencyProvider>();

          return context.read<HomeProvider>().fetchHomeData(
            currency: currencyProvider.selectedCurrency,
            unit: currencyProvider.selectedUnit,
          );
        },
        scrollController: _homeScrollController,
      ),
      const Center(child: Text("Search / Category")),
      const Center(child: Text("Cart Screen")),
      ProductListScreen(
        isEmbedded: true,
        scrollController: _productListScrollController,
        onRefresh: () => context.read<HomeProvider>().fetchHomeData(),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }
}
