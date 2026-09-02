class GspMonthlyPlanModel {
  final String gspMinimumFormatted;
  final double gspMinimumAmount;
  final List<GspTier> gspTiers;
  final DateTime? planActivatedAt;
  final DateTime? nextReminderDate;
  final bool remindersEnabled;
  final DateTime? lastReminderSentAt;
  final String currency;
  final String currencySymbol;
  final double pricePerGram;
  final String formattedPricePerGram;
  final String? stripeConfigurationError;

  GspMonthlyPlanModel({
    required this.gspMinimumFormatted,
    required this.gspMinimumAmount,
    required this.gspTiers,
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

  factory GspMonthlyPlanModel.fromJson(Map<String, dynamic> json) {
    return GspMonthlyPlanModel(
      gspMinimumFormatted: json['gsp_minimum_formatted']?.toString() ?? '',
      gspMinimumAmount:
          double.tryParse(json['gsp_minimum_amount']?.toString() ?? '0') ?? 0,

      gspTiers: (json['gsp_tiers'] as List? ?? [])
          .map((e) => GspTier.fromJson(e))
          .toList(),

      planActivatedAt: json['plan_activated_at'] != null
          ? DateTime.tryParse(json['plan_activated_at'].toString())
          : null,

      nextReminderDate: json['next_reminder_date'] != null
          ? DateTime.tryParse(json['next_reminder_date'].toString())
          : null,

      remindersEnabled: json['reminders_enabled'] == true,

      lastReminderSentAt: json['last_reminder_sent_at'] != null
          ? DateTime.tryParse(json['last_reminder_sent_at'].toString())
          : null,

      currency: json['currency']?.toString() ?? 'USD',

      currencySymbol: json['currency_symbol']?.toString() ?? '\$',

      pricePerGram:
          double.tryParse(json['price_per_gram']?.toString() ?? '0') ?? 0,

      formattedPricePerGram: json['formatted_price_per_gram']?.toString() ?? '',

      stripeConfigurationError: json['stripe_configuration_error']?.toString(),
    );
  }
}

class GspTier {
  final double sgd;
  final double amount;
  final String formatted;
  final String currency;

  GspTier({
    required this.sgd,
    required this.amount,
    required this.formatted,
    required this.currency,
  });

  factory GspTier.fromJson(Map<String, dynamic> json) {
    return GspTier(
      sgd: double.tryParse(json['sgd']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      formatted: json['formatted']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
    );
  }
}
