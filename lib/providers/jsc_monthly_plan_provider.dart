import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/models/jsc_monthly_investment_plan_model.dart';
import 'package:junubullion/services/jsc_services.dart';

class JscMonthlyPlanProvider extends ChangeNotifier {
  JscMonthlyPlanModel? _monthlyPlan;

  bool _isLoading = false;
  String? _errorMessage;

  JscMonthlyPlanModel? get monthlyPlan => _monthlyPlan;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchMonthlyPlan({required String currency}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await JscService.fetchMonthlyPlan(currency);

      log('JSC MONTHLY PLAN RESPONSE: $response');

      // Your API returns "success": true.
      final isSuccess =
          response['success'] == true || response['status'] == true;

      if (isSuccess) {
        final rawData = response['data'];

        if (rawData is Map) {
          final data = Map<String, dynamic>.from(rawData);

          _monthlyPlan = JscMonthlyPlanModel.fromJson(data);

          log('JSC MINIMUM: ${_monthlyPlan!.jscMinimumAmount}');
          log('JSC TIERS: ${_monthlyPlan!.jscTiers.length}');
        } else {
          _errorMessage = 'Invalid monthly plan data received.';
        }
      } else {
        _errorMessage =
            response['message']?.toString() ??
            'Unable to fetch JSC monthly plan.';
      }
    } catch (e, stackTrace) {
      log('JSC MONTHLY PLAN PROVIDER ERROR: $e', stackTrace: stackTrace);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
