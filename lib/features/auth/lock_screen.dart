import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../home/views/home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _isEmulator = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceAndAuth();
  }

  Future<void> _checkDeviceAndAuth() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _isEmulator = !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _isEmulator = !iosInfo.isPhysicalDevice;
      }
    } catch (e) {
      debugPrint("Device detection error: $e");
    }

    if (_isEmulator) {
      debugPrint("Emulator detected: Bypassing security.");
      await Future.delayed(const Duration(seconds: 1));
      _navigateToHome();
    } else {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() => _isAuthenticating = true);

      final bool isSupported = await auth.isDeviceSupported();
      if (!isSupported) {
        _navigateToHome();
        return;
      }

      // --- VERSION 3.0.0+ SYNTAX ---
      // 1. Direct parameters only (No 'options' or 'AuthenticationOptions')
      // 2. 'stickyAuth' is now 'persistAcrossBackgrounding'
      authenticated = await auth.authenticate(
        localizedReason: 'Access your private journal',
        persistAcrossBackgrounding: true, // Formerly stickyAuth
        biometricOnly: false, // Allows PIN/Pattern fallback
      );
    } catch (e) {
      debugPrint("Auth Error: $e");
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }

    if (authenticated) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Get.off(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isEmulator
                      ? Icons.developer_mode
                      : Icons.lock_outline_rounded,
                  size: 64,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Embrace Privacy",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isEmulator
                    ? "Emulator debug mode active."
                    : "Your memories are safely locked away.\nUnlock to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 60),
              if (_isAuthenticating)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: Icon(_isEmulator ? Icons.play_arrow : Icons.lock_open),
                  label: Text(_isEmulator ? "Enter App" : "Unlock Journal"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
