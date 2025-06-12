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
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }
}