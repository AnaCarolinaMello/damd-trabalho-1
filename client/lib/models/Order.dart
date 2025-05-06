import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';

class Order {
  final String id;
  final String name;
  final String description;
  final String date;
  final String time;
  final String status;
  final String imageUrl;
  final double rating;
  final bool isRated;
  final List<OrderItem> items;
  final double deliveryFee;
  final double discount;
  final Address address;

  Order({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.imageUrl,
    required this.address,
    this.rating = 0.0,
    this.isRated = false,
    this.items = const [],
    this.deliveryFee = 0.0,
    this.discount = 0.0,
  });

  double get price => items.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  double get total => price + deliveryFee - discount;
}