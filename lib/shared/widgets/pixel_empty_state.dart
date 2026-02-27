import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';

class PixelEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const PixelEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PixelColors.surfaceVariant,
                  border: Border.all(color: PixelColors.border, width: 2),
                ),
                child: Icon(icon, size: 64, color: PixelColors.textMuted),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -5,
                end: 5,
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 24),
          Text(
                title,
                style: PixelTextStyles.sectionHeader.copyWith(
                  color: PixelColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fade(duration: 500.ms)
              .slideY(begin: 0.5, end: 0, duration: 500.ms),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
                  subtitle!,
                  style: PixelTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                )
                .animate()
                .fade(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.5, end: 0, duration: 500.ms),
          ],
        ],
      ),
    );
  }
}
