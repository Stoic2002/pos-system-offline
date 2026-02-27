import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();

  Map<String, String>? _initialSettings;

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  void _loadValues(Map<String, String> currentSettings) {
    if (_initialSettings == null || _initialSettings != currentSettings) {
      _initialSettings = currentSettings;
      _storeNameController.text = currentSettings['store_name'] ?? '';
      _storeAddressController.text = currentSettings['store_address'] ?? '';
      _storePhoneController.text = currentSettings['store_phone'] ?? '';
    }
  }

  void _saveSettings() async {
    final notifier = ref.read(settingsProvider.notifier);

    await notifier.saveSetting('store_name', _storeNameController.text.trim());
    await notifier.saveSetting(
      'store_address',
      _storeAddressController.text.trim(),
    );
    await notifier.saveSetting(
      'store_phone',
      _storePhoneController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengaturan berhasil disimpan',
            style: PixelTextStyles.body,
          ),
          backgroundColor: PixelColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSettings = ref.watch(settingsProvider);
    _loadValues(currentSettings);

    return Scaffold(
      backgroundColor: PixelColors.background,
      appBar: AppBar(
        title: Text('PENGATURAN TOKO', style: PixelTextStyles.header),
        backgroundColor: PixelColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PixelColors.surface,
                border: Border.all(color: PixelColors.border, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INFORMASI TOKO', style: PixelTextStyles.sectionHeader),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _storeNameController,
                    style: PixelTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'NAMA TOKO',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: PixelColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _storeAddressController,
                    maxLines: 3,
                    style: PixelTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'ALAMAT TOKO',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: PixelColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _storePhoneController,
                    keyboardType: TextInputType.phone,
                    style: PixelTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'NOMOR TELEPON (opsional)',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: PixelColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            PixelButton(
              text: 'SIMPAN PENGATURAN',
              color: PixelColors.success,
              borderColor: PixelColors.primaryDark,
              textColor: Colors.black,
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }
}
