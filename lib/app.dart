import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/pixel_theme.dart';
import 'core/providers/settings_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'shared/widgets/main_navigation_screen.dart';

class KasirGoApp extends ConsumerWidget {
  final bool isFirstTime;

  const KasirGoApp({super.key, this.isFirstTime = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optionally watch settings just to initialize it early
    ref.watch(settingsProvider);

    return MaterialApp(
      title: 'KasirGo',
      theme: PixelTheme.theme,
      debugShowCheckedModeBanner: false,
      home: isFirstTime
          ? const OnboardingScreen()
          : const MainNavigationScreen(),
    );
  }
}
