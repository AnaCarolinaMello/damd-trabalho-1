import 'dart:convert';
import 'dart:typed_data';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';

class Order {
  final String? id;
  final String name;
  final String description;
  String date;
  String time;
  Status status;
  final Uint8List? image;
  double rating;
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
    this.image,
    required this.address,
    this.rating = 0.0,
    this.items = const [],
    this.deliveryFee = 0.0,
    this.discount = 0.0,
  });

  double get price => items.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  double get total => price + deliveryFee - discount;

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] ?? [];
    List<OrderItem> orderItems;
    var address = json['address'];
    
    // Verifica se os itens já são objetos OrderItem ou precisam ser convertidos
    if (itemsList is List<OrderItem>) {
      orderItems = itemsList;
    } else {
      orderItems = itemsList.map<OrderItem>((item) => OrderItem.fromJson(item)).toList();
    }

    if (address is String) {
      address = jsonDecode(address);
    }

    return Order(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: json['date'],
      time: json['time'],
      status: Status.values.byName(json['status']),
      image: json['image'] ?? Uint8List.fromList([]),
      address: Address.fromJson(address),
      items: orderItems,
      deliveryFee: json['delivery_fee'],
      discount: json['discount'],
    );
  }
}