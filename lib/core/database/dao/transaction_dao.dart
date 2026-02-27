import '../database_helper.dart';
import '../../models/transaction.dart';
import '../../models/transaction_item.dart';
import '../../models/cart_item.dart';

class TransactionDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> createTransaction(
    TransactionModel transaction,
    List<CartItem> cartItems,
  ) async {
    final db = await dbHelper.database;

    int transactionId = 0;

    await db.transaction((txn) async {
      // 1. Insert Request
      transactionId = await txn.insert('transactions', transaction.toMap());

      // 2. Insert Items and update stock
      for (final cartItem in cartItems) {
        final txItem = TransactionItem(
          transactionId: transactionId,
          productId: cartItem.product.id!,
          productName: cartItem.product.name,
          productPrice: cartItem.product.price,
          quantity: cartItem.quantity,
          subtotal: cartItem.subtotal,
        );

        await txn.insert('transaction_items', txItem.toMap());

        // Decrement stock
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [cartItem.quantity, cartItem.product.id],
        );

        // Optional log stock
        await txn.insert('stock_logs', {
          'product_id': cartItem.product.id,
          'type': 'sale',
          'quantity_change': -cartItem.quantity,
          'stock_before': cartItem.product.stock,
          'stock_after': cartItem.product.stock - cartItem.quantity,
          'note': 'Penjualan inv: ${transaction.invoiceNumber}',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });

    return transactionId;
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await dbHelper.database;
    final maps = await db.query('transactions', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
    return List.generate(maps.length, (i) => TransactionItem.fromMap(maps[i]));
  }
}
