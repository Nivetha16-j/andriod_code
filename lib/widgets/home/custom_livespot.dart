import 'package:flutter/material.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'dart:developer';
import 'dart:async';

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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Live spot price',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),

            Row(
              children: [
                Expanded(
                  child: _buildPriceBadge(
                    metalName: 'Gold',
                    priceText: goldPriceText,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildPriceBadge(
                    metalName: 'Silver',
                    priceText: silverPriceText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Currency Dropdown
            _buildDropdownContainer(
              value: widget.selectedCurrency,
              items: currencies,
              onChanged: (val) {
                if (val != null) {
                  widget.onSelectionChanged(val, widget.selectedUnit);
                }
              },
            ),
            const SizedBox(height: 12.0),

            // Unit Dropdown
            _buildDropdownContainer(
              value: widget.selectedUnit,
              items: units,
              onChanged: (val) {
                if (val != null) {
                  widget.onSelectionChanged(widget.selectedCurrency, val);
                }
              },
            ),
            const SizedBox(height: 20.0),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Marketing Trend',
                  style: TextStyle(
                    color: lightGoldText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBadge({
    required String metalName,
    required String priceText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metalName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: accentGold,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            priceText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownContainer({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1E1035),
            size: 28,
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String itemValue) {
            return DropdownMenuItem<String>(
              value: itemValue,
              child: Text(itemValue),
            );
          }).toList(),
        ),
      ),
    );
  }
}
