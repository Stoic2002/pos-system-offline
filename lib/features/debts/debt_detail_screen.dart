import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/debt.dart';
import '../../core/providers/debts_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';
import '../../shared/widgets/currency_text.dart';
import '../../shared/utils/date_formatter.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final DebtModel debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen> {
  final _paymentController = TextEditingController();

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  void _processPayment() {
    final amount = double.tryParse(_paymentController.text) ?? 0;
    final remaining = widget.debt.totalDebt - widget.debt.amountPaid;

    if (amount <= 0 || amount > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah pembayaran tidak valid',
            style: PixelTextStyles.body,
          ),
          backgroundColor: PixelColors.danger,
        ),
      );
      return;
    }

    ref.read(debtsProvider.notifier).payDebt(widget.debt.id!, amount);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pembayaran kasbon berhasil dicatat',
          style: PixelTextStyles.body,
        ),
        backgroundColor: PixelColors.success,
      ),
    );
  }

  void _sendWhatsAppReminder() async {
    final remaining = widget.debt.totalDebt - widget.debt.amountPaid;

    final message =
        '''
Halo ${widget.debt.customerName},
Mengingatkan kembali terkait tagihan kasbon di kasirgo.
Total Tagihan: Rp ${widget.debt.totalDebt.toInt()}
Sisa Tagihan: Rp ${remaining.toInt()}

Mohon ketersediaannya untuk melakukan pembayaran. Terima kasih🙏.
'''
            .trim();

    final encodedMessage = Uri.encodeComponent(message);

    // As in standard WhatsApp WA.me link
    final Uri url = Uri.parse('https://wa.me/?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membuka WhatsApp',
              style: PixelTextStyles.body,
            ),
            backgroundColor: PixelColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates (e.g. if paid)
    final debtsList = ref.watch(debtsProvider);
    final optDebt = debtsList.whenData(
      (debts) => debts.where((d) => d.id == widget.debt.id).firstOrNull,
    );

    // Fallback to widget.debt if not found temporarily
    final currentDebt = optDebt.value ?? widget.debt;
    final isPaid = currentDebt.status == 'paid';
    final remaining = currentDebt.totalDebt - currentDebt.amountPaid;

    return Scaffold(
      backgroundColor: PixelColors.background,
      appBar: AppBar(
        title: Text('DETAIL KASBON', style: PixelTextStyles.header),
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
                  Text('PELANGGAN', style: PixelTextStyles.bodyMuted),
                  const SizedBox(height: 4),
                  Text(
                    currentDebt.customerName.toUpperCase(),
                    style: PixelTextStyles.amountBig,
                  ),
                  const Divider(
                    color: PixelColors.border,
                    height: 32,
                    thickness: 2,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TANGGAL', style: PixelTextStyles.bodyMuted),
                      Text(
                        DateFormatter.formatDate(currentDebt.createdAt),
                        style: PixelTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('STATUS', style: PixelTextStyles.bodyMuted),
                      Text(
                        currentDebt.status.toUpperCase(),
                        style: PixelTextStyles.body.copyWith(
                          color: isPaid
                              ? PixelColors.success
                              : (currentDebt.status == 'partial'
                                    ? PixelColors.warning
                                    : PixelColors.danger),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: PixelColors.border,
                    height: 32,
                    thickness: 2,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL BELANJA', style: PixelTextStyles.bodyMuted),
                      CurrencyText(
                        currentDebt.totalDebt,
                        style: PixelTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SUDAH DIBAYAR', style: PixelTextStyles.bodyMuted),
                      CurrencyText(
                        currentDebt.amountPaid,
                        style: PixelTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SISA PIUTANG',
                        style: PixelTextStyles.bodyMuted.copyWith(
                          color: PixelColors.danger,
                        ),
                      ),
                      CurrencyText(
                        remaining,
                        style: PixelTextStyles.amountBig.copyWith(
                          color: PixelColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (!isPaid) ...[
              Text('PEMBAYARAN KASBON', style: PixelTextStyles.sectionHeader),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PixelColors.surfaceVariant,
                  border: Border.all(color: PixelColors.border, width: 2),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _paymentController,
                      keyboardType: TextInputType.number,
                      style: PixelTextStyles.body,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Pembayaran',
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
                    SizedBox(
                      width: double.infinity,
                      child: PixelButton(
                        text: 'CATAT PEMBAYARAN',
                        color: PixelColors.success,
                        borderColor: PixelColors.border,
                        textColor: Colors.black,
                        onPressed: _processPayment,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PixelButton(
                text: 'KIRIM PENGINGAT (WHATSAPP)',
                color: PixelColors.primaryLight,
                borderColor: PixelColors.primaryDark,
                textColor: Colors.black,
                onPressed: _sendWhatsAppReminder,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
