import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/date_formatter.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';

final printerServiceProvider = Provider((ref) => PrinterService());

class PrinterService {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await printer.getBondedDevices();
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      final isConnected = await printer.isConnected;
      if (isConnected == true) {
        await printer.disconnect();
      }
      return await printer.connect(device) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    await printer.disconnect();
  }

  Future<void> testPrint() async {
    final isConnected = await printer.isConnected;
    if (isConnected != true) return;

    printer.printNewLine();
    printer.printCustom("KASIRGO TEST PRINT", 2, 1);
    printer.printNewLine();
    printer.printQRcode("KasirGo", 200, 200, 1);
    printer.printNewLine();
    printer.printNewLine();
  }

  Future<void> printReceipt({
    required String storeName,
    required TransactionModel transaction,
    required List<TransactionItem> items,
  }) async {
    final isConnected = await printer.isConnected;
    if (isConnected != true) return;

    printer.printNewLine();
    printer.printCustom(storeName, 2, 1);
    printer.printNewLine();

    printer.printCustom(
      DateFormatter.formatDateTime(transaction.createdAt),
      0,
      1,
    );
    printer.printCustom("No: ${transaction.invoiceNumber}", 0, 1);
    printer.printNewLine();

    printer.printCustom("--------------------------------", 0, 1);

    for (var item in items) {
      printer.printCustom(item.productName, 0, 0);
      final qtyPrice = "${item.quantity} x Rp ${item.productPrice.toInt()}";
      final subtotal = "Rp ${item.subtotal.toInt()}";

      // Attempting simple text justification for 32 character standard printer
      int spacing = 32 - (qtyPrice.length + subtotal.length);
      if (spacing < 1) spacing = 1;

      printer.printCustom(
        "$qtyPrice${List.filled(spacing, ' ').join()}$subtotal",
        0,
        0,
      );
    }

    printer.printCustom("--------------------------------", 0, 1);

    final totalStr = "TOTAL";
    final totalVal = "Rp ${transaction.totalAmount.toInt()}";
    int tSpace = 32 - (totalStr.length + totalVal.length);
    printer.printCustom(
      "$totalStr${List.filled(tSpace > 0 ? tSpace : 1, ' ').join()}$totalVal",
      1,
      0,
    );

    final cashStr = "TUNAI";
    final cashVal = "Rp ${transaction.amountPaid.toInt()}";
    int cSpace = 32 - (cashStr.length + cashVal.length);
    printer.printCustom(
      "$cashStr${List.filled(cSpace > 0 ? cSpace : 1, ' ').join()}$cashVal",
      0,
      0,
    );

    final changeStr = "KEMBALI";
    final changeVal = "Rp ${transaction.changeAmount.toInt()}";
    int chSpace = 32 - (changeStr.length + changeVal.length);
    printer.printCustom(
      "$changeStr${List.filled(chSpace > 0 ? chSpace : 1, ' ').join()}$changeVal",
      0,
      0,
    );

    printer.printNewLine();
    printer.printCustom("TERIMA KASIH", 1, 1);
    printer.printCustom("Powered by KasirGo", 0, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
  }
}
