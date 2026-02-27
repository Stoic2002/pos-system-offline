import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';
import '../../shared/widgets/main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage(
                    icon: Icons.storefront,
                    title: 'KASIRGO',
                    subtitle:
                        'Kasir Pixel, Cuan Real.\nAplikasi POS simple untuk UMKM.',
                  ),
                  _buildPage(
                    icon: Icons.offline_bolt,
                    title: 'OFFLINE FIRST',
                    subtitle:
                        'Tanpa internet! Data aman di HP Anda.\nBayar sekali, pakai selamanya.',
                  ),
                  _buildPage(
                    icon: Icons.rocket_launch,
                    title: 'MULAI SEKARANG',
                    subtitle:
                        'Catat penjualan, kelola produk, dan tagih kasbon semudah main game.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicator
                  Row(
                    children: List.generate(
                      3,
                      (index) =>
                          Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? PixelColors.primary
                                      : PixelColors.surfaceVariant,
                                  border: Border.all(
                                    color: PixelColors.border,
                                    width: 2,
                                  ),
                                ),
                              )
                              .animate(target: _currentPage == index ? 1 : 0)
                              .scaleXY(begin: 1, end: 1.2, duration: 200.ms),
                    ),
                  ),
                  PixelButton(
                    text: _currentPage == 2 ? 'MULAI' : 'LANJUT',
                    color: PixelColors.success,
                    borderColor: PixelColors.primaryDark,
                    textColor: Colors.black,
                    fullWidth: false,
                    onPressed: _nextPage,
                  ).animate().fade().slideX(begin: 0.5, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PixelColors.surface,
              border: Border.all(color: PixelColors.primary, width: 4),
            ),
            child: Icon(icon, size: 100, color: PixelColors.primaryLight),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 48),
          Text(
                title,
                style: PixelTextStyles.header.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              )
              .animate()
              .fade(delay: 200.ms)
              .slideY(begin: 0.5, end: 0, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
                subtitle,
                style: PixelTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              )
              .animate()
              .fade(delay: 400.ms)
              .slideY(begin: 0.5, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
}
