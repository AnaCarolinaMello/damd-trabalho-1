import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:damd_trabalho_1/services/Api.dart';
import 'package:damd_trabalho_1/controllers/tracking.dart';
import 'package:damd_trabalho_1/services/Route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:damd_trabalho_1/controllers/notification.dart';

class OrderController {
  static final path = 'order';
  static final databaseService = DatabaseService.instance;
  static List<Order> orders = [
    Order(
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
      customerId: 1,
    ),
  ];

  static Future<List<Order>> getOrders(int userId) async {
    try {
      final response = await ApiService.get('$path/user/$userId');
      return response.map<Order>((order) => Order.fromJson(order)).toList();
    } catch (e) {
      print('error getting orders $e');
      return await databaseService.getOrdersByUserId(userId);
    }
  }

  static Future<Order?> getOrder(int id, int userId) async {
    try {
      final response = await ApiService.get('$path/$id?userId=$userId');
      return Order.fromJson(response);
    } catch (e) {
      return await databaseService.getOrderById(id);
    }
  }

  static Future<void> acceptOrder(int orderId, int driverId) async {
    try {
      final response = await ApiService.post('$path/accept/$orderId', {
        'driverId': driverId,
      });
    } catch (e) {
      await databaseService.assignDriverToOrder(orderId, driverId);
    }
  }

  static Future<Order?> getAcceptedOrder(int driverId) async {
    try {
      final response = await ApiService.get('$path/driver/$driverId');
      return Order.fromJson(response);
    } catch (e) {
      return await databaseService.getOrderByDriverId(driverId);
    }
  }

  static Future<void> deliverOrder(int orderId, int userId, XFile photo) async {
    final Uint8List imageBytes = await photo.readAsBytes();
    try {
      await ApiService.post('$path/deliver/$orderId', {
        'photo': imageBytes,
        'userId': userId,
      });

      // Update tracking when order is delivered
      await TrackingService.updateDeliveryStatus(
        orderId: orderId,
        driverId: userId, // Assuming userId is driverId in this context
        status: Status.delivered,
        notes: 'Pedido entregue com sucesso',
      );
      await NotificationController.createNotification();
    } catch (e) {
      print(
        'error delivering order: $e and orderId: $orderId and userId: $userId',
      );
      await databaseService.finishOrder(orderId, imageBytes);
    }
  }

  static Future<void> cancelOrder(int orderId, int userId) async {
    try {
      await ApiService.post('$path/cancel/$orderId', {'userId': userId});
    } catch (e) {
      print(
        'error canceling order: $e and orderId: $orderId and userId: $userId',
      );
      await databaseService.updateOrderStatus(orderId, Status.cancelled);
    }
  }

  static Future<List<Order>> getAvailableOrders() async {
    try {
      final response = await ApiService.get('$path/available');
      final nearByOrders = await TrackingService.getNearbyDeliveries();
      print('nearByOrders: $nearByOrders');
      return response
          .map<Order>((order) => Order.fromJson(order))
          .where(
            (order) => nearByOrders.any(
              (nearByOrder) => nearByOrder['order_id'] == order.id,
            ),
          )
          .toList();
    } catch (e) {
      return await databaseService.getOrdersByStatus(Status.pending);
    }
  }

  static Future<Order> createOrder(Order order, int userId) async {
    final newOrder = Order(
      name: order.name,
      description: order.description,
      date: DateTime.now().toIso8601String(),
      time:
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      status: Status.pending,
      items: order.items,
      address: order.address,
      customerId: userId,
      deliveryFee: order.deliveryFee,
      discount: order.discount,
    );
    try {
      final response = await ApiService.post(path, newOrder.toJson());
      LatLng latLng = await RouteService.getLatAndLngByAddress(order.address);
      await TrackingService.updateDeliveryStatus(
        orderId: response['id'],
        driverId: userId,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        status: Status.pending,
        destinationAddress: order.address.fullAddress,
      );
      return Order.fromJson(response);
    } catch (e) {
      return await databaseService.createOrder(newOrder, userId);
    }
  }

  static Future<void> rateOrder(int orderId, int userId, double rating) async {
    try {
      await ApiService.post('$path/rate/$orderId', {
        'userId': userId,
        'rating': rating,
      });
    } catch (e) {
      print('error rating order: $e');
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
        await databaseService.createOrder(order, 1);
      }
    }
  }

  // Tracking-related methods

  static Future<Map<String, dynamic>?> getOrderTracking(
    int orderId,
    int customerId,
  ) async {
    try {
      return await TrackingService.getDeliveryLocation(orderId, customerId);
    } catch (e) {
      print('Error getting order tracking: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getOrderHistory(int orderId, int userId) async {
    try {
      return await TrackingService.getDeliveryHistory(orderId, userId);
    } catch (e) {
      print('Error getting order history: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> calculateOrderETA(
    int orderId,
    int driverId,
  ) async {
    try {
      return await TrackingService.calculateETA(orderId, driverId);
    } catch (e) {
      print('Error calculating ETA: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getDriverActiveOrders(int driverId) async {
    try {
      return await TrackingService.getDriverActiveDeliveries(driverId);
    } catch (e) {
      print('Error getting driver active orders: $e');
      return [];
    }
  }
}
