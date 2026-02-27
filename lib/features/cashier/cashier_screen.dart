import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/cart_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_card.dart';
import '../../shared/widgets/currency_text.dart';
import 'cart_widget.dart';
import '../../shared/widgets/pixel_empty_state.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('KASIR')),
      // drawer: const MainDrawer(), // Replaced by BottomNavigationBar
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: PixelColors.textMuted,
                ),
                filled: true,
                fillColor: PixelColors.surfaceVariant,
                contentPadding: const EdgeInsets.all(12),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: PixelColors.border, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: PixelColors.primary, width: 2),
                ),
              ),
              style: PixelTextStyles.body,
              onChanged: (value) {
                ref.read(productListProvider.notifier).searchProducts(value);
              },
            ),
          ),
          Expanded(
            child: productsState.when(
              data: (products) {
                if (products.isEmpty) {
                  return const PixelEmptyState(
                    icon: Icons.search_off,
                    title: 'PRODUK TIDAK DITEMUKAN',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return PixelCard(
                          padding: EdgeInsets.zero,
                          onTap: () {
                            // TODO: add to cart
                            if (product.stock > 0) {
                              ref
                                  .read(cartProvider.notifier)
                                  .addProduct(product);
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  color: PixelColors.surfaceVariant,
                                  child: product.imagePath != null
                                      ? Image.network(
                                          product.imagePath!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.inventory_2,
                                          size: 48,
                                          color: PixelColors.textMuted,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: PixelTextStyles.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    CurrencyText(
                                      product.price,
                                      style: PixelTextStyles.body.copyWith(
                                        color: PixelColors.primaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            product.stock >
                                                product.lowStockAlert
                                            ? PixelColors.success.withValues(
                                                alpha: 0.2,
                                              )
                                            : product.stock > 0
                                            ? PixelColors.warning.withValues(
                                                alpha: 0.2,
                                              )
                                            : PixelColors.danger.withValues(
                                                alpha: 0.2,
                                              ),
                                        border: Border.all(
                                          color:
                                              product.stock >
                                                  product.lowStockAlert
                                              ? PixelColors.success
                                              : product.stock > 0
                                              ? PixelColors.warning
                                              : PixelColors.danger,
                                        ),
                                      ),
                                      child: Text(
                                        'Stok: ${product.stock}',
                                        style: PixelTextStyles.body.copyWith(
                                          fontSize: 14,
                                          color:
                                              product.stock >
                                                  product.lowStockAlert
                                              ? PixelColors.success
                                              : product.stock > 0
                                              ? PixelColors.warning
                                              : PixelColors.danger,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fade(duration: 400.ms, delay: (index * 50).ms)
                        .scaleXY(begin: 0.9, end: 1, duration: 400.ms);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: PixelColors.primary),
              ),
              error: (err, stack) => Center(
                child: Text('Error: \$err', style: PixelTextStyles.bodyMuted),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: const CartWidget(),
    );
  }
}
