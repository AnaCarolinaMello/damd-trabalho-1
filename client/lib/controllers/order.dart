import 'package:camera/camera.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:damd_trabalho_1/services/ApiService.dart';

class OrderController {
  static final path = 'orders';
  static final databaseService = DatabaseService.instance;
  static List<Order> orders = [
    Order(
      id: '4752348',
      name: 'Restaurante Sabor Caseiro',
      description: 'Prato do dia + sobremesa',
      date: 'Hoje',
      time: '12:30',
      status: Status.pending,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      deliveryFee: 5.0,
      discount: 2.0,
      items: [
        OrderItem(name: 'Prato do dia', price: 25.0, quantity: 1),
        OrderItem(name: 'Sobremesa', price: 12.90, quantity: 1),
      ],
      isSynced: true,
      lastSyncAttempt: null,
      syncError: null,
    ),
    Order(
      id: '4752341',
      name: 'Supermercado Livre',
      description: '8 itens',
      date: 'Hoje',
      time: '10:45',
      status: Status.accepted,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [
        OrderItem(name: 'Arroz', price: 10.0, quantity: 2),
        OrderItem(name: 'Feijão', price: 8.0, quantity: 1),
      ],
      isSynced: true,
      lastSyncAttempt: null,
      syncError: null,
    ),
    Order(
      id: '4751598',
      name: 'Farmácia Bem Estar',
      description: '3 itens',
      date: '12 Set',
      time: '16:20',
      status: Status.delivered,
      rating: 4.0,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [
        OrderItem(name: 'Paracetamol', price: 10.0, quantity: 2),
        OrderItem(name: 'Ibuprofeno', price: 8.0, quantity: 1),
      ],
      isSynced: true,
      lastSyncAttempt: null,
      syncError: null,
    ),
    Order(
      id: '4751256',
      name: 'Açaí do Nordeste',
      description: 'Açaí 500ml + Complementos',
      date: '10 Set',
      time: '19:15',
      status: Status.delivered,
      rating: 5.0,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [OrderItem(name: 'Açaí', price: 23.90, quantity: 1),],
      isSynced: true,
      lastSyncAttempt: null,
      syncError: null,
    ),
    Order(
      id: '4750928',
      name: 'Hamburgueria Artesanal',
      description: 'Combo X-Tudo',
      date: '05 Set',
      time: '20:45',
      status: Status.delivered,
      rating: 3.5,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [OrderItem(name: 'Combo X-Tudo', price: 42.50, quantity: 1),],
      isSynced: true,
      lastSyncAttempt: null,
      syncError: null,
    ),
    Order(
      id: '4750348',
      name: 'Pizza Express',
      description: 'Pizza Grande Marguerita',
      date: '02 Set',
      time: '21:10',
      status: Status.delivered,
      rating: 4.5,
      deliveryFee: 5.0,
      discount: 2.0,
      address: Address(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 123',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      items: [OrderItem(name: 'Pizza Grande Marguerita', price: 49.90, quantity: 1),],
      isSynced: true,
      lastSyncAttempt: null,
      syncError: null,
    ),
  ];

  static Future<List<Order>> getOrders(String userId) async {
    return await databaseService.getOrdersByUserId(userId);
  }

  static Future<Order?> getOrder(String id) async {
    return databaseService.getOrderById(id);
  }

  static Future<void> acceptOrder(String orderId, String driverId) async {
    await databaseService.assignDriverToOrder(orderId, driverId);
  }

  static Future<Order?> getAcceptOrder(String driverId) async {
    return await databaseService.getOrderByDriverId(driverId);
  }

  static Future<void> deliverOrder(String orderId, XFile photo) async {
    await databaseService.finishOrder(orderId, photo);
  }

  static Future<List<Order>> getAvailableOrders() async {
    return await databaseService.getOrdersByStatus(Status.pending);
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
      deliveryFee: order.deliveryFee,
      discount: order.discount,
      isSynced: false,
      lastSyncAttempt: null,
      syncError: null,
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
        await databaseService.createOrder(
            order.copyWith(isSynced: false),
            '156ed1f3-7445-41b0-ac1d-09054eabdaf9'
        );
      }
    }
  }

  // Add new method for sync operations
  static Future<void> syncOrders() async {
    try {
      // Get unsynced orders
      final unsyncedOrders = await databaseService.getUnsyncedOrders();

      // Try to sync each order
      for (final order in unsyncedOrders) {
        try {
          // Try to post to API
          await ApiService.post(path, order.toJson());

          // If successful, mark as synced
          await databaseService.updateOrder(
              order.copyWith(
                isSynced: true,
                syncError: null,
                lastSyncAttempt: DateTime.now(),
              )
          );
        } catch (e) {
          // Update with error info
          await databaseService.updateOrder(
              order.copyWith(
                lastSyncAttempt: DateTime.now(),
                syncError: e.toString(),
              )
          );
        }
      }

      // Get updates from server
      final serverOrders = await ApiService.get(path);
      await databaseService.syncWithServer(serverOrders);
    } catch (e) {
      print('Sync error: $e');
    }
  }
}
