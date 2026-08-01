import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/providers/product_detail_provider.dart';
import 'package:junubullion/providers/review_provider.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe.publishableKey =
  //     "pk_test_xxxxxxxxxxxxxxxxx";

  // await Stripe.instance.applySettings();
  await dotenv.load(fileName: ".env");

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();

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
      ],
      child: const MyApp(),
    ),
  );

  try {
    await Firebase.initializeApp();
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: AppColors.primaryRed,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(fontFamily: 'Montserrat'),
    );
  }
}
