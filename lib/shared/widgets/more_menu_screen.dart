import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../features/history/transaction_history_screen.dart';
import '../../features/debts/debt_list_screen.dart';
import '../../features/settings/printer_settings_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/backup_screen.dart';

class MoreMenuScreen extends ConsumerWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('LAINNYA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'RIWAYAT TRANSAKSI',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.money_off,
            title: 'PIUTANG (KASBON)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebtListScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.print,
            title: 'PRINTER BLUETOOTH',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrinterSettingsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'PENGATURAN TOKO',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.backup,
            title: 'BACKUP / RESTORE',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: PixelColors.surface,
        border: Border.all(color: PixelColors.border, width: 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: PixelColors.primary),
        title: Text(title, style: PixelTextStyles.body),
        trailing: const Icon(Icons.chevron_right, color: PixelColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
