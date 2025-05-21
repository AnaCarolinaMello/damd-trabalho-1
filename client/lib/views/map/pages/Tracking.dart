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
  GoogleMapsPolyline polyline = GoogleMapsPolyline();
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late LatLng _destination = const LatLng(40.6782, -73.9442);
  late LatLng _location = const LatLng(40.6944, -73.9212);
  DriverModel.Driver? driver;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void init() async {
    await getDriver();
    await getAddress();
    await getRoute();
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
        markerId: MarkerId('Localização do motorista'),
        position: LatLng(_location.latitude, _location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(
          title: 'Localização do motorista',
          snippet: 'Localização do motorista',
        ),
      );
      _markers[widget.order.address.fullAddress] = marker;
      _markers['Localização do motorista'] = marker2;
      isLoading = false;
    });
  }

  getRoute() async {
    final result = await polyline.getRouteBetweenCoordinates(
      "<YOUR_APIKEY>",
      MyPointLatLng(_destination.latitude, _destination.longitude),
      MyPointLatLng(_location.latitude, _location.longitude),
      travelMode: MyTravelMode.driving,
    );
    if (result.status == "OK" && result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude!, point.longitude!));
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("polylineIdString"),
            visible: true,
            geodesic: true,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
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
                  // Desenho simulado de estrada
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

                  // Card inferior com detalhes do motorista
                  Driver(driver: driver!),
                ],
              ),
    );
  }
}
