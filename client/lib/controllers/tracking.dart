import 'package:damd_trabalho_1/services/Api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingService {
  static const String _trackingPath = 'tracking';

  // Update driver location
  static Future<Map<String, dynamic>> updateDriverLocation({
    required int driverId,
    int? orderId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    try {
      final data = {
        'driver_id': driverId,
        if (orderId != null) 'order_id': orderId,
        'latitude': latitude,
        'longitude': longitude,
        if (speed != null) 'speed': speed,
        if (heading != null) 'heading': heading,
        if (accuracy != null) 'accuracy': accuracy,
      };

      return await ApiService.post('$_trackingPath/location', data);
    } catch (e) {
      throw Exception('Failed to update driver location: $e');
    }
  }

  // Get driver current location
  static Future<Map<String, dynamic>> getDriverLocation(int driverId) async {
    try {
      return await ApiService.get('$_trackingPath/location/driver/$driverId');
    } catch (e) {
      throw Exception('Failed to get driver location: $e');
    }
  }

  // Update delivery status
  static Future<Map<String, dynamic>> updateDeliveryStatus({
    required int orderId,
    required int driverId,
    int? customerId,
    required String status,
    double? latitude,
    double? longitude,
    String? notes,
    String? destinationAddress,
  }) async {
    try {
      final data = {
        'order_id': orderId,
        'driver_id': driverId,
        if (customerId != null) 'customer_id': customerId,
        'status': status,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (notes != null) 'notes': notes,
        if (destinationAddress != null) 'destination_address': destinationAddress,
      };

      return await ApiService.post('$_trackingPath/status', data);
    } catch (e) {
      throw Exception('Failed to update delivery status: $e');
    }
  }

  // Get delivery location for customer
  static Future<Map<String, dynamic>> getDeliveryLocation(int orderId, int customerId) async {
    try {
      return await ApiService.get('$_trackingPath/delivery/$orderId/customer/$customerId');
    } catch (e) {
      throw Exception('Failed to get delivery location: $e');
    }
  }

  // Get delivery history
  static Future<List<dynamic>> getDeliveryHistory(int orderId, int userId) async {
    try {
      return await ApiService.get('$_trackingPath/history/$orderId/user/$userId');
    } catch (e) {
      throw Exception('Failed to get delivery history: $e');
    }
  }

  // Get nearby deliveries
  static Future<List<dynamic>> getNearbyDeliveries({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final query = 'latitude=$latitude&longitude=$longitude&radius=$radius';
      return await ApiService.get('$_trackingPath/nearby?$query');
    } catch (e) {
      throw Exception('Failed to get nearby deliveries: $e');
    }
  }

  // Calculate ETA
  static Future<Map<String, dynamic>> calculateETA(int orderId, int driverId) async {
    try {
      return await ApiService.get('$_trackingPath/eta/$orderId/driver/$driverId');
    } catch (e) {
      throw Exception('Failed to calculate ETA: $e');
    }
  }

  // Get driver active deliveries
  static Future<List<dynamic>> getDriverActiveDeliveries(int driverId) async {
    try {
      return await ApiService.get('$_trackingPath/driver/$driverId/active');
    } catch (e) {
      throw Exception('Failed to get driver active deliveries: $e');
    }
  }

  // Helper method to convert LatLng to coordinates
  static Map<String, double> latLngToCoordinates(LatLng position) {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }

  // Helper method to convert coordinates to LatLng
  static LatLng coordinatesToLatLng(Map<String, dynamic> coordinates) {
    return LatLng(
      coordinates['latitude']?.toDouble() ?? 0.0,
      coordinates['longitude']?.toDouble() ?? 0.0,
    );
  }

  // Status constants
  static const String statusPending = 'pending';
  static const String statusPreparing = 'preparing';
  static const String statusAccepted = 'accepted';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';
}
