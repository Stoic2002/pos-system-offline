import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../shared/widgets/pixel_button.dart';
import '../../shared/widgets/pixel_text_field.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toInt().toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      // Ignore imagePath and category for now in MVP Phase 1 simplicity
    );

    if (widget.product == null) {
      ref.read(productListProvider.notifier).addProduct(product);
    } else {
      ref.read(productListProvider.notifier).updateProduct(product);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'TAMBAH PRODUK' : 'EDIT PRODUK'),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Icons.delete, color: PixelColors.danger),
              onPressed: () {
                ref
                    .read(productListProvider.notifier)
                    .deleteProduct(widget.product!.id!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PixelTextField(
              label: 'NAMA PRODUK',
              hint: 'Contoh: Nasi Goreng',
              controller: _nameController,
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            PixelTextField(
              label: 'HARGA JUAL',
              hint: 'Contoh: 15000',
              controller: _priceController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (double.tryParse(v) == null) return 'Harus angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            PixelTextField(
              label: 'STOK AWAL',
              hint: 'Contoh: 10',
              controller: _stockController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (int.tryParse(v) == null) return 'Harus angka';
                return null;
              },
            ),
            const SizedBox(height: 32),
            PixelButton(text: 'SIMPAN PRODUK', onPressed: _saveProduct),
          ],
        ),
      ),
    );
  }
}
