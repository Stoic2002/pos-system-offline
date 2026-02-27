import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/transaction.dart';
import '../../core/models/transaction_item.dart';
import '../../core/models/debt.dart';
import '../../core/database/dao/transaction_dao.dart';
import '../../core/database/dao/debt_dao.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';
import '../../shared/widgets/currency_text.dart';
import '../../shared/utils/invoice_generator.dart';
import 'qris_payment_dialog.dart';
import 'receipt_screen.dart';

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({super.key});

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  String _inputAmountStr = '';

  void _onNumpadTapped(String value) {
    setState(() {
      if (value == 'C') {
        _inputAmountStr = '';
      } else if (value == 'DEL') {
        if (_inputAmountStr.isNotEmpty) {
          _inputAmountStr = _inputAmountStr.substring(
            0,
            _inputAmountStr.length - 1,
          );
        }
      } else if (value == '000') {
        if (_inputAmountStr.isNotEmpty) {
          _inputAmountStr += '000';
        }
      } else {
        _inputAmountStr += value;
      }
    });
  }

  void _confirmPayment(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PixelColors.surface,
        shape: const BeveledRectangleBorder(),
        title: Text('KONFIRMASI', style: PixelTextStyles.header),
        content: Text(
          'Yakin selesaikan transaksi ini?',
          style: PixelTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('BATAL', style: PixelTextStyles.bodyMuted),
          ),
          PixelButton(
            text: 'YA, SELESAI',
            color: PixelColors.success,
            borderColor: PixelColors.primaryDark,
            fullWidth: false,
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  void _processPayment(
    double inputAmount,
    double total,
    double change, {
    String method = 'cash',
  }) async {
    if (!mounted) return;

    final cartItems = ref.read(cartProvider);
    final settings = ref.read(settingsProvider);

    final String invoiceNo = InvoiceGenerator.generateFromTimestamp();

    final transaction = TransactionModel(
      invoiceNumber: invoiceNo,
      totalAmount: total,
      paymentMethod: method,
      amountPaid: inputAmount,
      changeAmount: change > 0 ? change : 0,
    );

    final dao = TransactionDao();
    await dao.createTransaction(transaction, cartItems);

    ref.read(cartProvider.notifier).clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          transaction: transaction,
          items: cartItems
              .map(
                (c) => TransactionItem(
                  transactionId: 0,
                  productId: c.product.id!,
                  productName: c.product.name,
                  productPrice: c.product.price,
                  quantity: c.quantity,
                  subtotal: c.subtotal,
                ),
              )
              .toList(),
          storeName: settings['store_name'] ?? 'Toko KasirGo',
        ),
      ),
    );
  }

  void _showKasbonDialog(double inputAmount, double total) {
    if (!mounted) return;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PixelColors.surface,
          shape: const BeveledRectangleBorder(),
          title: Text('SIMPAN KASBON', style: PixelTextStyles.header),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Belanja: Rp ${total.toInt()}',
                style: PixelTextStyles.body,
              ),
              Text(
                'Dibayar: Rp ${inputAmount.toInt()}',
                style: PixelTextStyles.body,
              ),
              Text(
                'Sisa Piutang: Rp ${(total - inputAmount).toInt()}',
                style: PixelTextStyles.body.copyWith(color: PixelColors.danger),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: PixelTextStyles.body,
                decoration: const InputDecoration(
                  labelText: 'NAMA PELANGGAN',
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('BATAL', style: PixelTextStyles.bodyMuted),
            ),
            PixelButton(
              text: 'SIMPAN',
              color: PixelColors.primary,
              borderColor: PixelColors.primaryDark,
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _processKasbon(inputAmount, total, controller.text.trim());
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _processKasbon(
    double inputAmount,
    double total,
    String customerName,
  ) async {
    if (!mounted) return;

    final cartItems = ref.read(cartProvider);
    final settings = ref.read(settingsProvider);

    final String invoiceNo = InvoiceGenerator.generateFromTimestamp();

    final transaction = TransactionModel(
      invoiceNumber: invoiceNo,
      totalAmount: total,
      paymentMethod: 'kasbon',
      amountPaid: inputAmount,
      changeAmount: 0,
    );

    final dao = TransactionDao();
    final txId = await dao.createTransaction(transaction, cartItems);

    final debtDao = DebtDao();
    await debtDao.insertDebt(
      DebtModel(
        transactionId: txId,
        customerName: customerName,
        totalDebt: total,
        amountPaid: inputAmount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    ref.read(cartProvider.notifier).clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          transaction: transaction,
          items: cartItems
              .map(
                (c) => TransactionItem(
                  transactionId: txId,
                  productId: c.product.id!,
                  productName: c.product.name,
                  productPrice: c.product.price,
                  quantity: c.quantity,
                  subtotal: c.subtotal,
                ),
              )
              .toList(),
          storeName: settings['store_name'] ?? 'Toko KasirGo',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.read(cartProvider.notifier).totalAmount;
    final inputAmount = double.tryParse(_inputAmountStr) ?? 0;
    final change = inputAmount - total;
    final isSufficient = inputAmount >= total;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: PixelColors.background,
        border: Border(top: BorderSide(color: PixelColors.primary, width: 3)),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: PixelColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PEMBAYARAN', style: PixelTextStyles.header),
                  IconButton(
                    icon: const Icon(Icons.close, color: PixelColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Container(
              color: PixelColors.surfaceVariant,
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _inputAmountStr = ''; // Reset input when switching tabs
                  });
                },
                labelStyle: PixelTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: PixelTextStyles.bodyMuted,
                indicatorColor: PixelColors.primary,
                indicatorWeight: 4,
                tabs: const [
                  Tab(text: 'TUNAI'),
                  Tab(text: 'QRIS'),
                  Tab(text: 'TRANSFER'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe to avoid accidental numpad inputs
                children: [
                  _buildCashTab(total, inputAmount, change, isSufficient),
                  _buildQrisTab(total),
                  _buildTransferTab(total),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashTab(
    double total,
    double inputAmount,
    double change,
    bool isSufficient,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('TOTAL BELANJA', style: PixelTextStyles.bodyMuted),
                const SizedBox(height: 8),
                CurrencyText(
                  total,
                  style: PixelTextStyles.amountBig.copyWith(
                    color: PixelColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 32),
                Text('UANG DITERIMA', style: PixelTextStyles.bodyMuted),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PixelColors.surfaceVariant,
                    border: Border.all(color: PixelColors.primary, width: 2),
                  ),
                  child: Text(
                    _inputAmountStr.isEmpty ? 'Rp 0' : 'Rp $_inputAmountStr',
                    style: PixelTextStyles.amountBig,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 32),
                Text('KEMBALIAN', style: PixelTextStyles.bodyMuted),
                const SizedBox(height: 8),
                CurrencyText(
                  change > 0 ? change : 0,
                  style: PixelTextStyles.amountBig.copyWith(
                    color: change >= 0
                        ? PixelColors.accentOrange
                        : PixelColors.textMuted,
                  ),
                ),
                const Spacer(),
                if (isSufficient)
                  PixelButton(
                    text: 'SELESAI & CETAK STRUK',
                    color: PixelColors.primary,
                    borderColor: PixelColors.primaryDark,
                    onPressed: () => _confirmPayment(
                      context,
                      () => _processPayment(inputAmount, total, change),
                    ),
                  )
                else if (inputAmount > 0)
                  PixelButton(
                    text: 'JADIKAN KASBON',
                    color: PixelColors.warning,
                    borderColor: PixelColors.primaryDark,
                    textColor: Colors.black,
                    onPressed: () => _showKasbonDialog(inputAmount, total),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: PixelColors.surface,
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: [
                _buildNumpadButton('7'),
                _buildNumpadButton('8'),
                _buildNumpadButton('9'),
                _buildNumpadButton('4'),
                _buildNumpadButton('5'),
                _buildNumpadButton('6'),
                _buildNumpadButton('1'),
                _buildNumpadButton('2'),
                _buildNumpadButton('3'),
                _buildNumpadButton('C', color: PixelColors.danger),
                _buildNumpadButton('0'),
                _buildNumpadButton('000'),
                _buildNumpadButton('DEL', color: PixelColors.warning),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrisTab(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PixelColors.surfaceVariant,
              border: Border.all(color: PixelColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 80,
              color: PixelColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Klik tombol di bawah untuk\nmenghasilkan QRIS dinamis.',
            textAlign: TextAlign.center,
            style: PixelTextStyles.bodyMuted,
          ),
          const SizedBox(height: 24),
          PixelButton(
            text: 'BAYAR VIA QRIS',
            color: Colors.blueAccent,
            borderColor: PixelColors.primaryDark,
            textColor: Colors.white,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => QrisPaymentDialog(amount: total),
              );
              if (confirmed == true) {
                _processPayment(total, total, 0, method: 'qris');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransferTab(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PixelColors.surfaceVariant,
              border: Border.all(color: PixelColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.account_balance,
              size: 80,
              color: PixelColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Konfirmasi pembayaran via\nTransfer Bank.',
            textAlign: TextAlign.center,
            style: PixelTextStyles.bodyMuted,
          ),
          const SizedBox(height: 24),
          PixelButton(
            text: 'KONFIRMASI TRANSFER',
            color: PixelColors.success,
            borderColor: PixelColors.primaryDark,
            textColor: Colors.black,
            onPressed: () {
              _confirmPayment(
                context,
                () => _processPayment(total, total, 0, method: 'transfer'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(
    String label, {
    Color color = PixelColors.surfaceVariant,
  }) {
    return GestureDetector(
      onTap: () => _onNumpadTapped(label),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: PixelColors.border, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: PixelTextStyles.body.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
