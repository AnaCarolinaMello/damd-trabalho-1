import 'package:damd_trabalho_1/models/enum/Status.dart' as OrderStatus;
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderStep.dart';
import 'package:damd_trabalho_1/views/order/components/Track.dart';
import 'package:damd_trabalho_1/views/order/components/TrackActions.dart';
import 'package:damd_trabalho_1/views/order/components/OrderResume.dart';
import 'package:damd_trabalho_1/views/order/components/Status.dart';
import 'package:damd_trabalho_1/views/order/components/SeeMap.dart';
import 'package:damd_trabalho_1/services/TrackingService.dart';
import 'dart:async';

class OrderTracking extends StatefulWidget {
  final Order order;
  final List<OrderStep>? customSteps;

  const OrderTracking({super.key, required this.order, this.customSteps});

  @override
  State<OrderTracking> createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  Timer? _trackingTimer;
  List<dynamic> trackingHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadTrackingHistory();
    _startTrackingUpdates();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _startTrackingUpdates() {
    // Atualizar histórico a cada 10 segundos
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadTrackingHistory();
    });
  }

  Future<void> _loadTrackingHistory() async {
    if (widget.order.id == null || widget.order.customerId == null || _isLoadingHistory) {
      return;
    }

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await TrackingService.getDeliveryHistory(
        widget.order.id!,
        widget.order.customerId!,
      );

      if (history != null && history is List) {
        setState(() {
          trackingHistory = history;
        });
      }
    } catch (e) {
      print('Erro ao carregar histórico de tracking: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obter os passos de progresso
    final progressSteps = widget.customSteps ?? _getDefaultSteps();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rastreamento do Pedido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número do pedido
              OrderResume(order: widget.order),

              const SizedBox(height: Tokens.spacing24),

              // Container de rastreamento
              Track(steps: progressSteps),

              // Histórico de tracking em tempo real
              if (trackingHistory.isNotEmpty) ...[
                const SizedBox(height: Tokens.spacing16),
                Container(
                  padding: const EdgeInsets.all(Tokens.spacing16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: Tokens.spacing8),
                          Text(
                            'Histórico de Entrega',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: Tokens.fontSize14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (_isLoadingHistory) ...[
                            const SizedBox(width: Tokens.spacing8),
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: Tokens.spacing12),
                      ...trackingHistory.map((tracking) => Padding(
                        padding: const EdgeInsets.only(bottom: Tokens.spacing8),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(tracking['status']),
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: Tokens.spacing8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getStatusText(tracking['status']),
                                    style: TextStyle(
                                      fontSize: Tokens.fontSize12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  if (tracking['notes'] != null) ...[
                                                                         Text(
                                       tracking['notes'],
                                       style: TextStyle(
                                         fontSize: Tokens.fontSize12,
                                         color: Theme.of(context).colorScheme.onSurfaceVariant,
                                       ),
                                     ),
                                  ],
                                ],
                              ),
                            ),
                                                         Text(
                               _formatTimestamp(tracking['timestamp']),
                               style: TextStyle(
                                 fontSize: Tokens.fontSize12,
                                 color: Theme.of(context).colorScheme.onSurfaceVariant,
                               ),
                             ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ],

              SeeMap(status: widget.order.status, order: widget.order),

              const SizedBox(height: Tokens.spacing24),

              // Botão para contatar atendimento
              TrackActions(),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.receipt_long;
      case 'accepted':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.inventory_2;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pedido Recebido';
      case 'accepted':
        return 'Pedido Aceito pelo Motorista';
      case 'preparing':
        return 'Em Preparação';
      case 'ready':
        return 'Pronto para Entrega';
      case 'out_for_delivery':
        return 'Saiu para Entrega';
      case 'delivered':
        return 'Entregue';
      default:
        return status;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  List<OrderStep> _getDefaultSteps() {
    return [
      OrderStep(
        title: 'Pedido Recebido',
        subtitle: 'Recebemos seu pedido',
        icon: Icons.receipt_long,
        isCompleted: true,
        time: '${widget.order.time.split(':')[0]}:${widget.order.time.split(':')[1]}',
      ),
      OrderStep(
        title: 'Pedido Confirmado',
        subtitle: 'Seu pedido foi confirmado',
        icon: Icons.check_circle,
        isCompleted: true,
        time: '${widget.order.time.split(':')[0]}:${widget.order.time.split(':')[1]}',
      ),
      OrderStep(
        title: 'Pedido em Preparação',
        subtitle: 'Estamos preparando seu pedido',
        icon: Icons.restaurant,
        isCompleted: true,
        time: '${widget.order.time.split(':')[0]}:${widget.order.time.split(':')[1]}',
      ),
      OrderStep(
        title: 'Pronto para Entrega',
        subtitle: 'Seu pedido está pronto',
        icon: Icons.inventory_2,
        isCompleted:
            widget.order.status == OrderStatus.Status.pending ||
            widget.order.status == OrderStatus.Status.accepted ||
            widget.order.status == OrderStatus.Status.delivered,
        time: '${widget.order.time.split(':')[0]}:${widget.order.time.split(':')[1]}',
      ),
      OrderStep(
        title: 'Saiu para Entrega',
        subtitle: 'Seu pedido está a caminho',
        icon: Icons.delivery_dining,
        isCompleted:
            widget.order.status == OrderStatus.Status.accepted || widget.order.status == OrderStatus.Status.delivered,
        time: '${widget.order.time.split(':')[0]}:${widget.order.time.split(':')[1]}',
      ),
      OrderStep(
        title: 'Entregue',
        subtitle: 'Seu pedido foi entregue',
        icon: Icons.check_circle,
        isCompleted: widget.order.status == OrderStatus.Status.delivered,
        time: '${widget.order.time.split(':')[0]}:${widget.order.time.split(':')[1]}',
      ),
    ];
  }
}
