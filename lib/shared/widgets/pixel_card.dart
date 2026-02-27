import 'package:flutter/material.dart';
import '../../core/theme/pixel_colors.dart';

class PixelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  const PixelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = PixelColors.surface,
    this.borderColor = PixelColors.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 2),
        // No border radius for Pixel Art feel
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
