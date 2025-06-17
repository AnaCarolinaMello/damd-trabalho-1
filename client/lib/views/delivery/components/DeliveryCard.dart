import 'package:damd_trabalho_1/controllers/tracking.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:damd_trabalho_1/services/Route.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/components/Card.dart';
import 'package:damd_trabalho_1/components/ActionButton.dart';
import 'package:damd_trabalho_1/utils/index.dart';
import 'package:damd_trabalho_1/controllers/order.dart';
import 'package:damd_trabalho_1/models/User.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:damd_trabalho_1/views/map/pages/Route.dart';

class DeliveryCard extends StatefulWidget {
  final Order? order;

  const DeliveryCard({super.key, required this.order});

  @override
  State<DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends State<DeliveryCard> {
  bool loading = false;

  void acceptOrder() async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(jsonDecode(prefs.getString('user') ?? '{}'));
    final position = await TrackingService.getCurrentLocation();
    List<Location> locations = await locationFromAddress(
      widget.order!.address.fullAddress,
    );
    final latLng = await RouteService.getLatAndLngByAddress(widget.order!.address);

    await OrderController.acceptOrder(widget.order!.id!, user.id!);
    await TrackingService.updateDeliveryStatus(
      orderId: widget.order!.id!,
      driverId: user.id!,
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      status: Status.accepted,
      destinationAddress: widget.order!.address.fullAddress,
    );
    await TrackingService.updateDriverLocation(
      driverId: user.id!,
      orderId: widget.order!.id!,
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed,
      heading: position.heading,
      accuracy: position.accuracy,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(item: 'orders')),
    );
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Cabeçalho do card
          Padding(
            padding: const EdgeInsets.all(Tokens.spacing16),
            child: Row(
              children: [
                // Ícone do estabelecimento
                Container(
                  width: Tokens.spacing48,
                  height: Tokens.spacing48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Tokens.radius8),
                  ),
                  child: Icon(
                    Utils.getIconForOrderType(widget.order!.name),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: Tokens.spacing12),

                // Detalhes do pedido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.order!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Tokens.fontSize16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'R\$ ${widget.order!.deliveryFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Tokens.fontSize16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Tokens.spacing4),
                      Text(
                        '${DateTime.tryParse(widget.order!.date)?.day ?? 0}/${DateTime.tryParse(widget.order!.date)?.month ?? 0}/${DateTime.tryParse(widget.order!.date)?.year ?? 0} ${widget.order!.time.split(':')[0]}:${widget.order!.time.split(':')[1]}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: Tokens.fontSize14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: Tokens.spacing16,
              right: Tokens.spacing16,
              bottom: Tokens.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.order!.address.shortAddress,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  widget.order!.address.cityState,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Separador
          Divider(
            height: Tokens.borderSize1,
            thickness: Tokens.borderSize1,
            color: theme.colorScheme.surfaceVariant,
          ),

          // Botões de ação
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Tokens.spacing8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  label: 'Ver rota',
                  icon: Icons.map_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutePage(order: widget.order!),
                      ),
                    );
                  },
                ),
                ActionButton(
                  label: 'Aceitar',
                  isPrimary: true,
                  icon: Icons.check_circle_outline,
                  onTap: acceptOrder,
                  loading: loading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
