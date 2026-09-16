import 'package:flutter/material.dart';
import 'package:junubullion/models/gsp_monthly_investment_plan_model.dart';
import 'package:junubullion/services/gsp_service.dart';

class GspMonthlyPlanProvider extends ChangeNotifier {
  GspMonthlyPlanModel? _monthlyPlan;

  bool _isLoading = false;
  String? _errorMessage;

  GspMonthlyPlanModel? get monthlyPlan => _monthlyPlan;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchMonthlyPlan({required String currency}) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await GspService.fetchMonthlyPlan(currency);

      if (response['status'] == true) {
        final data = Map<String, dynamic>.from(response['data'] ?? {});

        _monthlyPlan = GspMonthlyPlanModel.fromJson(data);
      } else {
        _errorMessage =
            response['message']?.toString() ??
            'Unable to fetch GSP monthly plan.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }
}
