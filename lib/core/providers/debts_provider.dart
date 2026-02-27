import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/dao/debt_dao.dart';
import '../models/debt.dart';

final debtDaoProvider = Provider((ref) => DebtDao());

final debtsProvider = AsyncNotifierProvider<DebtsNotifier, List<DebtModel>>(() {
  return DebtsNotifier();
});

class DebtsNotifier extends AsyncNotifier<List<DebtModel>> {
  @override
  FutureOr<List<DebtModel>> build() async {
    return _fetchUnpaid();
  }

  Future<List<DebtModel>> _fetchUnpaid() async {
    final dao = ref.watch(debtDaoProvider);
    return dao.getUnpaidDebts();
  }

  Future<List<DebtModel>> _fetchAll() async {
    final dao = ref.watch(debtDaoProvider);
    return dao.getAllDebts();
  }

  Future<void> loadDebts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAll());
  }

  Future<void> filterUnpaid() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUnpaid());
  }

  Future<void> payDebt(int id, double amount) async {
    final dao = ref.watch(debtDaoProvider);
    await dao.payDebt(id, amount);
    filterUnpaid();
  }
}
