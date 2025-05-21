import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/services/ApiService.dart';
import 'package:damd_trabalho_1/services/Database.dart';

class SyncService {
  final DatabaseService databaseService;
  final Connectivity connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;

  SyncService({
    required this.databaseService,
    Connectivity? connectivity,
  }) : connectivity = connectivity ?? Connectivity();

  Future<bool> isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncOrders() async {
    if (!await isConnected()) return;

    try {
      // Sync local changes to server
      await _pushLocalChanges();

      // Get updates from server
      await _pullServerUpdates();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<void> _pushLocalChanges() async {
    final unsyncedOrders = await databaseService.getUnsyncedOrders();

    for (final order in unsyncedOrders) {
      try {
        dynamic response;
        if (order.id == null) {
          response = await ApiService.post('orders', order.toJson());
        } else {
          response = await ApiService.put('orders/${order.id}', order.toJson());
        }

        final updatedOrder = order.copyWith(
          isSynced: true,
          syncError: null,
          lastSyncAttempt: DateTime.now(),
        );
        await databaseService.updateOrder(updatedOrder);
      } catch (e) {
        final updatedOrder = order.copyWith(
          lastSyncAttempt: DateTime.now(),
          syncError: e.toString(),
        );
        await databaseService.updateOrder(updatedOrder);
        rethrow;
      }
    }
  }

  Future<void> _pullServerUpdates() async {
    try {
      final serverOrders = await ApiService.get('orders');
      await databaseService.syncWithServer(serverOrders);
    } catch (e) {
      print('Failed to fetch server updates: $e');
      rethrow;
    }
  }

  void initializeSync() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (!result.contains(ConnectivityResult.none)) {
        syncOrders();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}