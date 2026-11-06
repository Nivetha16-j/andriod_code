class GspInvestmentTransaction {
  final int id;
  final String referenceNumber;
  final String description;
  final String amount;
  final String unit;
  final String value;
  final String status;
  final String investmentDate;
  final String source;

  GspInvestmentTransaction({
    required this.id,
    required this.referenceNumber,
    required this.description,
    required this.amount,
    required this.unit,
    required this.value,
    required this.status,
    required this.investmentDate,
    required this.source,
  });

  factory GspInvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return GspInvestmentTransaction(
      id: json['id'] ?? 0,
      referenceNumber: json['reference_number']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      unit: json['unit']?.toString() ?? '',
      value: json['value']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      investmentDate: json['investment_date']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }
}
