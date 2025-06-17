import 'dart:async';
import 'package:damd_trabalho_1/controllers/tracking.dart';
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/services/Route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:damd_trabalho_1/models/Time.dart';

class RoutePage extends StatefulWidget {
  final Order order;
  const RoutePage({super.key, required this.order});

  @override
  State<RoutePage> createState() => _RouteState();
}

class _RouteState extends State<RoutePage> {
  bool isDarkMode = false;
  bool isLoading = true;
  late GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late LatLng _destination = const LatLng(40.6782, -73.9442);
  late LatLng _location = const LatLng(40.6944, -73.9212);
  TimeModel? _timeDistance;
  bool _gettingTimeDistance = true;

  // GPX simulation variables
  String? _gpxFilePath;
  List<LatLng>? _routePoints;
  double _simulationProgress = 0.0;
  Timer? _simulationTimer;
  final double _simulationDuration = 180; // 3 minutes in seconds
  final double _simulationUpdateInterval = 1; // Update every second
  bool _isSimulating = false;

  // Real-time location tracking variables
  StreamSubscription<Position>? _locationSubscription;
  bool _useRealTimeLocation = false;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void init() async {
    await getCurrentLocation();
    await getAddress();
    await getRouteDuration();
    await setupRouteSimulation();
    getMakers();
  }

