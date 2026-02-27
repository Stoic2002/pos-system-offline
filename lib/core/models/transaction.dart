class TransactionModel {
  final int? id;
  final String invoiceNumber;
  final double totalAmount;
  final double discountAmount;
  final String paymentMethod; // 'cash', 'qris', 'transfer'
  final double amountPaid;
  final double changeAmount;
  final String? note;
  final String status; // 'completed', 'voided'
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    this.discountAmount = 0,
    required this.paymentMethod,
    this.amountPaid = 0,
    this.changeAmount = 0,
    this.note,
    this.status = 'completed',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'note': note,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      totalAmount: map['total_amount'],
      discountAmount: map['discount_amount'] ?? 0,
      paymentMethod: map['payment_method'],
      amountPaid: map['amount_paid'] ?? 0,
      changeAmount: map['change_amount'] ?? 0,
      note: map['note'],
      status: map['status'] ?? 'completed',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  TransactionModel copyWith({
    int? id,
    String? invoiceNumber,
    double? totalAmount,
    double? discountAmount,
    String? paymentMethod,
    double? amountPaid,
    double? changeAmount,
    String? note,
    String? status,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
