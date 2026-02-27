import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao/transaction_dao.dart';
import '../models/transaction.dart';

final transactionDaoProvider = Provider((ref) => TransactionDao());

final transactionHistoryProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  final dao = ref.watch(transactionDaoProvider);
  return await dao.getAllTransactions();
});
