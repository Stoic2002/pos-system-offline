import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../shared/widgets/pixel_button.dart';

class QrisPaymentDialog extends StatelessWidget {
  final double amount;

  const QrisPaymentDialog({super.key, required this.amount});

  String get qrisPayload =>
      '00020101021226590014COM.GOJEK.WWW011893600914...540${amount.toInt().toString().length}${amount.toInt()}5802ID5911Toko KasirGo6007Jakarta63040000';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PixelColors.surface,
      shape: const BeveledRectangleBorder(),
      title: Text(
        'BAYAR VIA QRIS',
        style: PixelTextStyles.header,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: qrisPayload,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Total Tagihan:', style: PixelTextStyles.bodyMuted),
          Text('Rp ${amount.toInt()}', style: PixelTextStyles.amountBig),
          const SizedBox(height: 16),
          Text(
            'Minta pelanggan scan QR Code ini\nmenggunakan aplikasi M-Banking/E-Wallet.',
            style: PixelTextStyles.bodyMuted.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // False = unconfirmed
          child: Text('BATAL', style: PixelTextStyles.bodyMuted),
        ),
        PixelButton(
          text: 'KONFIRMASI LUNAS',
          color: PixelColors.success,
          borderColor: PixelColors.primaryDark,
          onPressed: () => Navigator.pop(context, true), // True = confirmed
        ),
      ],
    );
  }
}
