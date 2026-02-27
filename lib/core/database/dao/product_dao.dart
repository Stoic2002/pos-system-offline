import '../database_helper.dart';
import '../../models/product.dart';

class ProductDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Product product) async {
    final db = await dbHelper.database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllActiveProducts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? AND is_active = ?',
      whereArgs: ['%$query%', 1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> update(Product product) async {
    final db = await dbHelper.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteSoft(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      'products',
      {'is_active': 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateStock(int productId, int quantityDifference) async {
    final db = await dbHelper.database;
    await db.rawUpdate('UPDATE products SET stock = stock + ? WHERE id = ?', [
      quantityDifference,
      productId,
    ]);
  }

  Future<void> restockProduct({
    required int productId,
    required int addedQuantity,
    required int stockBefore,
    String? note,
  }) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      // 1. Update stock
      await txn.rawUpdate(
        'UPDATE products SET stock = stock + ? WHERE id = ?',
        [addedQuantity, productId],
      );

      // 2. Insert log
      final stockAfter = stockBefore + addedQuantity;
      await txn.insert('stock_logs', {
        'product_id': productId,
        'type': 'IN',
        'quantity_change': addedQuantity,
        'stock_before': stockBefore,
        'stock_after': stockAfter,
        'note': note ?? 'Restock',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }
}
