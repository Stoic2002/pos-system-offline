import '../../models/debt.dart';
import '../database_helper.dart';

class DebtDao {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> insertDebt(DebtModel debt) async {
    final db = await dbHelper.database;
    return await db.insert('debts', debt.toMap());
  }

  Future<List<DebtModel>> getAllDebts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return DebtModel.fromMap(maps[i]);
    });
  }

  Future<List<DebtModel>> getUnpaidDebts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'status != ?',
      whereArgs: ['paid'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return DebtModel.fromMap(maps[i]);
    });
  }

  Future<int> payDebt(int id, double amount) async {
    final db = await dbHelper.database;
    final debtMaps = await db.query('debts', where: 'id = ?', whereArgs: [id]);
    if (debtMaps.isNotEmpty) {
      final debt = DebtModel.fromMap(debtMaps.first);
      final newAmountPaid = debt.amountPaid + amount;

      String newStatus = 'partial';
      if (newAmountPaid >= debt.totalDebt) {
        newStatus = 'paid';
      }

      final updatedDebt = debt.copyWith(
        amountPaid: newAmountPaid,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      return await db.update(
        'debts',
        updatedDebt.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }
}
