import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/history_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/currency_text.dart';
import '../../shared/utils/date_formatter.dart';
import '../../shared/widgets/pixel_empty_state.dart';
import 'transaction_detail_screen.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(transactionHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('RIWAYAT TRANSAKSI')),
      body: historyState.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const PixelEmptyState(
              icon: Icons.receipt_long,
              title: 'BELUM ADA TRANSAKSI',
              subtitle: 'Penjualan yang sukses akan muncul di sini.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(
              color: PixelColors.border,
              height: 16,
              thickness: 2,
            ),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tx.invoiceNumber, style: PixelTextStyles.body),
                    subtitle: Text(
                      DateFormatter.formatDateTime(tx.createdAt),
                      style: PixelTextStyles.bodyMuted,
                    ),
                    trailing: CurrencyText(
                      tx.totalAmount,
                      style: PixelTextStyles.body.copyWith(
                        color: PixelColors.primaryLight,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionDetailScreen(transaction: tx),
                        ),
                      );
                    },
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
