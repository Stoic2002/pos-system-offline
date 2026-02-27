class DebtModel {
  final int? id;
  final int transactionId;
  final String customerName;
  final double totalDebt;
  final double amountPaid;
  final String status; // 'unpaid', 'partial', 'paid'
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  DebtModel({
    this.id,
    required this.transactionId,
    required this.customerName,
    required this.totalDebt,
    this.amountPaid = 0.0,
    this.status = 'unpaid',
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  DebtModel copyWith({
    int? id,
    int? transactionId,
    String? customerName,
    double? totalDebt,
    double? amountPaid,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      customerName: customerName ?? this.customerName,
      totalDebt: totalDebt ?? this.totalDebt,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'customer_name': customerName,
      'total_debt': totalDebt,
      'amount_paid': amountPaid,
      'status': status,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'],
      transactionId: map['transaction_id'],
      customerName: map['customer_name'],
      totalDebt: map['total_debt'],
      amountPaid: map['amount_paid'],
      status: map['status'],
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}
