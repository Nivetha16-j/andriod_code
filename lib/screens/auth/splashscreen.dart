import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/plans/jsc/jsc_form.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/services/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation
    _controller.forward();

    checkLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    bool loggedIn = await SessionManager.isLoggedIn();

    final token = await SessionManager.getToken();

    log("lllooooo $loggedIn)..............$token");

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      // Navigator.of(
      //   context,
      // ).push(MaterialPageRoute(builder: (_) => JscApplicationForm()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            // SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Color.fromRGBO(223, 174, 2, 1),
                        Color.fromRGBO(251, 230, 157, 1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    "JUNU BULLION",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
