import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../../core/services/printer_service.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final printerService = ref.read(printerServiceProvider);
    final devices = await printerService.getPairedDevices();
    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _isLoading = true);
    final printerService = ref.read(printerServiceProvider);
    final success = await printerService.connect(device);
    setState(() {
      _isLoading = false;
      if (success) {
        _connectedDevice = device;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Terhubung ke \${device.name}' : 'Gagal menghubungkan!',
          ),
          backgroundColor: success ? PixelColors.success : PixelColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENGATURAN PRINTER'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDevices),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: PixelColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('PRINTER BLUETOOTH', style: PixelTextStyles.header),
                const SizedBox(height: 8),
                Text(
                  'Pastikan printer sudah di-pairing via pengaturan Bluetooth HP.',
                  style: PixelTextStyles.bodyMuted,
                ),
                const SizedBox(height: 24),
                if (_devices.isEmpty)
                  Text(
                    'Tidak ada perangkat terdeteksi.',
                    style: PixelTextStyles.body,
                  )
                else
                  ..._devices.map((device) {
                    final isConnected =
                        _connectedDevice?.address == device.address;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: PixelColors.surface,
                        border: Border.all(
                          color: isConnected
                              ? PixelColors.success
                              : PixelColors.border,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.print,
                          color: isConnected
                              ? PixelColors.success
                              : PixelColors.textMuted,
                        ),
                        title: Text(
                          device.name ?? 'Unknown',
                          style: PixelTextStyles.body,
                        ),
                        subtitle: Text(
                          device.address ?? '',
                          style: PixelTextStyles.bodyMuted,
                        ),
                        trailing: isConnected
                            ? ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(printerServiceProvider)
                                      .testPrint();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PixelColors.primary,
                                  foregroundColor: Colors.black,
                                ),
                                child: Text(
                                  'TEST',
                                  style: PixelTextStyles.body,
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () => _connect(device),
                                child: Text(
                                  'SAMBUNG',
                                  style: PixelTextStyles.body,
                                ),
                              ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
