class JscMonthlyPlanModel {
  final String jscMinimumFormatted;
  final double jscMinimumAmount;
  final List<JscTier> jscTiers;
  final DateTime? planActivatedAt;
  final DateTime? nextReminderDate;
  final bool remindersEnabled;
  final DateTime? lastReminderSentAt;
  final String currency;
  final String currencySymbol;
  final double pricePerGram;
  final String formattedPricePerGram;
  final String? stripeConfigurationError;

  JscMonthlyPlanModel({
    required this.jscMinimumFormatted,
    required this.jscMinimumAmount,
    required this.jscTiers,
    required this.planActivatedAt,
    required this.nextReminderDate,
    required this.remindersEnabled,
    required this.lastReminderSentAt,
    required this.currency,
    required this.currencySymbol,
    required this.pricePerGram,
    required this.formattedPricePerGram,
    required this.stripeConfigurationError,
  });

  factory JscMonthlyPlanModel.fromJson(Map<String, dynamic> json) {
    return JscMonthlyPlanModel(
      jscMinimumFormatted: json['jscMinimumFormatted']?.toString() ?? '',
      jscMinimumAmount:
          double.tryParse(json['jscMinimumAmount']?.toString() ?? '0') ?? 0,

      jscTiers: (json['jscTiers'] as List? ?? [])
          .map((e) => JscTier.fromJson(e))
          .toList(),

      planActivatedAt: json['planActivatedAt'] != null
          ? DateTime.tryParse(json['planActivatedAt'].toString())
          : null,

      nextReminderDate: json['nextReminderDate'] != null
          ? DateTime.tryParse(json['nextReminderDate'].toString())
          : null,

      remindersEnabled: json['remindersEnabled'] == true,

      lastReminderSentAt: json['lastReminderSentAt'] != null
          ? DateTime.tryParse(json['lastReminderSentAt'].toString())
          : null,

      currency: json['currency']?.toString() ?? 'USD',

      currencySymbol: json['currencySymbol']?.toString() ?? '\$',

      pricePerGram:
          double.tryParse(json['pricePerGram']?.toString() ?? '0') ?? 0,

      formattedPricePerGram: json['formattedPricePerGram']?.toString() ?? '',

      stripeConfigurationError: json['stripeConfigurationError']?.toString(),
    );
  }
}

class JscTier {
  final double sgd;
  final double amount;
  final String formatted;
  final String currency;

  JscTier({
    required this.sgd,
    required this.amount,
    required this.formatted,
    required this.currency,
  });

  factory JscTier.fromJson(Map<String, dynamic> json) {
    return JscTier(
      sgd: double.tryParse(json['sgd']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      formatted: json['formatted']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
    );
  }
}
