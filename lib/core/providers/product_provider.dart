import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao/product_dao.dart';
import '../models/product.dart';

final productDaoProvider = Provider((ref) => ProductDao());

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(() {
      return ProductListNotifier();
    });

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  late ProductDao _dao;

  @override
  Future<List<Product>> build() async {
    _dao = ref.watch(productDaoProvider);
    return _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    return await _dao.getAllActiveProducts();
  }

  Future<void> searchProducts(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (query.trim().isEmpty) {
        return _fetchProducts();
      }
      return await _dao.searchProducts(query);
    });
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dao.insert(product);
      return _fetchProducts();
    });
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dao.update(product);
      return _fetchProducts();
    });
  }

  Future<void> deleteProduct(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dao.deleteSoft(id);
      return _fetchProducts();
    });
  }

  Future<void> restockProduct({
    required int productId,
    required int addedQuantity,
    required int stockBefore,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dao.restockProduct(
        productId: productId,
        addedQuantity: addedQuantity,
        stockBefore: stockBefore,
        note: note,
      );
      return _fetchProducts();
    });
  }
}
