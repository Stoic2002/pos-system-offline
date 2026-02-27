import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';

class RestockDialog extends ConsumerStatefulWidget {
  final Product product;

  const RestockDialog({super.key, required this.product});

  @override
  ConsumerState<RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends ConsumerState<RestockDialog> {
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah harus lebih dari 0',
            style: PixelTextStyles.body,
          ),
          backgroundColor: PixelColors.danger,
        ),
      );
      return;
    }

    await ref
        .read(productListProvider.notifier)
        .restockProduct(
          productId: widget.product.id!,
          addedQuantity: quantity,
          stockBefore: widget.product.stock,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PixelColors.surface,
      shape: const BeveledRectangleBorder(),
      title: Text('TAMBAH STOK', style: PixelTextStyles.header),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: ${widget.product.name}', style: PixelTextStyles.body),
            Text(
              'Stok Saat Ini: ${widget.product.stock}',
              style: PixelTextStyles.bodyMuted,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: PixelTextStyles.body,
              decoration: const InputDecoration(
                labelText: 'JUMLAH DITAMBAHKAN',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PixelColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              style: PixelTextStyles.body,
              decoration: const InputDecoration(
                labelText: 'CATATAN (opsional)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PixelColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('BATAL', style: PixelTextStyles.bodyMuted),
        ),
        PixelButton(
          text: 'SIMPAN',
          color: PixelColors.primary,
          borderColor: PixelColors.primaryDark,
          onPressed: _submit,
        ),
      ],
    );
  }
}
