import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/order/pages/OrderTracking.dart';
import 'package:damd_trabalho_1/views/order/components/Rate.dart';
import 'package:damd_trabalho_1/views/order/components/Rating.dart';
import 'package:damd_trabalho_1/views/order/components/OrderItems.dart';
import 'package:damd_trabalho_1/views/order/components/OrderSummary.dart';
import 'package:damd_trabalho_1/components/IconButton.dart';
import 'package:damd_trabalho_1/views/order/components/Address.dart';
import 'package:damd_trabalho_1/views/order/components/Status.dart';
import 'package:damd_trabalho_1/views/order/components/Shop.dart';
import 'package:damd_trabalho_1/views/order/components/EstimateTime.dart';
import 'package:damd_trabalho_1/views/order/components/SeeMap.dart';
import 'package:damd_trabalho_1/services/TrackingService.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart' as OrderStatus;
import 'dart:async';


class OrderDetail extends StatefulWidget {
  final Order order;
  final bool isActive;
  final Function() orderAgain;
  final Function(Order, double) rateOrder;

  const OrderDetail({super.key, required this.order, this.isActive = false, required this.orderAgain, required this.rateOrder});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  Order? order;
  bool isLoading = true;
  Timer? _trackingTimer;
  Map<String, dynamic>? deliveryData;
  double? distanceKm;
  int? etaMinutes;
  bool _isLoadingTracking = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    if (widget.isActive) {
      _startTrackingUpdates();
    }
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _startTrackingUpdates() {
    // Atualizar tracking a cada 15 segundos para pedidos ativos
    _trackingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _loadDeliveryTracking();
    });

    // Primeira carga imediata
    _loadDeliveryTracking();
  }

  Future<void> _loadOrder() async {
    setState(() {
      order = widget.order;
      isLoading = false;
    });
  }

  Future<void> _loadDeliveryTracking() async {
    if (!widget.isActive || order?.id == null || order?.customerId == null || _isLoadingTracking) {
      return;
    }

    setState(() {
      _isLoadingTracking = true;
    });

    try {
      // Obter dados de tracking da entrega
      final tracking = await TrackingService.getDeliveryLocation(
        order!.id!,
        order!.customerId!,
      );

      if (tracking != null) {
        setState(() {
          deliveryData = tracking;
        });

        // Se temos localização do motorista, calcular ETA
        if (order!.driverId != null) {
          try {
            final eta = await TrackingService.calculateETA(
              order!.id!,
              order!.driverId!,
            );

            if (eta != null) {
              setState(() {
                distanceKm = eta['distance_km']?.toDouble();
                etaMinutes = eta['eta_minutes']?.toInt();
              });
            }
          } catch (e) {
            print('Erro ao calcular ETA: $e');
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar tracking: $e');
    } finally {
      setState(() {
        _isLoadingTracking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedido #${order!.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              color:
                  widget.isActive
                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Status(order: order!, isActive: widget.isActive),
                  const SizedBox(height: Tokens.spacing4),
                  Text(
                    '${DateTime.tryParse(order!.date)?.day ?? 0}/${DateTime.tryParse(order!.date)?.month ?? 0}/${DateTime.tryParse(order!.date)?.year ?? 0} ${order!.time.split(':')[0]}:${order!.time.split(':')[1]}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: Tokens.fontSize14,
                    ),
                  ),

                  if (widget.isActive) ...[
                    const SizedBox(height: Tokens.spacing16),
                    EstimateTime(order: order!),

                    // Informações de tracking em tempo real
                    if (distanceKm != null || etaMinutes != null) ...[
                      const SizedBox(height: Tokens.spacing12),
                      Container(
                        padding: const EdgeInsets.all(Tokens.spacing12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: Tokens.spacing4),
                                Text(
                                  'Informações de Entrega',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Tokens.fontSize14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (_isLoadingTracking) ...[
                                  const SizedBox(width: Tokens.spacing8),
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: Tokens.spacing8),
                            Row(
                              children: [
                                if (distanceKm != null) ...[
                                  Icon(
                                    Icons.straighten,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: Tokens.spacing4),
                                  Text(
                                    'Distância: ${distanceKm!.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      fontSize: Tokens.fontSize12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                if (distanceKm != null && etaMinutes != null)
                                  const SizedBox(width: Tokens.spacing16),
                                if (etaMinutes != null) ...[
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: Tokens.spacing4),
                                  Text(
                                    'ETA: ${etaMinutes!} min',
                                    style: TextStyle(
                                      fontSize: Tokens.fontSize12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // Detalhes do estabelecimento
            Shop(order: order!, isActive: widget.isActive),

            const Divider(),

            if (widget.order.image != null && widget.order.image!.isNotEmpty) ...[
              Image.memory(
                widget.order.image!,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              const Divider(),
            ],

            // Itens do pedido
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Tokens.spacing16,
                vertical: Tokens.spacing8,
              ),
              child: Text(
                'Itens do Pedido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Tokens.fontSize16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            // Lista de itens
            OrderItems(items: order!.items),

            // Resumo de valores
            Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: OrderSummary(order: order!),
            ),

            const Divider(),

            // Endereço de entrega
            AddressComponent(address: order!.address),

            // Botão de rastreamento para pedidos ativos
            if (widget.isActive)
              Padding(
                padding: const EdgeInsets.all(Tokens.spacing16),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomIconButton(
                    icon: Icons.map_outlined,
                    label: 'Rastrear Pedido',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTracking(order: order!),
                        ),
                      );
                    },
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: SeeMap(status: order!.status, order: order!, noPadding: true),
            ),

            // Avaliação ou botões para pedidos entregues
            if (!widget.isActive) ...[
              const SizedBox(height: Tokens.spacing16),
              if (order!.rating == 0)
                Rate(
                  rateOrder: (rating) async {
                    await widget.rateOrder(order!, rating);
                    setState(() {
                      order!.rating = rating;
                    });
                  },
                )
              else
                Rating(
                  orderAgain: widget.orderAgain,
                ),
            ],

            const SizedBox(height: Tokens.spacing24),
          ],
        ),
      ),
    );
  }
}
