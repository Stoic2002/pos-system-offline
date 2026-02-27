import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao/stock_log_dao.dart';
import '../models/stock_log.dart';

final stockLogDaoProvider = Provider((ref) => StockLogDao());

final recentStockLogsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final dao = ref.watch(stockLogDaoProvider);
  return await dao.getRecentLogs();
});

final productStockLogsProvider =
    FutureProvider.family<List<StockLogModel>, int>((ref, productId) async {
      final dao = ref.watch(stockLogDaoProvider);
      return await dao.getStockLogsForProduct(productId);
    });
