import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;

  Future<void> _exportDatabase() async {
    setState(() => _isLoading = true);
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'kasirgo.db');
      final file = File(path);

      if (await file.exists()) {
        final xFile = XFile(path);
        // ignore: deprecated_member_use
        final _ = await Share.shareXFiles([
          xFile,
        ], text: 'Backup Database KasirGo');
      } else {
        throw Exception('Database file not found.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal export database: \$e',
              style: PixelTextStyles.body,
            ),
            backgroundColor: PixelColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importDatabase() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // .db files
      );

      if (result != null && result.files.single.path != null) {
        final sourcePath = result.files.single.path!;

        // Ensure it's a KasirGo sqlite DB (basic superficial check)
        if (!sourcePath.endsWith('.db')) {
          throw Exception('Harap pilih file backup berformat .db');
        }

        final dbPath = await getDatabasesPath();
        final path = p.join(dbPath, 'kasirgo.db');

        // Copy new database over the old one
        final newDbBytes = await File(sourcePath).readAsBytes();
        await File(path).writeAsBytes(newDbBytes, flush: true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Database berhasil di-restore! Ganti layar agar efek sinkronisasi berjalan.',
                style: PixelTextStyles.body,
              ),
              backgroundColor: PixelColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal restore database: \$e',
              style: PixelTextStyles.body,
            ),
            backgroundColor: PixelColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.background,
      appBar: AppBar(
        title: Text('BACKUP & RESTORE', style: PixelTextStyles.header),
        backgroundColor: PixelColors.primary,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_sync,
                  size: 80,
                  color: PixelColors.primaryLight,
                ),
                const SizedBox(height: 32),
                Text(
                  'Backup data toko Anda (Produk, Laporan, Kasbon) agar tidak hilang saat berganti perangkat.',
                  style: PixelTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                PixelButton(
                  text: 'EXPORT DATABASE (.db)',
                  color: PixelColors.success,
                  borderColor: PixelColors.primaryDark,
                  textColor: Colors.black,
                  onPressed: _isLoading ? null : _exportDatabase,
                ),
                const SizedBox(height: 24),
                PixelButton(
                  text: 'RESTORE DATABASE (.db)',
                  color: PixelColors.warning,
                  borderColor: PixelColors.border,
                  textColor: Colors.black,
                  onPressed: _isLoading ? null : _importDatabase,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: PixelColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
