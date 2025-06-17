import 'package:damd_trabalho_1/services/Api.dart';
import 'package:geolocator/geolocator.dart';

/// Serviço para gerenciar tracking de entregas
///
/// Este serviço integra com o gateway da API (/api) nas rotas de tracking (/tracking)
///
/// Exemplos de uso:
///
/// 1. Atualizar localização do motorista:
/// ```dart
/// await TrackingService.updateDriverLocation(
///   driverId: 123,
///   orderId: 456,
///   latitude: -23.5505,
///   longitude: -46.6333,
/// );
/// ```
///
/// 2. Obter informações de entrega para o cliente:
/// ```dart
/// final delivery = await TrackingService.getDeliveryLocation(orderId, customerId);
/// ```
///
/// 3. Calcular distância e ETA:
/// ```dart
/// final eta = await TrackingService.calculateETA(orderId, driverId);
/// print('Distância: ${eta['distance_km']} km');
/// print('ETA: ${eta['eta_minutes']} minutos');
/// ```
class TrackingService {
  // Atualizar localização do motorista
  static Future<dynamic> updateDriverLocation({
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
        'order_id': orderId,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed ?? 0.0,
        'heading': heading ?? 0.0,
        'accuracy': accuracy ?? 0.0,
      };

      return await ApiService.post('tracking/location', data);
    } catch (e) {
      throw Exception('Erro ao atualizar localização: $e');
    }
  }

  // Obter localização atual do motorista
  static Future<dynamic> getDriverLocation(int driverId) async {
    try {
      return await ApiService.get('tracking/location/driver/$driverId');
    } catch (e) {
      throw Exception('Erro ao obter localização do motorista: $e');
    }
  }

  // Obter localização da entrega para o cliente
  static Future<dynamic> getDeliveryLocation(int orderId, int customerId) async {
    try {
      return await ApiService.get('tracking/delivery/$orderId/customer/$customerId');
    } catch (e) {
      throw Exception('Erro ao obter localização da entrega: $e');
    }
  }

  // Atualizar status da entrega
  static Future<dynamic> updateDeliveryStatus({
    required int orderId,
    required int driverId,
    required String status,
    double? latitude,
    double? longitude,
    String? notes,
    String? destinationAddress,
    int? customerId,
  }) async {
    try {
      final data = {
        'order_id': orderId,
        'driver_id': driverId,
        'status': status,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
        'destination_address': destinationAddress,
        'customer_id': customerId,
      };

      return await ApiService.post('tracking/status', data);
    } catch (e) {
      throw Exception('Erro ao atualizar status da entrega: $e');
    }
  }

  // Obter histórico de tracking
  static Future<dynamic> getDeliveryHistory(int orderId, int userId) async {
    try {
      return await ApiService.get('tracking/history/$orderId/user/$userId');
    } catch (e) {
      throw Exception('Erro ao obter histórico de entrega: $e');
    }
  }

  // Calcular ETA
  static Future<dynamic> calculateETA(int orderId, int driverId) async {
    try {
      return await ApiService.get('tracking/eta/$orderId/driver/$driverId');
    } catch (e) {
      throw Exception('Erro ao calcular ETA: $e');
    }
  }

  // Obter entregas ativas do motorista
  static Future<dynamic> getDriverActiveDeliveries(int driverId) async {
    try {
      return await ApiService.get('tracking/driver/$driverId/active');
    } catch (e) {
      throw Exception('Erro ao obter entregas ativas: $e');
    }
  }

  // Obter localização atual do dispositivo
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviços de localização estão desabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissões de localização foram negadas.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissões de localização foram negadas permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Calcular distância entre dois pontos
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // em km
  }
}
