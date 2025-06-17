import 'dart:async';

import 'package:damd_trabalho_1/models/Driver.dart' as DriverModel;
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/views/map/components/Driver.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/controllers/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:damd_trabalho_1/services/Route.dart';
import 'package:damd_trabalho_1/controllers/tracking.dart';

class Tracking extends StatefulWidget {
  final Order order;
  const Tracking({super.key, required this.order});

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  bool isDarkMode = false;
  bool isLoading = true;
  late GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late LatLng _destination = const LatLng(40.6782, -73.9442);
  late LatLng _location = const LatLng(40.6944, -73.9212);
  DriverModel.Driver? driver;

  // GPX route simulation variables
  String? _gpxFilePath;
  List<LatLng>? _routePoints;
  double _simulationProgress = 0.0;
  Timer? _simulationTimer;
  final double _simulationDuration = 180; // 3 minutes in seconds
  final double _simulationUpdateInterval = 1; // Update every second

  // Real-time location tracking variables
  StreamSubscription<Position>? _locationSubscription;
  bool _useRealTimeLocation = false;

  // Tracking service integration
  Timer? _trackingUpdateTimer;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void init() async {
    await getDriver();
    await getAddress();
    await updateDriverLocationFromService();
    await setupRouteSimulation();
    await getRouteDuration();
    getMakers();
    await initializeTracking();
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
        markerId: const MarkerId('Localização do motorista'),
        position: LatLng(_location.latitude, _location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: const InfoWindow(
          title: 'Localização do motorista',
          snippet: 'Localização do motorista',
        ),
      );
      _markers[widget.order.address.fullAddress] = marker;
      _markers['Localização do motorista'] = marker2;
      isLoading = false;
    });
  }

  /// Start tracking the driver's real location instead of simulating
  Future<void> startRealTimeLocationTracking() async {
    // Cancel simulation if running
    _simulationTimer?.cancel();
    _locationSubscription?.cancel();

    // Check location permissions
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
    updateDriverMarker(LatLng(position.latitude, position.longitude));

    // Subscribe to location updates
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      if (_useRealTimeLocation) {
        // Update driver position with real GPS location
        updateDriverMarker(LatLng(position.latitude, position.longitude));
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
  void updateDriverMarker(LatLng position) {
    setState(() {
      print('position: $position');
      _location = position;

      // Update the marker
      _markers['Localização do motorista'] = Marker(
        markerId: const MarkerId('Localização do motorista'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: const InfoWindow(
          title: 'Localização do motorista',
          snippet: 'Localização do motorista',
        ),
      );
    });

    // Move the camera to follow the driver
    mapController.animateCamera(CameraUpdate.newLatLng(position));

    // Recalculate route duration if needed
    updateRouteDuration();

    // Update tracking service with new position
    updateTrackingService(position);
  }

  /// Initialize tracking service integration
  Future<void> initializeTracking() async {
    try {
      if (widget.order.driverId != null && widget.order.customerId != null) {
        // Create initial tracking record
        await TrackingService.updateDeliveryStatus(
          orderId: widget.order.id!,
          driverId: widget.order.driverId!,
          customerId: widget.order.customerId,
          status: Status.accepted,
          latitude: _destination.latitude,
          longitude: _destination.longitude,
          destinationAddress: widget.order.address.fullAddress,
          notes: 'Entrega iniciada',
        );

        // Start periodic updates to get real driver location
        startTrackingUpdates();
      }
    } catch (e) {
      print('Error initializing tracking: $e');
    }
  }

  /// Start periodic updates from tracking service
  void startTrackingUpdates() {
    _trackingUpdateTimer?.cancel();

    _trackingUpdateTimer = Timer.periodic(const Duration(minutes: 2), (
      timer,
    ) async {
      await updateDriverLocationFromService();
    });
  }

  /// Update driver location from tracking service
  Future<void> updateDriverLocationFromService() async {
    try {
      if (widget.order.driverId != null) {
        final location = await TrackingService.getDriverLocation(
          widget.order.driverId!,
        );
        if (location['latitude'] != null && location['longitude'] != null) {
          final newPosition = LatLng(
            double.parse(location['latitude'].toString()),
            double.parse(location['longitude'].toString()),
          );
          // Only update if we're not using real-time GPS
          updateDriverMarker(newPosition);
        }
      }
    } catch (e) {
      print('Error getting driver location from service: $e');
    }
  }

  /// Update tracking service with current position
  Future<void> updateTrackingService(LatLng position) async {
    try {
      if (widget.order.driverId != null && _useRealTimeLocation) {
        await TrackingService.updateDriverLocation(
          driverId: widget.order.driverId!,
          orderId: widget.order.id,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      print('Error updating tracking service: $e');
    }
  }

  /// Update the route duration based on new driver position
  Future<void> updateRouteDuration() async {
    try {
      final duration = await TrackingService.calculateETA(
        widget.order.id!,
        widget.order.driverId!,
      );
      setState(() {
        driver?.arrivalTime = '${duration['eta_minutes']} min';
      });
    } catch (e) {
      print('Error updating route duration: $e');
    }
  }

  /// Set up the route simulation
  Future<void> setupRouteSimulation() async {
    try {
      // Get or create GPX file for the route
      _gpxFilePath = await RouteService.getOrCreateGpxFile(
        _location,
        _destination,
        widget.order.id?.toString() ?? 'route',
      );

      // Get route points for polyline
      _routePoints = await RouteService.getRoutePoints(_location, _destination);

      // Draw the polyline
      drawPolyline();

      // Start the simulation
      // startSimulation();
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

  /// Start the driver movement simulation
  void startSimulation() {
    if (_gpxFilePath == null) return;

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
          _simulationProgress +=
              _simulationUpdateInterval / _simulationDuration;

          // Reset when complete
          if (_simulationProgress >= 1.0) {
            _simulationProgress = 0.0;
          }
        });

        // Update driver position
        await updateDriverPosition();
      },
    );
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

  Future<void> getDriver() async {
    final driverId = widget.order.driverId;
    final orderDriver = await UserController.getUserById(driverId!);
    setState(() {
      driver = DriverModel.Driver.fromJson(orderDriver!.toJson());
      print('driver: ${driver?.id}');
    });
  }

  Future<void> getRouteDuration() async {
    try {
      final duration = await TrackingService.calculateETA(
        widget.order.id!,
        widget.order.driverId!,
      );
      driver?.arrivalTime = '${duration['eta_minutes']} min';
    } catch (e) {
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
    // Cancel tracking updates
    _trackingUpdateTimer?.cancel();
    super.dispose();
  }

  // Informações da viagem
  final String pickupPoint = 'Ponto de encontro: Shopping Center';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acompanhe seu pedido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Map showing real-time driver movement
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

                  // Driver information card
                  Driver(driver: driver!),
                ],
              ),
    );
  }
}
