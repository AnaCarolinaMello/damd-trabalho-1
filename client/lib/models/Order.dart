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
  final String? driverId;
  final bool isSynced;
  final DateTime? lastSyncAttempt;
  final String? syncError;

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
    this.isSynced = true,
    this.lastSyncAttempt,
    this.syncError,
  });

  double get price => items.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  double get total => price + deliveryFee - discount;

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] ?? [];
    List<OrderItem> orderItems;
    var address = json['address'];

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
      deliveryFee: json['delivery_fee'] ?? 0.0,
      discount: json['discount'] ?? 0.0,
      driverId: json['driver_id'],
      isSynced: json['is_synced'] ?? true,
      lastSyncAttempt: json['last_sync_attempt'] != null
          ? DateTime.parse(json['last_sync_attempt'])
          : null,
      syncError: json['sync_error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date,
      'time': time,
      'status': status.name,
      'image': image,
      'address': jsonEncode(address.toJson()),
      'rating': rating,
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_fee': deliveryFee,
      'discount': discount,
      'driver_id': driverId,
      'is_synced': isSynced,
      'last_sync_attempt': lastSyncAttempt?.toIso8601String(),
      'sync_error': syncError,
    };
  }

  Order copyWith({
    String? id,
    String? name,
    String? description,
    String? date,
    String? time,
    Status? status,
    Uint8List? image,
    double? rating,
    List<OrderItem>? items,
    double? deliveryFee,
    double? discount,
    Address? address,
    String? driverId,
    bool? isSynced,
    DateTime? lastSyncAttempt,
    String? syncError,
  }) {
    return Order(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      image: image ?? this.image,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      driverId: driverId ?? this.driverId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncError: syncError ?? this.syncError,
    );
  }
}