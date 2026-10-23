class WalletDashboardModel {
  final String formattedTotalDigitalBalance;
  final String gspFormattedTotalValue;
  final String jscFormattedTotalValue;

  WalletDashboardModel({
    required this.formattedTotalDigitalBalance,
    required this.gspFormattedTotalValue,
    required this.jscFormattedTotalValue,
  });

  factory WalletDashboardModel.fromJson(Map<String, dynamic> json) {
    return WalletDashboardModel(
      formattedTotalDigitalBalance:
          json['data']['formatted_total_digital_balance'] ?? '\$0.00',

      gspFormattedTotalValue:
          json['data']['gsp']['formatted_total_value'] ?? '\$0.00',

      jscFormattedTotalValue:
          json['data']['jsc']['formatted_total_value'] ?? '\$0.00',
    );
  }
}
