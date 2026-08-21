import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/screens/cart/cartscreen.dart';
import 'package:junubullion/screens/home/homescreen.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:junubullion/screens/search/search.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/product/custom_productlist.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _livePriceTimer;

  final ScrollController _homeScrollController = ScrollController();

  final ScrollController _productListScrollController = ScrollController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late int _currentIndex;

  // --------------------------------------------------
  // PROVIDER REFERENCES
  // --------------------------------------------------

  late HomeProvider _homeProvider;
  late CurrencyProvider _currencyProvider;
  late ExclusiveProductProvider _exclusiveProductProvider;
  late CartProvider _cartProvider;

  // Prevent multiple timer callbacks from running
  // at the same time.
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Get provider references ONCE.
      //
      // The timer will NOT use context.read() anymore.
      _homeProvider = context.read<HomeProvider>();
      _currencyProvider = context.read<CurrencyProvider>();
      _exclusiveProductProvider = context.read<ExclusiveProductProvider>();
      _cartProvider = context.read<CartProvider>();

      _initializeData();
    });
  }

  // ==================================================
  // INITIAL DATA
  // ==================================================

  Future<void> _initializeData() async {
    if (!mounted) return;

    final currency = _currencyProvider.selectedCurrency;

    final unit = _currencyProvider.selectedUnit;

    // --------------------------------------------------
    // HOME
    // --------------------------------------------------

    await _homeProvider.fetchHomeData(currency: currency, unit: unit);

    if (!mounted) return;

    // --------------------------------------------------
    // EXCLUSIVE PRODUCTS
    // --------------------------------------------------

    await _exclusiveProductProvider.fetchProducts(
      currency: currency,
      unit: unit,
    );

    if (!mounted) return;

    // --------------------------------------------------
    // CART
    // --------------------------------------------------

    _cartProvider.updateSelection(currency: currency, unit: unit);

    await _cartProvider.fetchCart();

    if (!mounted) return;

    // --------------------------------------------------
    // START TIMER
    // --------------------------------------------------

    _startLivePriceTimer();
  }

  // ==================================================
  // LIVE PRICE TIMER
  // ==================================================

  void _startLivePriceTimer() {
    // Cancel any existing timer.
    _livePriceTimer?.cancel();

    if (!mounted) return;

    _livePriceTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshLiveData();
    });
  }

  Future<void> _refreshLiveData() async {
    // --------------------------------------------------
    // VERY IMPORTANT
    // --------------------------------------------------

    if (!mounted) return;

    // Don't allow another refresh while the previous
    // one is still running.
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      // --------------------------------------------------
      // READ VALUES FROM PROVIDER REFERENCE
      // --------------------------------------------------
      //
      // NO context.read() HERE.
      //

      final currency = _currencyProvider.selectedCurrency;

      final unit = _currencyProvider.selectedUnit;

      // --------------------------------------------------
      // HOME
      // --------------------------------------------------

      await _homeProvider.fetchHomeData(currency: currency, unit: unit);

      if (!mounted) return;

      // --------------------------------------------------
      // EXCLUSIVE PRODUCTS
      // --------------------------------------------------

      await _exclusiveProductProvider.fetchProducts(
        endpoint: _exclusiveProductProvider.currentEndpoint,
        currency: currency,
        unit: unit,
        showLoader: false,
      );

      if (!mounted) return;

      // --------------------------------------------------
      // CART
      // --------------------------------------------------

      _cartProvider.updateSelection(currency: currency, unit: unit);

      await _cartProvider.fetchCart();

      if (!mounted) return;
    } catch (e, stackTrace) {
      debugPrint('LIVE PRICE TIMER ERROR: $e');

      debugPrint('LIVE PRICE TIMER STACK: $stackTrace');
    } finally {
      _isRefreshing = false;
    }
  }

  // ==================================================
  // DISPOSE
  // ==================================================

  @override
  void dispose() {
    debugPrint('🔥 MAIN SCREEN DISPOSE - CANCELLING TIMER');

    _livePriceTimer?.cancel();
    _livePriceTimer = null;

    _homeScrollController.dispose();
    _productListScrollController.dispose();

    super.dispose();
  }

  // ==================================================
  // SWITCH TAB
  // ==================================================

  void _switchToTab(int index) {
    if (!mounted) return;

    if (index == 0 && _homeScrollController.hasClients) {
      _homeScrollController.jumpTo(0);
    } else if (index == 3 && _productListScrollController.hasClients) {
      _productListScrollController.jumpTo(0);
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    // --------------------------------------------------
    // LOADING
    // --------------------------------------------------

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

    // --------------------------------------------------
    // ERROR
    // --------------------------------------------------

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
              Text(homeProvider.errorMessage!),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: () {
                  final currency = _currencyProvider.selectedCurrency;

                  final unit = _currencyProvider.selectedUnit;

                  _homeProvider.fetchHomeData(currency: currency, unit: unit);
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // --------------------------------------------------
    // PAGES
    // --------------------------------------------------

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

      const CartScreen(),

      ProductListScreen(
        isEmbedded: true,

        scrollController: _productListScrollController,

        onRefresh: () {
          final currency = _currencyProvider.selectedCurrency;

          final unit = _currencyProvider.selectedUnit;

          return _homeProvider.fetchHomeData(currency: currency, unit: unit);
        },
      ),

      const ProfileScreen(),
    ];

    // --------------------------------------------------
    // SCAFFOLD
    // --------------------------------------------------

    return Scaffold(
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
    );
  }
}
