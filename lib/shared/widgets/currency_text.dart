import 'package:flutter/material.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../core/theme/pixel_text_styles.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const CurrencyText(this.amount, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(amount),
      style: style ?? PixelTextStyles.body,
    );
  }
}
