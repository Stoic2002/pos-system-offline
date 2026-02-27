import 'package:intl/intl.dart';

class InvoiceGenerator {
  /// Format: KG-YYYYMMDD-XXXX
  /// Contoh: KG-20250227-0001
  static String generate(int sequence) {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    final seqStr = sequence.toString().padLeft(4, '0');
    return 'KG-$date-$seqStr';
  }

  /// Helper method for quick generation based on timestamp
  static String generateFromTimestamp() {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    final seq = DateTime.now().millisecondsSinceEpoch.toString().substring(9);
    return 'KG-$date-$seq';
  }
}
