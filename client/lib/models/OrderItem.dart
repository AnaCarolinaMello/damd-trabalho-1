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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as double,
      quantity: json['quantity'] as int,
    );
  }
}