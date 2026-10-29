import 'package:flutter/material.dart';
import 'package:junubullion/providers/graph_provider.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'dart:developer';
import 'dart:async';

import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_homegraph.dart';
import 'package:junubullion/widgets/home/custom_moregraphs.dart';
import 'package:provider/provider.dart';

class LiveSpotPriceCard extends StatefulWidget {
  final Map<String, dynamic>? spotPricesData;

  final String selectedCurrency;
  final String selectedUnit;

  final Function(String, String) onSelectionChanged;

  const LiveSpotPriceCard({
    super.key,
    this.spotPricesData,
    required this.selectedCurrency,
    required this.selectedUnit,
    required this.onSelectionChanged,
  });

  @override
  State<LiveSpotPriceCard> createState() => _LiveSpotPriceCardState();
}

class _LiveSpotPriceCardState extends State<LiveSpotPriceCard> {
  @override
  void initState() {
    super.initState();

    _spotPrice = widget.spotPricesData;

    _fetchSpotPrice();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchSpotPrice();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchGraph(); // uses rangeCodes[selectedIndex], which is '1d' by default
    });
  }

  @override
  void didUpdateWidget(covariant LiveSpotPriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // didUpdateWidget
    if (oldWidget.selectedCurrency != widget.selectedCurrency ||
        oldWidget.selectedUnit != widget.selectedUnit) {
      _fetchSpotPrice();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fetchGraph();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // String selectedCurrency = 'USD';
  // String selectedUnit = 'Gram';

  int selectedIndex = 0; // 1 Month selected by default

  final List<String> tabs = [
    '1 Day',
    '1 Month',
    'Year-to-Date',
    '1 Year',
    '5 Years',
    '10 Years',
    'All',
  ];

  // API range codes, same order as `tabs`
  final List<String> rangeCodes = [
    '1d',
    '1mo',
    'ytd',
    '1y',
    '5y',
    '10y',
    'all',
  ];

  void _fetchGraph() {
    context.read<GraphProvider>().fetchSingleGraph(
      currency: widget.selectedCurrency,
      unit: widget.selectedUnit,
      range: rangeCodes[selectedIndex],
    );
  }

  final List<String> currencies = [
    'USD',
    'SGD',
    'CAD',
    'INR',
    'EUR',
    'AED',
    'CNY',
  ];
  final List<String> units = ['Gram', 'Ounce', 'Kilogram'];

  final Map<String, String> unitMap = {
    'Gram': 'gram',
    'Ounce': 'toz',
    'Kilogram': 'kg',
  };

  Map<String, dynamic>? _spotPrice;
  Timer? _timer;

  bool _isLoading = false;

  Future<void> _fetchSpotPrice() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final data = await ApiService.fetchSpotPrice(
        currency: widget.selectedCurrency,
        unit: unitMap[widget.selectedUnit]!,
      );
      log(
        "selectedCurrency: $widget.selectedCurrency, selectedUnit: ${unitMap[widget.selectedUnit]}",
      );

      print(data);
      log("Fetched spot price data: $data");

      log("Gold Price: ${data['metals']['gold']['price']}");
      log("Silver Price: ${data['metals']['silver']['price']}");

      if (mounted) {
        setState(() {
          _spotPrice = data;
        });
      }
    } finally {
      _isLoading = false;
    }
  }

  // Helper method to parse metal prices
  String _getPrice(String metal) {
    if (_spotPrice == null || _spotPrice!.isEmpty) {
      return '${widget.selectedCurrency} 0.00';
    }

    try {
      final String metalKey = metal.toLowerCase(); // 'gold' or 'silver'

      // Extract root dataset or list
      dynamic rawData =
          _spotPrice!['spot_prices'] ?? _spotPrice!['data'] ?? _spotPrice;

      // --- CASE 1: Data is a List of objects ---
      if (rawData is List) {
        for (var item in rawData) {
          if (item is Map && _matchesCurrencyAndUnit(item)) {
            return _extractMetalPrice(item, metalKey);
          }
        }
      }
      // --- CASE 2: Data is a single Map object (Your Current Log Structure) ---
      else if (rawData is Map) {
        return _extractMetalPrice(rawData, metalKey);
      }
    } catch (e) {
      debugPrint('Error parsing spot price for $metal: $e');
    }

    return '${widget.selectedCurrency} 0.00';
  }

  // Helper 1: Checks if currency and unit match dropdown selections
  bool _matchesCurrencyAndUnit(Map item) {
    final String? itemCurrency = item['currency']?.toString();
    final String? itemUnit =
        item['unit_label']?.toString() ?? item['unit']?.toString();

    return itemCurrency?.toUpperCase() ==
            widget.selectedCurrency.toUpperCase() &&
        itemUnit?.toLowerCase() == widget.selectedUnit.toLowerCase();
  }

  // Helper 2: Safely reads the price from 'metals' map or direct key
  String _extractMetalPrice(Map item, String metalKey) {
    dynamic metalObj;

    // Check inside 'metals' object first (e.g. item['metals']['gold'])
    if (item['metals'] is Map) {
      metalObj = item['metals'][metalKey];
    } else {
      // Fallback if structured directly (e.g. item['gold'])
      metalObj = item[metalKey];
    }

    if (metalObj is Map) {
      final rawPrice = metalObj['price'];
      final double priceVal =
          double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;
      return '${widget.selectedCurrency} ${priceVal.toStringAsFixed(2)}';
    } else if (metalObj is num || metalObj is String) {
      final double priceVal = double.tryParse(metalObj.toString()) ?? 0.0;
      return '${widget.selectedCurrency} ${priceVal.toStringAsFixed(2)}';
    }

    return '${widget.selectedCurrency} 0.00';
  }

  @override
  Widget build(BuildContext context) {
    final String goldPriceText = _getPrice('gold');
    final String silverPriceText = _getPrice('silver');

    final provider = context.watch<GraphProvider>();

    // replace: if (provider.isLoading) {
    if (provider.isLoading && provider.graphData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final graphData = provider.graphData;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.BgGradient),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // SPOT PRICE HEADER
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TranslatedText(
                  'Spot price',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Real-Time Feed",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 3),

            const TranslatedText(
              'Live precious metals prices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // GOLD + SILVER PRICE CARDS
            // ==========================================
            Row(
              children: [
                Expanded(
                  child: _buildPriceBadge(
                    metalName: 'Gold',
                    priceText: goldPriceText,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _buildPriceBadge(
                    metalName: 'Silver',
                    priceText: silverPriceText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            // ==========================================
            // CURRENCY + UNIT DROPDOWNS
            // ==========================================
            Row(
              children: [
                Expanded(
                  child: _buildDropdownContainer(
                    icon: Icons.attach_money,
                    label: 'Currency',
                    value: widget.selectedCurrency,
                    items: currencies,
                    onChanged: (val) {
                      if (val != null) {
                        widget.onSelectionChanged(val, widget.selectedUnit);
                      }
                    },
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: _buildDropdownContainer(
                    icon: Icons.balance,
                    label: 'Unit',
                    value: widget.selectedUnit,
                    items: units,
                    onChanged: (val) {
                      if (val != null) {
                        widget.onSelectionChanged(widget.selectedCurrency, val);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Column(
              children: [
                _buildTabsGrid(), // <-- replaces the old 42px single-row tab Container

                const SizedBox(height: 12),

                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomMoreGraphs(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDAA520)),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'More Charts',
                          style: TextStyle(
                            color: Color(0xFFFFB800),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_right_alt, // long arrow like the design
                          color: Color(0xFFFFB800),
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // replace: HomeGraph(chartData: graphData!),
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                if (graphData != null) HomeGraph(chartData: graphData),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsGrid() {
    const gold = Color(0xFFDAA520);
    const int perRow = 4;
    final int rowCount = (tabs.length / perRow).ceil();
    final BorderSide divider = BorderSide(
      color: gold.withOpacity(0.25),
      width: 0.8,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          children: List.generate(rowCount, (row) {
            return SizedBox(
              height: 44,
              child: Row(
                children: List.generate(perRow, (col) {
                  final int index = row * perRow + col;

                  // empty slot to keep the 4-column grid aligned
                  if (index >= tabs.length) {
                    return const Expanded(child: SizedBox());
                  }

                  final bool isSelected = selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (selectedIndex == index)
                          return; // ignore re-tapping the active tab
                        setState(() {
                          selectedIndex = index;
                        });
                        _fetchGraph();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? gold : Colors.transparent,
                          border: Border(
                            right: col < perRow - 1 ? divider : BorderSide.none,
                            bottom: row < rowCount - 1
                                ? divider
                                : BorderSide.none,
                          ),
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8AB4F8),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPriceBadge({
    required String metalName,
    required String priceText,
  }) {
    final bool isGold = metalName.toLowerCase() == 'gold';

    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF70282A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGold ? AppColors.mustard : Colors.white70,
          width: 2.2,
        ),
      ),
      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Metal name
              TranslatedText(
                metalName.toUpperCase(),
                style: TextStyle(
                  color: isGold ? AppColors.mustard : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Price
              Text(
                priceText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),

              const SizedBox(height: 5),

              // Currency / Unit
              Text(
                '${widget.selectedCurrency}/${widget.selectedUnit}',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Gold/Silver indicator
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: isGold ? AppColors.mustard : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF982628),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            // const SizedBox(width: 12),
            Icon(icon, color: const Color(0xFFD2A900), size: 21),

            // const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(),

            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : null,
                dropdownColor: const Color(0xFF3A2022),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: onChanged,
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ),
            ),

            // const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
