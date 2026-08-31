import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
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
  // ============================================================
  // TIMER
  // ============================================================

  Timer? _livePriceTimer;

  // ============================================================
  // SCROLL CONTROLLERS
  // ============================================================

  final ScrollController _homeScrollController = ScrollController();

  final ScrollController _productListScrollController = ScrollController();

  // ============================================================
  // SCAFFOLD
  // ============================================================

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // ============================================================
  // TAB
  // ============================================================

  late int _currentIndex;

  // ============================================================
  // PROVIDERS
  // ============================================================

  late HomeProvider _homeProvider;

  late CurrencyProvider _currencyProvider;

  late ExclusiveProductProvider _exclusiveProductProvider;

  late CartProvider _cartProvider;

  late PhysicalConversionProvider _physicalProvider;

  // ============================================================
  // TIMER LOCK
  // ============================================================

  bool _isRefreshing = false;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // ----------------------------------------------------------
      // GET PROVIDER REFERENCES ONCE
      // ----------------------------------------------------------

      _homeProvider = context.read<HomeProvider>();

      _currencyProvider = context.read<CurrencyProvider>();

      _exclusiveProductProvider = context.read<ExclusiveProductProvider>();

      _cartProvider = context.read<CartProvider>();

      _physicalProvider = context.read<PhysicalConversionProvider>();

      // ----------------------------------------------------------
      // INITIAL API LOAD
      // ----------------------------------------------------------

      _initializeData();
    });
  }

  // ============================================================
  // INITIAL DATA
  // ============================================================

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      final currency = _currencyProvider.selectedCurrency;

      final unit = _currencyProvider.selectedUnit;

      // ========================================================
      // IMPORTANT
      //
      // DO NOT RESTORE PHYSICAL CONVERSION FROM
      // SHARED PREFERENCES.
      //
      // Backend is the source of truth.
      //
      // We intentionally DO NOT call:
      //
      // initializePhysicalConversion()
      // ========================================================

      // --------------------------------------------------------
      // HOME
      // --------------------------------------------------------

      await _homeProvider.fetchHomeData(currency: currency, unit: unit);

      if (!mounted) return;

      // --------------------------------------------------------
      // EXCLUSIVE PRODUCTS
      // --------------------------------------------------------

      await _exclusiveProductProvider.fetchProducts(
        currency: currency,
        unit: unit,
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // CART
      // --------------------------------------------------------

      _cartProvider.updateSelection(currency: currency, unit: unit);

      await _cartProvider.fetchCart();

      if (!mounted) return;

      // --------------------------------------------------------
      // IF APP STARTED DIRECTLY ON CART TAB
      //
      // Fetch backend conversion status immediately.
      // --------------------------------------------------------

      // if (_currentIndex == 2) {
      //   await _fetchCartConversionStatus();
      // }

      if (!mounted) return;

      // --------------------------------------------------------
      // START LIVE PRICE TIMER
      // --------------------------------------------------------

      _startLivePriceTimer();
    } catch (e, stackTrace) {
      debugPrint('❌ INITIAL DATA ERROR: $e');

      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // FETCH CART CONVERSION STATUS
  //
  // THIS IS THE ONLY PLACE MAIN SCREEN ASKS
  // WHETHER CONVERSION IS ACTIVE.
  //
  // BACKEND -> PROVIDER -> CART SCREEN
  // ============================================================

  // Future<void> _fetchCartConversionStatus() async {
  //   if (!mounted) return;

  //   debugPrint('================================================');

  //   debugPrint('🛒 FETCHING BACKEND CONVERSION STATUS');

  //   debugPrint('================================================');

  //   await _physicalProvider.fetchConversionStatus();

  //   if (!mounted) return;

  //   debugPrint(
  //     '🛒 BACKEND CONVERSION STATUS -> '
  //     'active=${_physicalProvider.isActive}, '
  //     'metal=${_physicalProvider.metal}, '
  //     'amount=${_physicalProvider.amount}',
  //   );
  // }

  // ============================================================
  // LIVE PRICE TIMER
  // ============================================================

  void _startLivePriceTimer() {
    _livePriceTimer?.cancel();

    if (!mounted) return;

    _livePriceTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshLiveData();
    });

    debugPrint('⏱️ LIVE PRICE TIMER STARTED');
  }

  // ============================================================
  // LIVE PRICE REFRESH
  // ============================================================

  Future<void> _refreshLiveData() async {
    if (!mounted) return;

    // Prevent overlapping requests.
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      final currency = _currencyProvider.selectedCurrency;

      final unit = _currencyProvider.selectedUnit;

      // ========================================================
      // HOME PRICE
      // ========================================================

      await _homeProvider.fetchHomeData(currency: currency, unit: unit);

      if (!mounted) return;

      // ========================================================
      // EXCLUSIVE PRODUCT PRICES
      // ========================================================

      await _exclusiveProductProvider.fetchProducts(
        endpoint: _exclusiveProductProvider.currentEndpoint,
        currency: currency,
        unit: unit,
        showLoader: false,
      );

      if (!mounted) return;

      // ========================================================
      // IMPORTANT
      //
      // DO NOT fetch conversion status every 3 seconds.
      //
      // Conversion status is checked when Cart is opened.
      // ========================================================

      // ========================================================
      // NORMAL CART
      //
      // If physical conversion is active, don't fetch the
      // normal cart because it could overwrite the physical
      // cart state.
      // ========================================================

      if (_physicalProvider.isActive) {
        debugPrint(
          '⏭️ LIVE TIMER: Physical conversion active. '
          'Skipping normal cart API.',
        );

        return;
      }

      // --------------------------------------------------------
      // NORMAL CART
      // --------------------------------------------------------

      _cartProvider.updateSelection(currency: currency, unit: unit);

      await _cartProvider.fetchCart();
    } catch (e, stackTrace) {
      debugPrint('❌ LIVE PRICE TIMER ERROR: $e');

      debugPrint('❌ LIVE PRICE TIMER STACK: $stackTrace');
    } finally {
      _isRefreshing = false;
    }
  }

  // ============================================================
  // SWITCH TAB
  // ============================================================

  void _switchToTab(int index) {
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
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    debugPrint('🔥 MAIN SCREEN DISPOSE - CANCELLING TIMER');

    _livePriceTimer?.cancel();

    _livePriceTimer = null;

    _homeScrollController.dispose();

    _productListScrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    // ============================================================
    // INITIAL LOADING
    // ============================================================

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

    // ============================================================
    // ERROR
    // ============================================================

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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ============================================================
    // PAGES
    // ============================================================

    final pages = [
      // ========================================================
      // HOME
      // ========================================================
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

      // ========================================================
      // SEARCH
      // ========================================================
      SearchScreen(),

      // ========================================================
      // CART
      //
      // DO NOT MAKE THIS CONST.
      //
      // isActiveTab changes when user switches tabs.
      // ========================================================
      CartScreen(isActiveTab: _currentIndex == 2),

      // ========================================================
      // PRODUCT LIST
      // ========================================================
      ProductListScreen(
        isEmbedded: true,

        scrollController: _productListScrollController,

        onRefresh: () {
          final currency = _currencyProvider.selectedCurrency;

          final unit = _currencyProvider.selectedUnit;

          return _homeProvider.fetchHomeData(currency: currency, unit: unit);
        },
      ),

      // ========================================================
      // PROFILE
      // ========================================================
      const ProfileScreen(),
    ];

    // ============================================================
    // SCAFFOLD
    // ============================================================

    return Scaffold(
      key: scaffoldKey,

      drawer: const CustomDrawer(),

      backgroundColor: const Color(0xFFFAFAFA),

      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      // ========================================================
      // INDEXED STACK
      // ========================================================
      body: IndexedStack(index: _currentIndex, children: pages),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }
}
