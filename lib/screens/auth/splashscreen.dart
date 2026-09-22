import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:video_player/video_player.dart';

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

  late VideoPlayerController _videoController;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // ---------------- ANIMATION ----------------

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

    _controller.forward();

    // ---------------- VIDEO ----------------

    _videoController = VideoPlayerController.asset('assets/logo/video.mp4');

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();

      // DO NOT LOOP
      await _videoController.setLooping(false);

      // Listen for video completion
      _videoController.addListener(_videoListener);

      // Start video
      await _videoController.play();

      if (mounted) {
        setState(() {});
      }

      log("Video duration: ${_videoController.value.duration}");
    } catch (e) {
      log("Splash video error: $e");
    }
  }

  void _videoListener() {
    if (!_videoController.value.isInitialized) {
      return;
    }

    final position = _videoController.value.position;
    final duration = _videoController.value.duration;

    // Check whether video has completed
    if (position >= duration && !_hasNavigated) {
      _hasNavigated = true;

      log("Splash video completed");

      checkLogin();
    }
  }

  Future<void> checkLogin() async {
    bool loggedIn = await SessionManager.isLoggedIn();

    final token = await SessionManager.getToken();

    log("lllooooo $loggedIn..............$token");

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==================================================
          // BACKGROUND VIDEO
          // ==================================================
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : Container(color: Colors.black),
          ),

          // ==================================================
          // DARK OVERLAY
          // ==================================================
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // ==================================================
          // LOGO + TEXT
          // ==================================================
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  SvgPicture.asset(
                    'assets/logo/logo.svg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 10),

                  // TEXT
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
                          "Build a Better Future with JUNU Investment",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}
