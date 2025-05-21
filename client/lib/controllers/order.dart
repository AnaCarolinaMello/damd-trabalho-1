import 'package:camera/camera.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:damd_trabalho_1/services/Api.dart';

class OrderController {
  static final path = 'orders';
  static final databaseService = DatabaseService.instance;
  static List<Order> orders = [
    Order(
      id: '4752348',
      name: 'Restaurante Do Sabor',
      description: 'Prato do dia + sobremesa',
      date: 'Hoje',
      time: '12:30',
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
    )
  ];

  static Future<List<Order>> getOrders(String userId) async {
    return await databaseService.getOrdersByUserId(userId);
  }

  static Future<Order?> getOrder(String id) async {
    // try {
    //   final response = await ApiService.get('$path/$id');
    //   return Order.fromJson(response);
    // } catch (e) {
      return databaseService.getOrderById(id);
    // }
  }

  static Future<void> acceptOrder(String orderId, String driverId) async {
    // try {
    //   final response = await ApiService.post('$path/accept/$orderId', {
    //     'driver_id': driverId,
    //   });
    // } catch (e) {
      await databaseService.assignDriverToOrder(orderId, driverId);
    // }
  }

  static Future<Order?> getAcceptOrder(String driverId) async {
    // try {
    //   final response = await ApiService.get('$path/accept/$driverId');
    //   return Order.fromJson(response);
    // } catch (e) {
      return await databaseService.getOrderByDriverId(driverId);
    // }
  }

  static Future<void> deliverOrder(String orderId, XFile photo) async {
    await databaseService.finishOrder(orderId, photo);
  }

  static Future<List<Order>> getAvailableOrders() async {
    // try {
    //   final response = await ApiService.get('$path/available');
    //   return response.map((order) => Order.fromJson(order)).toList();
    // } catch (e) {
    return await databaseService.getOrdersByStatus(Status.pending);
    // }
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
    return await databaseService.createOrder(newOrder, userId);
  }

  static Future<void> rateOrder(String orderId, double rating) async {
    await databaseService.rateOrder(orderId, rating);
  }

  static Future<void> createOrders() async {
    try {
      await ApiService.post(path, orders);
    } catch (e) {
      for (var order in orders) {
        await databaseService.createOrder(order, 'e85e1f47-e907-4967-a08f-fa1018f8d80e');
      }
    }
  }
}
