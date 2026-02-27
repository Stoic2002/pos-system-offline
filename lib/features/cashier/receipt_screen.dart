import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/transaction.dart';
import '../../core/models/transaction_item.dart';
import '../../core/services/printer_service.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final TransactionModel transaction;
  final List<TransactionItem> items;
  final String storeName;

  const ReceiptScreen({
    super.key,
    required this.transaction,
    required this.items,
    required this.storeName,
  });

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();

  Future<void> _shareReceipt() async {
    try {
      RenderRepaintBoundary boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/KasirGo_Struk_${widget.transaction.invoiceNumber}.png',
      );
      await file.writeAsBytes(pngBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Struk KasirGo: ${widget.transaction.invoiceNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal share struk: \$e')));
      }
    }
  }

  Future<void> _printReceipt() async {
    final printerService = ref.read(printerServiceProvider);

    try {
      await printerService.printReceipt(
        storeName: widget.storeName,
        transaction: widget.transaction,
        items: widget.items,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mencetak struk...'),
            backgroundColor: PixelColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mencetak struk. Pastikan printer terhubung.'),
            backgroundColor: PixelColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STRUK TRANSAKSI'),
        automaticallyImplyLeading: false, // Must use button to close
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: RepaintBoundary(
                  key: _receiptKey,
                  child: Container(
                    width: 320, // Typical receipt width
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.storeName.toUpperCase(),
                          style: PixelTextStyles.amountBig.copyWith(
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat(
                            'dd MMM yyyy HH:mm',
                          ).format(widget.transaction.createdAt),
                          style: PixelTextStyles.body.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'No: ${widget.transaction.invoiceNumber}',
                          style: PixelTextStyles.body.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDashedLine(),
                        const SizedBox(height: 16),
                        ...widget.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: PixelTextStyles.body.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.quantity} x Rp ${item.productPrice.toInt()}',
                                      style: PixelTextStyles.body.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      'Rp ${item.subtotal.toInt()}',
                                      style: PixelTextStyles.body.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDashedLine(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL',
                              style: PixelTextStyles.body.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${widget.transaction.totalAmount.toInt()}',
                              style: PixelTextStyles.body.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TUNAI',
                              style: PixelTextStyles.body.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Rp ${widget.transaction.amountPaid.toInt()}',
                              style: PixelTextStyles.body.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'KEMBALI',
                              style: PixelTextStyles.body.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Rp ${widget.transaction.changeAmount.toInt()}',
                              style: PixelTextStyles.body.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDashedLine(),
                        const SizedBox(height: 16),
                        Text(
                          'TERIMA KASIH',
                          style: PixelTextStyles.body.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Powered by KasirGo',
                          style: PixelTextStyles.body.copyWith(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: PixelColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: PixelButton(
                    text: 'CETAK THERMAL',
                    color: PixelColors.primary,
                    borderColor: PixelColors.primaryDark,
                    textColor: Colors.black,
                    onPressed: _printReceipt,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PixelButton(
                    text: 'SHARE WA',
                    color: PixelColors.success,
                    borderColor: PixelColors.primaryDark,
                    onPressed: _shareReceipt,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PixelButton(
                    text: 'TUTUP',
                    color: PixelColors.surfaceVariant,
                    borderColor: PixelColors.border,
                    textColor: PixelColors.textPrimary,
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        150 ~/ 5,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.black54,
            height: 1,
          ),
        ),
      ),
    );
  }
}
