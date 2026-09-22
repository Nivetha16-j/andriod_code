import 'package:flutter/material.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'dart:developer';
import 'dart:async';

import 'package:junubullion/widgets/custom_translated_text.dart';

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
  }

  @override
  void didUpdateWidget(covariant LiveSpotPriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedCurrency != widget.selectedCurrency ||
        oldWidget.selectedUnit != widget.selectedUnit) {
      _fetchSpotPrice();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static const Color accentGold = Color(0xFFC59800);
  static const Color lightGoldText = Color(0xFFE0B222);

  // String selectedCurrency = 'USD';
  // String selectedUnit = 'Gram';

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

            // ==========================================
            // MARKETING TREND
            // ==========================================
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: GestureDetector(
            //     onTap: () {},
            //     child: const TranslatedText(
            //       'Marketing Trend',
            //       style: TextStyle(
            //         color: lightGoldText,
            //         fontSize: 16.0,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
          ],
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
