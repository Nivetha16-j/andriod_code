import 'package:flutter/material.dart';
import 'package:junubullion/screens/auth/loginscreen.dart';
import 'package:junubullion/screens/auth/otpscreen.dart';
import 'package:junubullion/screens/auth/registrationscreen.dart';
import 'package:junubullion/screens/auth/splashscreen.dart';
import 'package:junubullion/screens/home/homescreen.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/product/product_details.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const register = '/register';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String productDetails = "/productDetails";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      case '/otp':
        final args = settings.arguments as Map<String, dynamic>?;

        final String phone = args?['phoneNumber'] ?? '';
        final String verificationId = args?['verificationId'] ?? '';

        return MaterialPageRoute(
          builder: (_) =>
              OTPScreen(phoneNumber: phone, verificationId: verificationId),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case productDetails:
        final product = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
