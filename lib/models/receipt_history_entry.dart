import 'receipt_data.dart';

class ReceiptHistoryEntry {
  ReceiptHistoryEntry({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.receipt,
  });

  final String id;
  DateTime createdAt;
  String title;
  ReceiptData receipt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'title': title,
        'receipt': receipt.toMap(),
      };

  factory ReceiptHistoryEntry.fromMap(Map<String, dynamic> map) => ReceiptHistoryEntry(
        id: map['id'] as String,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
        title: map['title'] as String? ?? 'Kwitansi',
        receipt: ReceiptData.fromMap(Map<String, dynamic>.from(map['receipt'] as Map)),
      );
}
