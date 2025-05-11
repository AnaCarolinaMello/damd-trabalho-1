import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:damd_trabalho_1/models/User.dart';
import 'package:damd_trabalho_1/models/Address.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/models/enum/UserType.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:uuid/uuid.dart';
import 'package:damd_trabalho_1/database/schema.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  final _uuid = Uuid();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'delivery_tracker.db');

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print("Error creating database directory: $e");
      }

      return await openDatabase(
        path,
        version: 3,
        onCreate: _createDB,
        onOpen: (db) {
          print("Database opened successfully at $path");
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print("Upgrading database from version $oldVersion to $newVersion");
          await _createDB(db, newVersion);
        },
      );
    } catch (e) {
      print("Critical database initialization error: $e");
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      final String schema = DatabaseSchema.schema;
      final List<String> queries =
          schema.split(';').where((query) => query.trim().isNotEmpty).toList();

      for (String query in queries) {
        final cleanQuery = query.trim();
        if (cleanQuery.isNotEmpty) {
          try {
            await db.execute(cleanQuery);
          } catch (e) {
            print("Error executing query: $cleanQuery");
            print("Error details: $e");
          }
        }
      }
      print("Database schema applied successfully");
    } catch (e) {
      print('Database creation error: $e');
      rethrow;
    }
  }

  // User operations
  Future<String> createUser(User user) async {
    try {
      final db = await instance.database;
      final id = _uuid.v4();

      final userData = user.toJson();
      userData['id'] = id;

      print("Creating user with data: $userData");

      await db.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return id;
    } catch (e) {
      print("Error creating user: $e");
      rethrow;
    }
  }

  Future<List<User>> getUsers() async {
    final db = await instance.database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromJson(map)).toList();
  }

  Future<User?> getUser(String id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<List<User>> getUsersByType(UserType type) async {
    final db = await instance.database;
    final typeString =
        type.toString().split('.').last; // Convert enum to string

    final maps = await db.query(
      'users',
      where: 'type = ?',
      whereArgs: [typeString],
    );

    return maps.map((map) => User.fromJson(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Address operations
  Future<String> createAddress(Address address) async {
    final db = await instance.database;
    final id = _uuid.v4();

    await db.insert('addresses', {
      'id': id,
      'street': address.street,
      'number': address.number,
      'complement': address.complement,
      'neighborhood': address.neighborhood,
      'city': address.city,
      'state': address.state,
      'zip_code': address.zipCode,
      'is_default': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  // Order operations
  Future<Order> createOrder(Order order, String customerId) async {
    final db = await instance.database;
    final orderId = _uuid.v4();
    final String addressId = await createAddress(order.address);

    await db.insert('orders', {
      'id': orderId,
      'customer_id': customerId,
      'name': order.name,
      'description': order.description,
      'date': order.date,
      'time': order.time,
      'status': order.status.toString().split('.').last,
      'image': order.image,
      'delivery_fee': order.deliveryFee,
      'discount': order.discount,
      'address_id': addressId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert order items
    for (var item in order.items) {
      await db.insert('order_items', {
        'id': _uuid.v4(),
        'order_id': orderId,
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'quantity': item.quantity,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return order;
  }

  Future<List<Order>> getOrdersByStatus(Status status) async {
    final db = await instance.database;

    // Primeiro, buscar as ordens com o status solicitado
    final orderMaps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status.toString().split('.').last],
    );

    List<Order> orders = [];

    // Para cada ordem, buscar seus itens e endereço associado
    for (var orderMap in orderMaps) {
      final String orderId = orderMap['id'] as String;

      // Buscar os itens da ordem
      final orderItems = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      // Buscar o endereço se houver id de endereço
      List<Map<String, dynamic>> addressMaps = [];
      if (orderMap['address_id'] != null) {
        addressMaps = await db.query(
          'addresses',
          where: 'id = ?',
          whereArgs: [orderMap['address_id']],
        );
      }

      // Adicionar os itens e endereço ao mapa da ordem
      final completeOrderMap = Map<String, dynamic>.from(orderMap);
      completeOrderMap['items'] = orderItems;
      completeOrderMap['address'] =
          addressMaps.isNotEmpty ? addressMaps.first : null;

      // Converter para objeto Order e adicionar à lista
      print(completeOrderMap['delivery_fee']);
      orders.add(Order.fromJson(completeOrderMap));
    }

    return orders;
  }

  Future<List<Order>> getOrdersByUserId(String userId) async {
    final db = await instance.database;

    final orderMaps = await db.rawQuery(
      '''
      SELECT o.*, a.street, a.number, a.complement, a.neighborhood, a.city, a.state, a.zip_code
      FROM orders o
      JOIN addresses a ON o.address_id = a.id
      WHERE o.customer_id = ?
      ORDER BY o.created_at DESC
    ''',
      [userId],
    );

    List<Order> orders = [];

    for (var orderMap in orderMaps) {
      final String orderId = orderMap['id'] as String;

      // Get order items
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items =
          itemMaps
              .map(
                (map) => OrderItem(
                  name: map['name'] as String,
                  description: map['description'] as String? ?? '',
                  price: map['price'] as double,
                  quantity: map['quantity'] as int,
                ),
              )
              .toList();

      // Create address
      final address = Address(
        street: orderMap['street'] as String,
        number: orderMap['number'] as String,
        complement: orderMap['complement'] as String? ?? '',
        neighborhood: orderMap['neighborhood'] as String,
        city: orderMap['city'] as String,
        state: orderMap['state'] as String,
        zipCode: orderMap['zip_code'] as String,
      );

      // Create order
      orders.add(
        Order(
          id: orderId,
          name: orderMap['name'] as String,
          description: orderMap['description'] as String? ?? '',
          date: orderMap['date'] as String,
          time: orderMap['time'] as String,
          status: Status.values.byName(orderMap['status'] as String),
          image: orderMap['image'] as Uint8List? ?? Uint8List.fromList([]),
          rating: orderMap['rating'] as double? ?? 0.0,
          deliveryFee: orderMap['delivery_fee'] as double? ?? 0.0,
          discount: orderMap['discount'] as double? ?? 0.0,
          address: address,
          items: items,
        ),
      );
    }

    return orders;
  }

  Future<Order?> getOrderById(String orderId) async {
    final db = await instance.database;

    final orderMaps = await db.rawQuery(
      '''
      SELECT o.*, a.street, a.number, a.complement, a.neighborhood, a.city, a.state, a.zip_code
      FROM orders o
      JOIN addresses a ON o.address_id = a.id
      WHERE o.id = ?
    ''',
      [orderId],
    );

    if (orderMaps.isEmpty) {
      return null;
    }

    final orderMap = orderMaps.first;

    // Buscar os itens da ordem
    final orderItems = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    // Construir o endereço a partir dos resultados
    final address = {
      'id': orderMap['address_id'],
      'street': orderMap['street'],
      'number': orderMap['number'],
      'complement': orderMap['complement'],
      'neighborhood': orderMap['neighborhood'],
      'city': orderMap['city'],
      'state': orderMap['state'],
      'zip_code': orderMap['zip_code'],
    };

    // Construir o mapa completo
    final completeOrderMap = Map<String, dynamic>.from(orderMap);
    completeOrderMap['items'] = orderItems;
    completeOrderMap['address'] = address;

    // Converter a string JSON em um mapa se necessário
    if (completeOrderMap['address'] is String) {
      try {
        completeOrderMap['address'] = jsonDecode(
          completeOrderMap['address'] as String,
        );
      } catch (e) {
        print('Erro ao decodificar o JSON do endereço: $e');
      }
    }

    return Order.fromJson(completeOrderMap);
  }

  Future<Order?> getOrderByDriverId(String driverId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> orderMaps = await db.rawQuery(
      '''
      SELECT o.*, 
      json_object(
        'id', a.id,
        'street', a.street,
        'number', a.number,
        'complement', a.complement,
        'neighborhood', a.neighborhood,
        'city', a.city,
        'state', a.state,
        'zip_code', a.zip_code
      ) as address
      FROM orders o
      LEFT JOIN addresses a ON o.address_id = a.id
      WHERE o.driver_id = ? AND o.status = ?
      LIMIT 1
      ''',
      [driverId, Status.accepted.toString().split('.').last],
    );

    if (orderMaps.isEmpty) {
      return null;
    }

    return Order.fromJson(orderMaps.first);
  }

  Future<int> updateOrderStatus(String orderId, Status status) async {
    final db = await instance.database;
    return db.update(
      'orders',
      {'status': status.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> finishOrder(String orderId, XFile photo) async {
    final db = await instance.database;

    try {
      // Ler a imagem como bytes
      final Uint8List imageBytes = await photo.readAsBytes();

      // Atualizar a ordem com os dados binários da imagem
      return db.update(
        'orders',
        {
          'image': imageBytes, // Armazena os bytes diretamente no campo BLOB
          'status': Status.delivered.toString().split('.').last,
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );
    } catch (e) {
      print('Erro ao salvar imagem: $e');
      return 0;
    }
  }

  Future<int> assignDriverToOrder(String orderId, String driverId) async {
    final db = await instance.database;
    return db.update(
      'orders',
      {
        'driver_id': driverId,
        'status': Status.accepted.toString().split('.').last,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> rateOrder(String orderId, double rating) async {
    final db = await instance.database;
    return db.update(
      'orders',
      {'rating': rating},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
