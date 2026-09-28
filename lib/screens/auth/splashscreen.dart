import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/services/app_bootstrap.dart';
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

  VideoPlayerController? _videoController;
  bool _hasNavigated = false;

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

    _controller.forward();

    // Let the first Flutter frame paint (logo on black) before starting
    // the video decoder — which can delay the first frame on cold start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _videoController = VideoPlayerController.asset('assets/logo/video.mp4');
      _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    final video = _videoController;
    if (video == null) return;

    try {
      await video.initialize();
      await video.setLooping(false);
      video.addListener(_videoListener);
      await video.play();

      if (mounted) {
        setState(() {});
      }

      log("Video duration: ${video.value.duration}");
    } catch (e) {
      log("Splash video error: $e");
      if (!_hasNavigated) {
        _hasNavigated = true;
        checkLogin();
      }
    }
  }

  void _videoListener() {
    final video = _videoController;
    if (video == null || !video.value.isInitialized) {
      return;
    }

    final position = video.value.position;
    final duration = video.value.duration;

    if (position >= duration && !_hasNavigated) {
      _hasNavigated = true;
      log("Splash video completed");
      checkLogin();
    }
  }

  Future<void> checkLogin() async {
    await AppBootstrap.ready;

    final loggedIn = await SessionManager.isLoggedIn();
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
    final video = _videoController;
    if (video != null) {
      video.removeListener(_videoListener);
      video.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = _videoController;
    final videoReady = video != null && video.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: videoReady
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: video.value.size.width,
                      height: video.value.size.height,
                      child: VideoPlayer(video),
                    ),
                  )
                : const ColoredBox(color: Colors.black),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo/logo.svg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
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
