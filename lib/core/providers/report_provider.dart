import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'history_provider.dart';

final reportProvider = FutureProvider<Map<String, double>>((ref) async {
  final dao = ref.watch(transactionDaoProvider);
  final transactions = await dao.getAllTransactions();

  // Group by Date String "yyyy-MM-dd"
  final Map<String, double> dailyRevenue = {};

  // Initialize last 7 days with 0
  final now = DateTime.now();
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    dailyRevenue[dateStr] = 0.0;
  }

  for (var tx in transactions) {
    final dateStr = DateFormat('yyyy-MM-dd').format(tx.createdAt);
    if (dailyRevenue.containsKey(dateStr)) {
      dailyRevenue[dateStr] = dailyRevenue[dateStr]! + tx.totalAmount;
    }
  }

  return dailyRevenue;
});
