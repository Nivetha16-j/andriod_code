import 'dart:async';
import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/screens/balance/balancescreen.dart';
import 'package:junubullion/screens/cart/cartscreen.dart';
import 'package:junubullion/screens/home/homescreen.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:junubullion/screens/search/search.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:junubullion/widgets/product/custom_productlist.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/account_provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  final int productCategoryIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.productCategoryIndex = 0,
  });

  static const int cartTabIndex = 2;

  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MainScreenState>()?._switchToTab(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _livePriceTimer;

  final ScrollController _homeScrollController = ScrollController();

  final ScrollController _productListScrollController = ScrollController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late int _currentIndex;

  late HomeProvider _homeProvider;

  late CurrencyProvider _currencyProvider;

  late ExclusiveProductProvider _exclusiveProductProvider;

  late CartProvider _cartProvider;

  late PhysicalConversionProvider _physicalProvider;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _homeProvider = context.read<HomeProvider>();

      _currencyProvider = context.read<CurrencyProvider>();

      _exclusiveProductProvider = context.read<ExclusiveProductProvider>();

      _cartProvider = context.read<CartProvider>();

      _physicalProvider = context.read<PhysicalConversionProvider>();

      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      final currency = _currencyProvider.selectedCurrency;

      final unit = _currencyProvider.selectedUnit;

      await _homeProvider.fetchHomeData(currency: currency, unit: unit);

      if (!mounted) return;

      const productEndpoints = [
        "exclusive-products",
        "gold-coins",
        "gold-bars",
        "silver-coins",
        "silver-bars",
      ];

      final selectedEndpoint =
          productEndpoints[widget.productCategoryIndex.clamp(0, 4)];

      await _exclusiveProductProvider.fetchProducts(
        endpoint: selectedEndpoint,
        currency: currency,
        unit: unit,
      );

      if (!mounted) return;

      _cartProvider.updateSelection(currency: currency, unit: unit);

      await _cartProvider.fetchCart();

      if (!mounted) return;

      _startLivePriceTimer();
    } catch (e, stackTrace) {
      debugPrint('❌ INITIAL DATA ERROR: $e');

      debugPrint('$stackTrace');
    }
  }

  void _startLivePriceTimer() {
    _livePriceTimer?.cancel();

    if (!mounted) return;

    _livePriceTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshLiveData();
    });

    debugPrint('⏱️ LIVE PRICE TIMER STARTED');
  }

  Future<void> _refreshLiveData() async {
    if (!mounted) return;

    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      final currency = _currencyProvider.selectedCurrency;

      final unit = _currencyProvider.selectedUnit;

      await _homeProvider.fetchHomeData(currency: currency, unit: unit);

      if (!mounted) return;

      await _exclusiveProductProvider.fetchProducts(
        endpoint: _exclusiveProductProvider.currentEndpoint,
        currency: currency,
        unit: unit,
        showLoader: false,
      );

      if (!mounted) return;

      if (_physicalProvider.isActive) {
        debugPrint(
          '⏭️ LIVE TIMER: Physical conversion active. '
          'Skipping normal cart API.',
        );

        return;
      }

      _cartProvider.updateSelection(currency: currency, unit: unit);

      await _cartProvider.fetchCart();
    } catch (e, stackTrace) {
      debugPrint('❌ LIVE PRICE TIMER ERROR: $e');

      debugPrint('❌ LIVE PRICE TIMER STACK: $stackTrace');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _switchToTab(int index) async {
    if (!mounted) return;

    if (index == 0 && _homeScrollController.hasClients) {
      _homeScrollController.jumpTo(0);
    }

    if (index == 3 && _productListScrollController.hasClients) {
      _productListScrollController.jumpTo(0);
    }

    setState(() {
      _currentIndex = index;
    });

    if (index == 4) {
      debugPrint('👤 PROFILE TAB OPENED - REFRESHING DATA');

      final ordersProvider = context.read<OrdersProvider>();
      final accountProvider = context.read<AccountProvider>();

      try {
        await Future.wait([
          ordersProvider.fetchOrders(),
          accountProvider.fetchAccountDetails(),
        ]);

        if (!mounted) return;

        debugPrint('✅ PROFILE DATA REFRESHED');
      } catch (e, stackTrace) {
        debugPrint('❌ PROFILE REFRESH ERROR: $e');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🔥 MAIN SCREEN DISPOSE - CANCELLING TIMER');

    _livePriceTimer?.cancel();

    _livePriceTimer = null;

    _homeScrollController.dispose();

    _productListScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    if (homeProvider.isLoading && homeProvider.homeData == null) {
      return Scaffold(
        key: scaffoldKey,
        drawer: const CustomDrawer(),
        backgroundColor: const Color(0xFFFAFAFA),
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(scaffoldKey: scaffoldKey),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (homeProvider.errorMessage != null && homeProvider.homeData == null) {
      return Scaffold(
        key: scaffoldKey,
        drawer: const CustomDrawer(),
        backgroundColor: const Color(0xFFFAFAFA),
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(scaffoldKey: scaffoldKey),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TranslatedText(homeProvider.errorMessage!),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: () {
                  final currency = _currencyProvider.selectedCurrency;

                  final unit = _currencyProvider.selectedUnit;

                  _homeProvider.fetchHomeData(currency: currency, unit: unit);
                },
                child: const TranslatedText('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final pages = [
      HomeScreen(
        onViewMoreTap: () {
          _switchToTab(3);
        },

        onRefresh: () {
          final currency = _currencyProvider.selectedCurrency;

          final unit = _currencyProvider.selectedUnit;

          return _homeProvider.fetchHomeData(currency: currency, unit: unit);
        },

        scrollController: _homeScrollController,
      ),

      SearchScreen(),

      CartScreen(isActiveTab: _currentIndex == 2),

      ProductListScreen(
        isEmbedded: true,

        scrollController: _productListScrollController,

        initialCategoryIndex: widget.productCategoryIndex,

        onRefresh: () {
          final currency = _currencyProvider.selectedCurrency;
          final unit = _currencyProvider.selectedUnit;

          return _exclusiveProductProvider.fetchProducts(
            endpoint: _exclusiveProductProvider.currentEndpoint,
            currency: currency,
            unit: unit,
          );
        },
      ),

      const ProfileScreen(),
      BalanceScreen(),
    ];

    return PopScope(
      // Only allow the app to close when the user is already on Home
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // already handled (app is closing)

        // Back pressed on another tab -> go to Home
        _switchToTab(0);
      },
      child: Scaffold(
        key: scaffoldKey,

        drawer: const CustomDrawer(),

        backgroundColor: const Color(0xFFFAFAFA),

        resizeToAvoidBottomInset: false,

        appBar: CustomAppBar(scaffoldKey: scaffoldKey),

        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _switchToTab,
        ),
      ),
    );
  }
}
