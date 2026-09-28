import 'package:flutter/material.dart';
import 'package:junubullion/providers/account_provider.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/checkout_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/gsp_balance_provider.dart';
import 'package:junubullion/providers/gsp_monthly_plan_provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/providers/jsc_balance_provider.dart';
import 'package:junubullion/providers/kyc_provider.dart';
import 'package:junubullion/providers/language_provider.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/providers/product_detail_provider.dart';
import 'package:junubullion/providers/review_provider.dart';
import 'package:junubullion/providers/testimonial_provider.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/services/app_bootstrap.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final languageProvider = LanguageProvider();

  // Start heavy init in the background — do not block the first frame.
  AppBootstrap.start(languageProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ExclusiveProductProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => KycProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => TestimonialProvider()),
        ChangeNotifierProvider(create: (_) => PhysicalConversionProvider()),
        ChangeNotifierProvider(create: (_) => JscBalanceProvider()),
        ChangeNotifierProvider(create: (_) => GspBalanceProvider()),
        ChangeNotifierProvider(create: (_) => GspMonthlyPlanProvider()),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
      ),
    );
  }
}
