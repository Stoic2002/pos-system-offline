class StockLogModel {
  final int? id;
  final int productId;
  final String
  type; // 'IN' (Restock), 'OUT' (Sale/Adjust), 'ADJUST' (Correction)
  final int quantityChange;
  final int stockBefore;
  final int stockAfter;
  final String? note;
  final DateTime createdAt;

  StockLogModel({
    this.id,
    required this.productId,
    required this.type,
    required this.quantityChange,
    required this.stockBefore,
    required this.stockAfter,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity_change': quantityChange,
      'stock_before': stockBefore,
      'stock_after': stockAfter,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory StockLogModel.fromMap(Map<String, dynamic> map) {
    return StockLogModel(
      id: map['id'],
      productId: map['product_id'],
      type: map['type'],
      quantityChange: map['quantity_change'],
      stockBefore: map['stock_before'],
      stockAfter: map['stock_after'],
      note: map['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
