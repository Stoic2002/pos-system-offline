import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/stock_log.dart';
import '../../core/providers/stock_log_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/utils/date_formatter.dart';
import '../../shared/widgets/pixel_empty_state.dart';

class StockLogScreen extends ConsumerWidget {
  final int productId;
  final String productName;

  const StockLogScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(productStockLogsProvider(productId));

    return Scaffold(
      backgroundColor: PixelColors.background,
      appBar: AppBar(
        title: Text(
          'RIWAYAT STOK: ${productName.toUpperCase()}',
          style: PixelTextStyles.header,
        ),
        backgroundColor: PixelColors.primary,
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            if (logs.isEmpty) {
              return const PixelEmptyState(
                icon: Icons.history_toggle_off,
                title: 'BELUM ADA RIWAYAT STOK',
              );
            }
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogCard(log)
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
          child: Text(
            'GAGAL MEMUAT DATA',
            style: PixelTextStyles.bodyMuted.copyWith(
              color: PixelColors.danger,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard(StockLogModel log) {
    IconData iconData;
    Color iconColor;
    String typeText;

    switch (log.type) {
      case 'IN':
        iconData = Icons.arrow_downward;
        iconColor = PixelColors.success;
        typeText = 'STOK MASUK';
        break;
      case 'OUT':
        iconData = Icons.arrow_upward;
        iconColor = PixelColors.warning;
        typeText = 'STOK KELUAR';
        break;
      case 'ADJUST':
        iconData = Icons.sync_alt;
        iconColor = PixelColors.accentBlue;
        typeText = 'PENYESUAIAN';
        break;
      default:
        iconData = Icons.info_outline;
        iconColor = PixelColors.textMuted;
        typeText = log.type;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: PixelColors.surface,
        border: Border.all(color: PixelColors.border, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PixelColors.surfaceVariant,
            border: Border.all(color: iconColor, width: 2),
          ),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          typeText,
          style: PixelTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(log.createdAt),
              style: PixelTextStyles.bodySmall,
            ),
            if (log.note != null && log.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Catatan: ${log.note}',
                style: PixelTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${log.quantityChange > 0 ? '+' : ''}${log.quantityChange}',
              style: PixelTextStyles.amountSmall.copyWith(
                color: log.quantityChange >= 0
                    ? PixelColors.success
                    : PixelColors.danger,
              ),
            ),
            Text(
              '${log.stockBefore} → ${log.stockAfter}',
              style: PixelTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
