import 'package:damd_trabalho_1/controllers/tracking.dart';
import 'package:damd_trabalho_1/models/Time.dart';
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/services/Route.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EstimateTime extends StatefulWidget {
  final Order order;
  const EstimateTime({super.key, required this.order});

  @override
  State<EstimateTime> createState() => _EstimateTimeState();
}

class _EstimateTimeState extends State<EstimateTime> {
  late LatLng _destination = const LatLng(40.6782, -73.9442);
  late LatLng _location = const LatLng(40.6944, -73.9212);
  TimeModel? _timeDistance;

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

  void init() async {
    try {
      await getAddress();
      final timeDistance = await TrackingService.calculateETA(
        widget.order.id!,
        widget.order.driverId!,
      );
      setState(() {
        _timeDistance = TimeModel(
          time: '${timeDistance['eta_minutes']} min',
          distance: '${timeDistance['distance_km']} km',
        );
      });
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Tokens.spacing8,
        horizontal: Tokens.spacing12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Tokens.radius8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: Tokens.fontSize16,
          ),
          const SizedBox(width: Tokens.spacing4),
          Text(
            'Entrega estimada: ${_timeDistance?.time ?? 'Sem estimativa'}',
            style: TextStyle(
              fontSize: Tokens.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}