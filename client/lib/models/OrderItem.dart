class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final String description;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
    );
  }
}