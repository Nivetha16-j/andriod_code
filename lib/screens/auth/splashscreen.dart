import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
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

  Timer? _fallbackTimer;
  Timer? _initializationTimer;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Fallback if video initialization gets stuck.
    _initializationTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (!_hasNavigated &&
            (_videoController == null ||
                !_videoController!.value.isInitialized)) {
          log("Video initialization timeout");
          _navigateOnce();
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasNavigated) return;

      _videoController = VideoPlayerController.asset(
        'assets/logo/video.mp4',
      );

      _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    final video = _videoController;
    if (video == null) return;

    try {
      await video.initialize();

      if (!mounted || _hasNavigated) return;

      _initializationTimer?.cancel();

      await video.setLooping(false);

      video.addListener(_videoListener);

      // Fallback if playback freezes or completion is not detected.
      _fallbackTimer = Timer(
        video.value.duration + const Duration(seconds: 5),
        () {
          if (!_hasNavigated) {
            log("Video fallback timer triggered");
            _navigateOnce();
          }
        },
      );

      await video.play();

      if (mounted) {
        setState(() {});
      }

      log("Video duration: ${video.value.duration}");
    } catch (e) {
      log("Splash video error: $e");
      _navigateOnce();
    }
  }

  void _videoListener() {
    final video = _videoController;

    if (video == null || !video.value.isInitialized) return;

    if (video.value.hasError) {
      log("Video playback error: ${video.value.errorDescription}");
      _navigateOnce();
      return;
    }

    if (video.value.isCompleted && !_hasNavigated) {
      log("Splash video completed");
      _navigateOnce();
    }
  }

  void _navigateOnce() {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;

    _fallbackTimer?.cancel();
    _initializationTimer?.cancel();

    checkLogin();
  }

  Future<void> checkLogin() async {
    try {
      await AppBootstrap.ready;

      final loggedIn = await SessionManager.isLoggedIn();

      log("Logged In: $loggedIn");

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        loggedIn ? AppRoutes.home : AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      log("Splash navigation error: $e");
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _initializationTimer?.cancel();

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
        ],
      ),
    );
  }
}