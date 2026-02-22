class ReceiptItem {
  ReceiptItem({
    required this.id,
    required this.quantity,
    required this.name,
    required this.description,
    required this.price,
  });

  final String id;
  int quantity;
  String name;
  String description;
  int price;

  int get total => quantity * price;

  ReceiptItem copy() => ReceiptItem(
        id: id,
        quantity: quantity,
        name: name,
        description: description,
        price: price,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'quantity': quantity,
        'name': name,
        'description': description,
        'price': price,
      };

  factory ReceiptItem.fromMap(Map<String, dynamic> map) => ReceiptItem(
        id: map['id'] as String,
        quantity: map['quantity'] as int? ?? 1,
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        price: map['price'] as int? ?? 0,
      );
}
