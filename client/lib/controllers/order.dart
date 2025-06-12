import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:damd_trabalho_1/services/Api.dart';

class OrderController {
  static final path = 'order';
  static final databaseService = DatabaseService.instance;
  static List<Order> orders = [
    Order(
      id: '4752348',
      name: 'Restaurante Do Sabor',
      description: 'Prato do dia + sobremesa',
      date: DateTime.now().toIso8601String(),
      time: DateTime.now().toIso8601String(),
      status: Status.pending,
      address: Address(
        street: 'Market Street',
        number: '123',
        complement: 'Apt 123',
        neighborhood: 'SoMa',
        city: 'San Francisco',
        state: 'CA',
        zipCode: '94103',
      ),
      deliveryFee: 5.0,
      discount: 2.0,
      items: [
        OrderItem(name: 'Prato do dia', price: 25.0, quantity: 1),
        OrderItem(name: 'Sovermesa', price: 12.90, quantity: 1),
      ],
      customerId: '391c606a-b79b-47f5-aa82-4951eb7fd06d',
    )
  ];

  static Future<List<Order>> getOrders(String userId) async {
    try {
      final response = await ApiService.get('$path/user/$userId');
      return response.map<Order>((order) => Order.fromJson(order)).toList();
    } catch (e) {
      print('error getting orders $e');
      return await databaseService.getOrdersByUserId(userId);
    }
  }

  static Future<Order?> getOrder(String id, String userId) async {
    try {
      final response = await ApiService.get('$path/$id?userId=$userId');
      return Order.fromJson(response);
    } catch (e) {
      return await databaseService.getOrderById(id);
    }
  }

  static Future<void> acceptOrder(String orderId, String driverId) async {
    try {
      final response = await ApiService.post('$path/accept/$orderId', {
        'driverId': driverId,
      });
    } catch (e) {
      await databaseService.assignDriverToOrder(orderId, driverId);
    }
  }

  static Future<Order?> getAcceptedOrder(String driverId) async {
    try {
      final response = await ApiService.get('$path/driver/$driverId');
      return Order.fromJson(response);
    } catch (e) {
      return await databaseService.getOrderByDriverId(driverId);
    }
  }

  static Future<void> deliverOrder(String orderId, String userId, XFile photo) async {
    final Uint8List imageBytes = await photo.readAsBytes();
    try {
      final response = await ApiService.post('$path/deliver/$orderId', {
        'photo': imageBytes,
        'userId': userId,
      });
    } catch (e) {
      await databaseService.finishOrder(orderId, imageBytes);
    }
  }

  static Future<List<Order>> getAvailableOrders() async {
    try {
      final response = await ApiService.get('$path/available');
      return response.map<Order>((order) => Order.fromJson(order)).toList();
    } catch (e) {
      return await databaseService.getOrdersByStatus(Status.pending);
    }
  }

  static Future<Order> createOrder(Order order, String userId) async {
    final newOrder = Order(
      name: order.name,
      description: order.description,
      date: DateTime.now().toIso8601String(),
      time: DateTime.now().toIso8601String(),
      status: Status.pending,
      items: order.items,
      address: order.address,
    );
    try {
      final response = await ApiService.post(path, newOrder);
      return Order.fromJson(response);
    } catch (e) {
      return await databaseService.createOrder(newOrder, userId);
    }
  }

  static Future<void> rateOrder(String orderId, String userId, double rating) async {
    try {
      final response = await ApiService.post('$path/rate/$orderId', {
        'userId': userId,
        'rating': rating,
      });
    } catch (e) {
      await databaseService.rateOrder(orderId, rating);
    }
  }

  static Future<void> createOrders() async {
    try {
      for (var order in orders) {
        await ApiService.post(path, order.toJson());
        print('order created');
      }
    } catch (e) {
      print('error creating orders $e');
      for (var order in orders) {
        await databaseService.createOrder(order, 'e85e1f47-e907-4967-a08f-fa1018f8d80e');
      }
    }
  }
}
