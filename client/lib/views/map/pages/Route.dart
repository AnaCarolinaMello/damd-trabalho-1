import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/services/Route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
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
  GoogleMapsPolyline polyline = GoogleMapsPolyline();
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late LatLng _destination = const LatLng(40.6782, -73.9442);
  late LatLng _location = const LatLng(40.6944, -73.9212);
  TimeModel? _timeDistance;
  bool _gettingTimeDistance = true;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void init() async {
    await getCurrentLocation();
    await getAddress();
    await getRouteDuration();
    await getRoute();
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
        markerId: MarkerId('Sua localização'),
        position: LatLng(_location.latitude, _location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(
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

    print('serviceEnabled: $serviceEnabled');

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
    print('position: $position');
    setState(() {
      _location = LatLng(position.latitude, position.longitude);
    });
  }

  getRoute() async {
    final result = await polyline.getRouteBetweenCoordinates(
      "<YOUR_API_KEY>",
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

  Future<void> getRouteDuration() async {
    try {
      final timeDistance = await RouteService.getRouteDuration(
        _location,
        _destination,
      );
      setState(() {
        _timeDistance = timeDistance;
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
                              ],
                            ),
                  ),
                ],
              ),
    );
  }
}
