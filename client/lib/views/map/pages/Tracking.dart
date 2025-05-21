import 'dart:async';
import 'dart:convert';

import 'package:damd_trabalho_1/models/Driver.dart' as DriverModel;
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/views/map/components/Driver.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/controllers/driver.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:damd_trabalho_1/services/Route.dart';

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

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void init() async {
    await getDriver();
    await getAddress();
    await setupRouteSimulation();
    await getRouteDuration();
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

  /// Set up the route simulation
  Future<void> setupRouteSimulation() async {
    try {
      // Get or create GPX file for the route
      _gpxFilePath = await RouteService.getOrCreateGpxFile(
        _location,
        _destination,
        widget.order.id ?? 'route',
      );

      // Get route points for polyline
      _routePoints = await RouteService.getRoutePoints(_location, _destination);

      // Draw the polyline
      drawPolyline();

      // Start the simulation
      startSimulation();
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

    // Start a timer to update the driver's position
    _simulationTimer = Timer.periodic(
      Duration(seconds: _simulationUpdateInterval.toInt()),
      (timer) async {
        // Update progress
        setState(() {
          _simulationProgress += _simulationUpdateInterval / _simulationDuration;

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

      // Update the map
      setState(() {
        _location = newPosition;

        // Update the marker
        _markers['Localização do motorista'] = Marker(
          markerId: const MarkerId('Localização do motorista'),
          position: newPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(
            title: 'Localização do motorista',
            snippet: 'Localização do motorista',
          ),
        );
      });

      // Move the camera to follow the driver
      mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
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
    final orderDriver = await DriverController.getDriver(driverId!);
    setState(() {
      driver = orderDriver;
    });
  }

  Future<void> getRouteDuration() async {
    try {
      final duration = await RouteService.getRouteDuration(
        _location,
        _destination,
      );
      driver?.arrivalTime = duration?.time;
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
