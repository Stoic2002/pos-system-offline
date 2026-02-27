import 'package:flutter/material.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final bool fullWidth;

  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = PixelColors.primary,
    this.borderColor = PixelColors.primaryDark,
    this.textColor = Colors.black,
    this.fullWidth = true,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? PixelColors.surfaceVariant
              : widget.color,
          border: Border.all(
            color: widget.onPressed == null
                ? PixelColors.border
                : widget.borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              offset: _isPressed ? const Offset(1, 1) : const Offset(3, 3),
              color: widget.onPressed == null
                  ? Colors.transparent
                  : Colors.black,
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: PixelTextStyles.buttonText.copyWith(
              color: widget.onPressed == null
                  ? PixelColors.textMuted
                  : widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
