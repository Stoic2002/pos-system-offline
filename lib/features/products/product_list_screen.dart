import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../core/providers/product_provider.dart';
import '../../shared/widgets/currency_text.dart';
import 'product_form_screen.dart';
import '../inventory/restock_dialog.dart';
import '../inventory/stock_log_screen.dart';
import '../../shared/widgets/pixel_empty_state.dart';

class ProductListScreen extends ConsumerWidget {
  final bool isStandalone;

  const ProductListScreen({super.key, this.isStandalone = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KELOLA PRODUK'),
        automaticallyImplyLeading: isStandalone,
      ),
      body: productsState.when(
        data: (products) {
          if (products.isEmpty) {
            return const PixelEmptyState(
              icon: Icons.inventory_2,
              title: 'BELUM ADA PRODUK',
              subtitle:
                  'Tekan tombol + untuk menambah\nproduk baru ke katalog jualan.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16).copyWith(bottom: 80),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(
              color: PixelColors.border,
              height: 16,
              thickness: 2,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: PixelColors.surfaceVariant,
                      child: product.imagePath != null
                          ? Image.network(product.imagePath!, fit: BoxFit.cover)
                          : const Icon(
                              Icons.image,
                              color: PixelColors.textMuted,
                            ),
                    ),
                    title: Text(product.name, style: PixelTextStyles.body),
                    subtitle: CurrencyText(
                      product.price,
                      style: PixelTextStyles.bodyMuted,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.history,
                            color: PixelColors.accentBlue,
                          ),
                          tooltip: 'Riwayat Stok',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockLogScreen(
                                  productId: product.id!,
                                  productName: product.name,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_box,
                            color: PixelColors.success,
                          ),
                          tooltip: 'Tambah Stok',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  RestockDialog(product: product),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: PixelColors.primary,
                          ),
                          tooltip: 'Edit Produk',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductFormScreen(product: product),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fade(duration: 300.ms, delay: (index * 30).ms)
                  .slideX(begin: 0.2, end: 0, duration: 300.ms);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: PixelColors.primary),
        ),
        error: (err, stack) => Center(child: Text('Error: \$err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
