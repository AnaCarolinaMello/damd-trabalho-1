import 'dart:convert';
import 'dart:typed_data';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';

class Order {
  final int? id;
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
  final int? driverId;
  final int? customerId;

  Order({
    this.id,
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
    this.driverId,
    this.customerId,
  });

  double get price => items.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  double get total => price + deliveryFee - discount;

  static Uint8List? _convertToUint8List(dynamic imageData) {
    if (imageData == null) return null;

    try {
      if (imageData is Map && imageData['data'] != null) {
        final bufferData = imageData['data'];
        if (bufferData is List) {
          // Convert ASCII bytes to string
          final jsonString = String.fromCharCodes(List<int>.from(bufferData));

          // Fix malformed JSON: {"255","216",...} -> ["255","216",...]
          final fixedJson = jsonString.replaceFirst('{', '[').replaceFirst(RegExp(r'}$'), ']');

          final decoded = jsonDecode(fixedJson);
          if (decoded is List) {
            return Uint8List.fromList(decoded.map<int>((e) => int.parse(e.toString())).toList());
          }
        }
      } else if (imageData is String) {
        try {
          return base64Decode(imageData);
        } catch (e) {
          // Try fixing malformed JSON format
          final fixedJson = imageData.replaceFirst('{', '[').replaceFirst(RegExp(r'}$'), ']');
          final decoded = jsonDecode(fixedJson);
          if (decoded is List) {
            return Uint8List.fromList(decoded.map<int>((e) => int.parse(e.toString())).toList());
          }
        }
      } else if (imageData is List) {
        return Uint8List.fromList(List<int>.from(imageData));
      }
    } catch (e) {
      print('Error converting image data: $e');
      // Silently fail - images are optional
      return null;
    }

    return null;
  }

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
      id: json['id'] as int?,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: Status.values.byName(json['status'] ?? 'pending'),
      image: _convertToUint8List(json['image']),
      address: Address.fromJson(address),
      items: orderItems,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      driverId: json['driver_id'] as int?,
      customerId: json['customer_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'time': time,
      'status': status.name,
      'image': image,
      'address': address.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_fee': deliveryFee,
      'discount': discount,
      'driver_id': driverId,
      'customer_id': customerId,
    };
  }
}
