import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';
import '../../shared/widgets/currency_text.dart';
import 'payment_sheet.dart';

class CartDetailSheet extends ConsumerWidget {
  const CartDetailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).totalAmount;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: PixelColors.background,
        border: Border(top: BorderSide(color: PixelColors.primary, width: 3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: PixelColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KERANJANG BELANJA', style: PixelTextStyles.header),
                IconButton(
                  icon: const Icon(Icons.close, color: PixelColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          if (cartItems.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Keranjang kosong',
                  style: PixelTextStyles.bodyMuted,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length,
                separatorBuilder: (context, index) => const Divider(
                  color: PixelColors.border,
                  height: 16,
                  thickness: 2,
                ),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: PixelTextStyles.body,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            CurrencyText(
                              item.product.price,
                              style: PixelTextStyles.bodyMuted,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: PixelColors.surfaceVariant,
                          border: Border.all(
                            color: PixelColors.border,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .decrementProduct(item.product);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.remove, size: 20),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              color: PixelColors.surface,
                              child: Center(
                                child: Text(
                                  '${item.quantity}',
                                  style: PixelTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (item.quantity < item.product.stock) {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addProduct(item.product);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Stok habis!',
                                        style: PixelTextStyles.body,
                                      ),
                                      backgroundColor: PixelColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.add, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CurrencyText(
                            item.subtotal,
                            style: PixelTextStyles.body.copyWith(
                              color: PixelColors.primaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: PixelColors.surface,
                border: Border(
                  top: BorderSide(color: PixelColors.border, width: 2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: PixelTextStyles.bodyMuted),
                      CurrencyText(total, style: PixelTextStyles.amountBig),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PixelButton(
                    text: 'LANJUT PEMBAYARAN',
                    color: PixelColors.success,
                    borderColor: PixelColors.primaryDark,
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.pop(context); // Close CartSheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: PixelColors.surface,
                        builder: (context) => const PaymentSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
