import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:junubullion/screens/home/homescreen.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/product/custom_productlist.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Map<String, dynamic>? _homeData;
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _livePriceTimer;

  bool _isFetching = false;

  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _productListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    print("MainScreen initState");

    _initialLoad();
    _startLivePriceTimer();
  }

  @override
  void dispose() {
    _livePriceTimer?.cancel();
    _homeScrollController.dispose();
    _productListScrollController.dispose();
    super.dispose();
  }

  // First load shows full-screen spinner
  Future<void> _initialLoad() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadHomeData();
  }

  // Quiet background fetch (does not set _isLoading = true)
  Future<void> _loadHomeData() async {
    if (_isFetching) return;

    _isFetching = true;

    try {
      final data = await ApiService.fetchHomeData();
      log("Timeeeeeeeeeee: ${DateTime.now()}");
      if (mounted) {
        setState(() {
          _homeData = data;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted && _homeData == null) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    } finally {
      _isFetching = false;
    }
  }

  // 1-second timer for live prices
  void _startLivePriceTimer() {
    _livePriceTimer?.cancel();

    _livePriceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      log("Timer fired: ${DateTime.now()}");

      if (_currentIndex == 0) {
        _loadHomeData();
      }
    });
  }

  void _switchToTab(int index) {
    if (index == 0 && _homeScrollController.hasClients) {
      _homeScrollController.jumpTo(0.0);
    } else if (index == 3 && _productListScrollController.hasClients) {
      _productListScrollController.jumpTo(0.0);
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: const CustomAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initialLoad,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final exclusiveProducts =
        _homeData?['data']?['exclusive_products'] as List<dynamic>?;

    final List<Widget> pages = [
      HomeScreen(
        homeData: _homeData,
        onViewMoreTap: () => _switchToTab(3),
        onRefresh: _loadHomeData,
        scrollController: _homeScrollController,
      ),
      const Center(child: Text("Search / Category")),
      const Center(child: Text("Cart Screen")),
      ProductListScreen(
        initialProducts: exclusiveProducts,
        isEmbedded: true,
        scrollController: _productListScrollController,
        onRefresh: _loadHomeData,
      ),
      const Center(child: Text("Profile Screen")),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }
}
