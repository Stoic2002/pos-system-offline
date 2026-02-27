import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/utils/date_formatter.dart';
import '../../core/providers/debts_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_empty_state.dart';
import 'debt_detail_screen.dart';

class DebtListScreen extends ConsumerStatefulWidget {
  const DebtListScreen({super.key});

  @override
  ConsumerState<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends ConsumerState<DebtListScreen> {
  bool _showUnpaidOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (_showUnpaidOnly) {
      ref.read(debtsProvider.notifier).filterUnpaid();
    } else {
      ref.read(debtsProvider.notifier).loadDebts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final debtState = ref.watch(debtsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PIUTANG (KASBON)'),
        actions: [
          IconButton(
            icon: Icon(
              _showUnpaidOnly ? Icons.filter_list : Icons.filter_list_off,
            ),
            onPressed: () {
              setState(() {
                _showUnpaidOnly = !_showUnpaidOnly;
              });
              _loadData();
            },
            tooltip: _showUnpaidOnly ? 'Tampilkan Semua' : 'Hanya Belum Lunas',
          ),
        ],
      ),
      body: debtState.when(
        data: (debts) {
          if (debts.isEmpty) {
            return const PixelEmptyState(
              icon: Icons.money_off,
              title: 'KASBON KOSONG',
              subtitle: 'Wah hebat! Tidak ada catatan kasbon saat ini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              final isPaid = debt.status == 'paid';
              final remaining = debt.totalDebt - debt.amountPaid;

              return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: PixelColors.surface,
                      border: Border.all(color: PixelColors.border, width: 2),
                    ),
                    child: ListTile(
                      title: Text(
                        debt.customerName,
                        style: PixelTextStyles.body,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal: ${DateFormatter.formatDate(debt.createdAt)}',
                            style: PixelTextStyles.bodyMuted.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Status: ${debt.status.toUpperCase()}',
                            style: TextStyle(
                              color: isPaid
                                  ? PixelColors.success
                                  : (debt.status == 'partial'
                                        ? Colors.orange
                                        : PixelColors.danger),
                              fontFamily: 'VT323',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total: Rp ${debt.totalDebt.toInt()}',
                            style: PixelTextStyles.bodyMuted.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          if (!isPaid)
                            Text(
                              'Sisa: Rp ${remaining.toInt()}',
                              style: PixelTextStyles.body.copyWith(
                                color: PixelColors.danger,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DebtDetailScreen(debt: debt),
                          ),
                        );
                      },
                    ),
                  )
                  .animate()
                  .fade(duration: 300.ms, delay: (index * 30).ms)
                  .slideX(begin: 0.2, end: 0, duration: 300.ms);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: PixelColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Error: \$err', style: PixelTextStyles.bodyMuted),
        ),
      ),
    );
  }
}
