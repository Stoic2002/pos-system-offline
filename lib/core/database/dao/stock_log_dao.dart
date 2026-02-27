import '../database_helper.dart';
import '../../models/stock_log.dart';

class StockLogDao {
  Future<void> insertStockLog(StockLogModel log) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('stock_logs', log.toMap());
  }

  Future<List<StockLogModel>> getStockLogsForProduct(int productId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_logs',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => StockLogModel.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getRecentLogs({int limit = 50}) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT sl.*, p.name as product_name
      FROM stock_logs sl
      JOIN products p ON sl.product_id = p.id
      ORDER BY sl.created_at DESC
      LIMIT ?
    ''',
      [limit],
    );
    return maps;
  }
}
