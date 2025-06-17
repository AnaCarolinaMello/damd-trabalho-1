import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/order/components/Status.dart';
import 'package:damd_trabalho_1/views/order/components/Shop.dart';
import 'package:damd_trabalho_1/views/order/components/EstimateTime.dart';
import 'package:damd_trabalho_1/views/order/components/Address.dart';
import 'package:damd_trabalho_1/views/order/components/SummaryItem.dart';
import 'package:damd_trabalho_1/components/IconButton.dart';
import 'package:damd_trabalho_1/views/delivery/pages/Finish.dart';
import 'package:damd_trabalho_1/views/map/pages/Route.dart';
import 'package:damd_trabalho_1/controllers/tracking.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart' as OrderStatus;
import 'dart:async';

class Delivery extends StatefulWidget {
  const Delivery({super.key, required this.order});

  final Order order;

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  Timer? _locationTimer;
  bool _isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _updateOrderStatusIfAccepted();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _updateDriverLocation();
    });

    _updateDriverLocation();
  }

  Future<void> _updateDriverLocation() async {
    if (_isUpdatingLocation) return;

    setState(() {
      _isUpdatingLocation = true;
    });

    try {
      final position = await TrackingService.getCurrentLocation();

      if (widget.order.driverId != null) {
        await TrackingService.updateDriverLocation(
          driverId: widget.order.driverId!,
          orderId: widget.order.id,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: position.speed,
          heading: position.heading,
          accuracy: position.accuracy,
        );
      }
    } catch (e) {
      print('Erro ao atualizar localização: $e');
    } finally {
      setState(() {
        _isUpdatingLocation = false;
      });
    }
  }

  Future<void> _updateOrderStatusIfAccepted() async {
    // Se o pedido foi aceito, atualizar o status no tracking
    try {
      final position = await TrackingService.getCurrentLocation();

      await TrackingService.updateDriverLocation(
        orderId: widget.order.id!,
        driverId: widget.order.driverId!,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
        accuracy: position.accuracy,
      );
    } catch (e) {
      print('Erro ao atualizar status do pedido: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Status(order: widget.order, isActive: true),
                  const SizedBox(height: Tokens.spacing4),
                  Text(
                    '${DateTime.tryParse(widget.order.date)?.day ?? 0}/${DateTime.tryParse(widget.order.date)?.month ?? 0}/${DateTime.tryParse(widget.order.date)?.year ?? 0} ${widget.order.time.split(':')[0]}:${widget.order.time.split(':')[1]}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: Tokens.fontSize14,
                    ),
                  ),

                  const SizedBox(height: Tokens.spacing16),
                  EstimateTime(order: widget.order),

                  if (_isUpdatingLocation) ...[
                    const SizedBox(height: Tokens.spacing8),
                    Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: Tokens.spacing8),
                        Text(
                          'Atualizando localização...',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: Tokens.fontSize12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Detalhes do estabelecimento
            Shop(order: widget.order, isActive: true),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: SummaryItem(
                label: 'Total',
                value: 'R\$ ${widget.order.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ),

            const Divider(),

            AddressComponent(address: widget.order.address),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: CustomIconButton(
                icon: Icons.check_circle_outline,
                label: 'Finalizar Entrega',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinishDelivery(order: widget.order),
                    ),
                  );

                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrega finalizada com sucesso!'),
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: CustomIconButton(
                icon: Icons.check_circle_outline,
                label: 'Ver rota',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutePage(order: widget.order),
                    ),
                  );

                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrega finalizada com sucesso!'),
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
