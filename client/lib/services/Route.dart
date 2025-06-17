import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:damd_trabalho_1/models/Time.dart';
import 'package:damd_trabalho_1/services/GPXService.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';

class RouteService {
  static const String apiKey = "AIzaSyDh5g6NowzzcUz-6K01CY3PoSIc_pXa4OM";
  static final Map<String, List<LatLng>> _routeCache = {};
  static final Map<String, String> _gpxPathCache = {};
  static final GoogleMapsPolyline _polyline = GoogleMapsPolyline();

  static Future<TimeModel?> getRouteDuration(
    LatLng origin,
    LatLng destination,
  ) async {
    final originString = "${origin.latitude}, ${origin.longitude}";
    final destinationString =
        "${destination.latitude}, ${destination.longitude}";
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$originString&destinations=$destinationString&key=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(
        "Tempo estimado da rota: ${json['rows'][0]['elements'][0]['duration']['text']}",
      );
      return TimeModel(
        time: json['rows'][0]['elements'][0]['duration']['text'],
        distance: json['rows'][0]['elements'][0]['distance']['text'],
      );
    } else {
      print('Erro ao obter a duração da rota: ${response.statusCode}');
      return null;
    }
  }

  /// Gets route points between two coordinates
  static Future<List<LatLng>> getRoutePoints(
    LatLng origin,
    LatLng destination,
  ) async {
    // Create a unique key for this route
    final routeKey = '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';

    // Check if route is cached
    if (_routeCache.containsKey(routeKey)) {
      return _routeCache[routeKey]!;
    }

    // Get route from Google Maps API
    final result = await _polyline.getRouteBetweenCoordinates(
      apiKey,
      MyPointLatLng(origin.latitude, origin.longitude),
      MyPointLatLng(destination.latitude, destination.longitude),
      travelMode: MyTravelMode.driving,
    );

    if (result.status == "OK" && result.points.isNotEmpty) {
      final List<LatLng> routePoints = [];

      for (var point in result.points) {
        routePoints.add(LatLng(point.latitude!, point.longitude!));
      }

      // Cache the result
      _routeCache[routeKey] = routePoints;

      return routePoints;
    } else {
      throw Exception('Failed to get route points: ${result.status}');
    }
  }

  /// Gets or creates a GPX file for a route
  static Future<String> getOrCreateGpxFile(
    LatLng origin,
    LatLng destination,
    String routeId,
  ) async {
    // Create a unique key for this route
    final routeKey = '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';

    // Check if GPX path is cached
    if (_gpxPathCache.containsKey(routeKey)) {
      return _gpxPathCache[routeKey]!;
    }

    // Get route points
    final routePoints = await getRoutePoints(origin, destination);

    // Create GPX file
    final gpxFile = await GPXService.createGpxFromPoints(routePoints, routeId);

    // Cache the path
    _gpxPathCache[routeKey] = gpxFile.path;

    return gpxFile.path;
  }

  /// Simulates driver movement along a route
  static Future<LatLng> simulateDriverPosition(
    String gpxFilePath,
    double progress,
  ) async {
    final routePoints = await GPXService.getPointsFromGpx(gpxFilePath);
    return GPXService.getPositionAtProgress(routePoints, progress);
  }
}
