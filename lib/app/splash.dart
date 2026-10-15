import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/strings.dart';
import '../state/app_state.dart';
import 'theme.dart';

/// Splash: brand moment, then routes by persisted state —
/// first run → language onboarding, otherwise the role dashboard.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _gone = false;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    if (!st.loading && !_gone) {
      _gone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          st.onboarded ? '/home' : '/language',
        );
      });
    }
    return Scaffold(
      backgroundColor: KsColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: KsColors.primaryContainer,
                  borderRadius: BorderRadius.circular(42),
                ),
                child: const Icon(
                  Icons.handshake,
                  color: KsColors.secondaryContainer,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr(lang, 'appName'),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              Text(
                tr(lang, 'tagline'),
                style: const TextStyle(
                  fontSize: 13,
                  color: KsColors.primaryFixedDim,
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: KsColors.secondaryContainer,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
