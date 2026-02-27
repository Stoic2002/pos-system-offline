import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../shared/utils/date_formatter.dart';
import '../../core/providers/report_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/pdf_service.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';

class ReportsScreen extends ConsumerWidget {
  final bool isStandalone;

  const ReportsScreen({super.key, this.isStandalone = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LAPORAN PENDAPATAN'),
        automaticallyImplyLeading: isStandalone,
      ),
      body: reportState.when(
        data: (data) {
          final entries = data.entries.toList();
          final maxY = data.values.isEmpty
              ? 10000.0
              : data.values.reduce((a, b) => a > b ? a : b) * 1.2;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('PENDAPATAN 7 HARI TERAKHIR', style: PixelTextStyles.body),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: PixelColors.surface,
                      border: Border.all(color: PixelColors.border, width: 2),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: BarChart(
                      BarChartData(
                        maxY: maxY == 0 ? 10000 : maxY,
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < entries.length) {
                                  final dateStr = entries[value.toInt()].key;
                                  final date = DateTime.parse(dateStr);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormatter.formatDate(date),
                                      style: PixelTextStyles.bodyMuted.copyWith(
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                if (value == maxY) return const SizedBox();
                                return Text(
                                  NumberFormat.compact().format(value),
                                  style: PixelTextStyles.bodyMuted.copyWith(
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxY > 0 ? maxY / 5 : 2000,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: PixelColors.border.withValues(alpha: 0.5),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        barGroups: List.generate(entries.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: entries[index].value,
                                color: PixelColors.primary,
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PixelButton(
                  text: 'EXPORT PDF',
                  color: PixelColors.success,
                  borderColor: PixelColors.primaryDark,
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuat PDF...')),
                      );
                      await ref
                          .read(pdfServiceProvider)
                          .exportReportPdf(
                            storeName: settings['store_name'] ?? 'KasirGo',
                            revenueData: data,
                          );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal membuat PDF: $e'),
                          backgroundColor: PixelColors.danger,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
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
