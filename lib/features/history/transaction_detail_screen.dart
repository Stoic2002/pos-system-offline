import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/transaction.dart';
import '../../core/models/transaction_item.dart';
import '../../core/providers/history_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';
import '../../shared/widgets/currency_text.dart';
import '../../shared/utils/date_formatter.dart';
import '../cashier/receipt_screen.dart';

final transactionItemsProvider =
    FutureProvider.family<List<TransactionItem>, int>((
      ref,
      transactionId,
    ) async {
      final dao = ref.watch(transactionDaoProvider);
      return await dao.getTransactionItems(transactionId);
    });

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsState = ref.watch(transactionItemsProvider(transaction.id!));
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('DETAIL TRANSAKSI')),
      body: itemsState.when(
        data: (items) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'INVOICE: ${transaction.invoiceNumber}',
                      style: PixelTextStyles.body,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TANGGAL: ${DateFormatter.formatDateTime(transaction.createdAt)}',
                      style: PixelTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: PixelColors.border, thickness: 2),
                    const SizedBox(height: 16),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: PixelTextStyles.body,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} x Rp ${item.productPrice.toInt()}',
                                    style: PixelTextStyles.bodyMuted,
                                  ),
                                ],
                              ),
                            ),
                            CurrencyText(
                              item.subtotal,
                              style: PixelTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: PixelColors.border, thickness: 2),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL', style: PixelTextStyles.body),
                        CurrencyText(
                          transaction.totalAmount,
                          style: PixelTextStyles.body.copyWith(
                            color: PixelColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TUNAI', style: PixelTextStyles.bodyMuted),
                        CurrencyText(
                          transaction.amountPaid,
                          style: PixelTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('KEMBALI', style: PixelTextStyles.bodyMuted),
                        CurrencyText(
                          transaction.changeAmount,
                          style: PixelTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: PixelColors.surface,
                child: PixelButton(
                  text: 'TAMPILKAN STRUK',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptScreen(
                          transaction: transaction,
                          items: items,
                          storeName: settings['store_name'] ?? 'KasirGo',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: PixelColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: PixelTextStyles.bodyMuted),
        ),
      ),
    );
  }
}
