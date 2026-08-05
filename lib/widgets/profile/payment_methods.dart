import 'package:flutter/material.dart';
import 'package:junubullion/providers/checkout_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 3;

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutProvider>().fetchPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.paymentMethods.isEmpty) {
      return const Center(child: Text("No payment methods available"));
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Payment Methods",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = provider.paymentMethods[index];

                  IconData icon;
                  String title;

                  switch (method) {
                    case "bank_transfer":
                      icon = Icons.account_balance;
                      title = "Bank Transfer";
                      break;

                    case "card":
                      icon = Icons.credit_card;
                      title = "Card";
                      break;

                    default:
                      icon = Icons.payment;
                      title = method;
                  }

                  return Card(
                    child: ListTile(leading: Icon(icon), title: Text(title)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
