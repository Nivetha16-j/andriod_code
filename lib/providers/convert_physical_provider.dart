import 'package:flutter/foundation.dart';
import 'package:junubullion/services/jsc_services.dart';

class ConvertPhysicalProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? gold;
  Map<String, dynamic>? silver;

  bool balancesUnlocked = false;

  Future<void> fetchConvertPhysical() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await JscService.fetchConvertPhysical();

      debugPrint('🔥 CONVERT API RESPONSE = $response');

      final data = response['data'] as Map<String, dynamic>?;

      // Your response structure:
      // data -> summary -> gold / silver
      final summary = data?['summary'] as Map<String, dynamic>?;

      gold = summary?['gold'] as Map<String, dynamic>?;
      silver = summary?['silver'] as Map<String, dynamic>?;

      // IMPORTANT:
      // balancesUnlocked is inside data, NOT summary.
      balancesUnlocked = data?['balancesUnlocked'] == true;

      debugPrint('🔥 CONVERT PHYSICAL PARSED');
      debugPrint('Gold = $gold');
      debugPrint('Silver = $silver');
      debugPrint('Unlocked = $balancesUnlocked');
    } catch (e) {
      debugPrint('❌ Convert Physical Error: $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get goldBalance {
    return _toDouble(gold?['balance']);
  }

  double get silverBalance {
    return _toDouble(silver?['balance']);
  }

  double get goldThreshold {
    return _toDouble(gold?['threshold']);
  }

  double get silverThreshold {
    return _toDouble(silver?['threshold']);
  }

  bool get canConvertGold {
    return gold?['can_convert'] == true;
  }

  bool get canConvertSilver {
    return silver?['can_convert'] == true;
  }

  String get goldThresholdLabel {
    return gold?['threshold_label']?.toString() ?? '50 g';
  }

  String get silverThresholdLabel {
    return silver?['threshold_label']?.toString() ?? '1 kg';
  }

  String get goldAvailableText {
    final unit = gold?['unit_short']?.toString() ?? 'g';

    return '${_formatBalance(goldBalance)} $unit';
  }

  String get silverAvailableText {
    final unit = silver?['unit_short']?.toString() ?? 'g';

    return '${_formatBalance(silverBalance)} $unit';
  }

  String _formatBalance(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  void clear() {
    gold = null;
    silver = null;

    balancesUnlocked = false;

    errorMessage = null;
    isLoading = false;

    notifyListeners();
  }
}
