import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/models/jsc_investment_transaction_model.dart';
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

  // JSC Investment transactions
  List<JscInvestmentTransaction> _jscInvestments = [];

  List<JscInvestmentTransaction> get jscInvestments => _jscInvestments;

  bool _isInvestmentsLoading = false;

  bool get isInvestmentsLoading => _isInvestmentsLoading;

  String? _investmentsErrorMessage;

  String? get investmentsErrorMessage => _investmentsErrorMessage;

  bool _hasLoadedInvestments = false;

  Future<void> getJscMonthlyPlan({
    required String currency,
    bool forceRefresh = false,
  }) async {
    // Prevent duplicate requests
    if (_isInvestmentsLoading) return;

    // Avoid fetching again if data is already available
    if (_hasLoadedInvestments && !forceRefresh) return;

    _isInvestmentsLoading = true;
    _investmentsErrorMessage = null;
    notifyListeners();

    try {
      final response = await JscService.getJscMonthlyPlan(currency);

      log('JSC INVESTMENTS RESPONSE: $response');

      if (response['status'] == true) {
        final rawData = response['data'];

        if (rawData is List) {
          _jscInvestments = rawData
              .whereType<Map>()
              .map(
                (item) => JscInvestmentTransaction.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();

          _hasLoadedInvestments = true;
        } else {
          _investmentsErrorMessage = 'Invalid investment data received.';
        }
      } else {
        _investmentsErrorMessage =
            response['message']?.toString() ??
            'Unable to fetch JSC investments.';
      }
    } catch (e, stackTrace) {
      log('JSC INVESTMENTS ERROR: $e', stackTrace: stackTrace);

      _investmentsErrorMessage = e.toString();
    } finally {
      _isInvestmentsLoading = false;
      notifyListeners();
    }
  }

  Future<void> monthlyPlanSuccess(String paymentIntentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await JscService.monthlyPlanSuccess(paymentIntentId);

      log('JSC MONTHLY PLAN RESPONSE: $response');

      // Your API returns "success": true.
      final isSuccess =
          response['success'] == true || response['status'] == true;

      if (isSuccess) {
        final rawData = response['data'];

        if (rawData is Map) {
          final data = Map<String, dynamic>.from(rawData);

          _monthlyPlan = JscMonthlyPlanModel.fromJson(data);

          // log('JSC MINIMUM: ${_monthlyPlan!.jscMinimumAmount}');
          // log('JSC TIERS: ${_monthlyPlan!.jscTiers.length}');
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