  void getMakers() {
    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId(widget.order.address.fullAddress),
        position: LatLng(_destination.latitude, _destination.longitude),
        infoWindow: InfoWindow(
          title: widget.order.address.shortAddress,
          snippet: widget.order.address.shortAddress,
        ),
      );
      final marker2 = Marker(
        markerId: const MarkerId('Sua localização'),
        position: LatLng(_location.latitude, _location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: const InfoWindow(
          title: 'Sua localização',
          snippet: 'Sua localização',
        ),
      );
      _markers[widget.order.address.fullAddress] = marker;
      _markers['Sua localização'] = marker2;
      isLoading = false;
    });
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está ativo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Verifica se temos permissão para acessar a localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Obtém a posição atual e atualiza a interface
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = LatLng(position.latitude, position.longitude);
    });
  }

  /// Start tracking the driver's real location instead of simulating
  Future<void> startRealTimeLocationTracking() async {
    // Cancel simulation if running
    if (_isSimulating) {
      stopSimulation();
    }

    _locationSubscription?.cancel();

    // Make sure location services and permissions are available
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      print('Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      print('Location permissions are permanently denied');
      return;
    }

    // Start listening to location changes
    setState(() {
      _useRealTimeLocation = true;
    });

    // Get current position first
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Update the marker with current position
    await updateDriverMarker(LatLng(position.latitude, position.longitude));

    // Subscribe to location updates
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) async {
      if (_useRealTimeLocation) {
        // Update driver position with real GPS location
        await updateDriverMarker(LatLng(position.latitude, position.longitude));
      }
    });
  }

  /// Stop real-time location tracking
  void stopRealTimeLocationTracking() {
    _locationSubscription?.cancel();
    setState(() {
      _useRealTimeLocation = false;
    });
  }

  /// Update the driver's marker with a new position
  Future<void> updateDriverMarker(LatLng position) async {
    setState(() {
      _location = position;

      // Update the marker
      _markers['Sua localização'] = Marker(
        markerId: const MarkerId('Sua localização'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: const InfoWindow(
          title: 'Sua localização',
          snippet: 'Sua localização',
        ),
      );
    });

    // Move the camera to follow the driver
    mapController.animateCamera(CameraUpdate.newLatLng(position));

    // Recalculate route
    updateRoute(position);
  }

  /// Update the route and duration based on new driver position
  Future<void> updateRoute(LatLng position) async {
    // Update route duration
    try {
      final timeDistance = await TrackingService.calculateETA(
        widget.order.id!,
        widget.order.driverId!,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() {
        print('timeDistance: ${timeDistance['eta_minutes']}');
        _timeDistance = TimeModel(
          time: '${timeDistance['eta_minutes']} min',
          distance: '${timeDistance['distance_km']} km',
        );
        _gettingTimeDistance = false;
      });

      // Update route points if significantly different
      if (_shouldUpdateRoute(position)) {
        // Get new route points
        _routePoints = await RouteService.getRoutePoints(position, _destination);

        // Update polyline
        setState(() {
          _polylines.clear();
          drawPolyline();
        });

        // Update GPX file for the new route
        _gpxFilePath = await RouteService.getOrCreateGpxFile(
          position,
          _destination,
          widget.order.id?.toString() ?? 'route-${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } catch (e) {
      print('Error updating route: $e');
    }
  }

  /// Determine if route needs to be recalculated based on distance from original path
  bool _shouldUpdateRoute(LatLng currentPosition) {
    // If no route points yet, always update
    if (_routePoints == null || _routePoints!.isEmpty) {
      return true;
    }

    // Find closest point on current route
    double minDistance = double.infinity;
    for (var point in _routePoints!) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        point.latitude,
        point.longitude
      );

      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    // If driver is more than 50 meters from route, update route
    return minDistance > 50;
  }

  /// Set up the route simulation
  Future<void> setupRouteSimulation() async {
    try {
      // Get route points for polyline
      _routePoints = await RouteService.getRoutePoints(_location, _destination);

      // Draw the polyline
      drawPolyline();

      // Get or create GPX file for the route
      _gpxFilePath = await RouteService.getOrCreateGpxFile(
        _location,
        _destination,
        widget.order.id?.toString() ?? 'route',
      );
    } catch (e) {
      print('Error setting up route simulation: $e');
    }
  }

  /// Draw the polyline on the map
  void drawPolyline() {
    if (_routePoints == null || _routePoints!.isEmpty) return;

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("routePolyline"),
          visible: true,
          geodesic: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: _routePoints!,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  /// Toggle simulation on/off
  void toggleSimulation() {
    if (_isSimulating) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }

  /// Start the driver movement simulation
  void startSimulation() {
    if (_gpxFilePath == null) return;

    setState(() {
      _isSimulating = true;
      _simulationProgress = 0.0;
    });

    // Cancel any existing timer
    _simulationTimer?.cancel();

    // Stop real-time tracking if active
    stopRealTimeLocationTracking();

    // Start a timer to update the driver's position
    _simulationTimer = Timer.periodic(
      Duration(seconds: _simulationUpdateInterval.toInt()),
      (timer) async {
        // Update progress
        setState(() {
          _simulationProgress += _simulationUpdateInterval / _simulationDuration;

          // Stop when complete
          if (_simulationProgress >= 1.0) {
            _simulationProgress = 1.0;
            stopSimulation();
          }
        });

        // Update driver position
        await updateDriverPosition();
      },
    );
  }

  /// Stop the simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
    setState(() {
      _isSimulating = false;
    });
  }

  /// Update the driver's position based on the current progress
  Future<void> updateDriverPosition() async {
    if (_gpxFilePath == null) return;

    try {
      // Get the new position
      final newPosition = await RouteService.simulateDriverPosition(
        _gpxFilePath!,
        _simulationProgress,
      );

      // Update the marker
      updateDriverMarker(newPosition);
    } catch (e) {
      print('Error updating driver position: $e');
    }
  }

  Future<void> getAddress() async {
    try {
      List<Location> locations = await locationFromAddress(
        widget.order.address.fullAddress,
      );
      final latLng = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );
      setState(() {
        _destination = latLng;
      });
    } catch (e) {
      print('Error getting location from address: $e');
    }
  }

  Future<void> getRouteDuration() async {
    try {
      print("position: ${_location.longitude}");
      final timeDistance = await TrackingService.calculateETA(
        widget.order.id!,
        widget.order.driverId ?? 0,
        latitude: _location.latitude,
        longitude: _location.longitude
      );
      setState(() {
        _timeDistance = TimeModel(
          time: '${timeDistance['eta_minutes']} min',
          distance: '${timeDistance['distance_km']} km',
        );
        _gettingTimeDistance = false;
      });
    } catch (e) {
      setState(() {
        _gettingTimeDistance = false;
      });
      print('Error getting route duration: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    // Cancel the simulation timer
    _simulationTimer?.cancel();
    // Cancel location subscription
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rota até o cliente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      markers: _markers.values.toSet(),
                      polylines: _polylines,
                      initialCameraPosition: CameraPosition(
                        target: _location,
                        zoom: 14.0,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tokens.spacing20,
                      vertical: Tokens.spacing20,
                    ),
                    color: theme.colorScheme.surface,
                    child:
                        _gettingTimeDistance
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                              children: [
                                Text('Tempo estimado: ${_timeDistance?.time ?? 'Sem estimativa'}'),
                                Text('Distância: ${_timeDistance?.distance ?? 'Sem estimativa'}'),
                                const SizedBox(height: Tokens.spacing12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: toggleSimulation,
                                      child: Text(_isSimulating ? 'Parar simulação' : 'Simular rota'),
                                    ),
                                    const SizedBox(width: Tokens.spacing12),
                                    ElevatedButton(
                                      onPressed: _useRealTimeLocation ? stopRealTimeLocationTracking : startRealTimeLocationTracking,
                                      child: Text(_useRealTimeLocation ? 'Parar GPS real' : 'Usar GPS real'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  ),
                ],
              ),
    );
  }
}
