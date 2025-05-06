import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/OrderStep.dart';
import 'package:damd_trabalho_1/views/order/components/Track.dart';
import 'package:damd_trabalho_1/views/order/components/TrackActions.dart';
import 'package:damd_trabalho_1/views/order/components/OrderResume.dart';
import 'package:damd_trabalho_1/models/Order.dart';

class OrderTracking extends StatelessWidget {
  final Order order;
  final List<OrderStep>? customSteps;
  
  const OrderTracking({
    super.key,
    required this.order,
    this.customSteps,
  });

  @override
  Widget build(BuildContext context) {
    // Obter os passos de progresso
    final progressSteps = customSteps ?? _getDefaultSteps();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rastreamento do Pedido',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
              OrderResume(order: order),

              const SizedBox(height: Tokens.spacing24),
              
              // Container de rastreamento
              Track(steps: progressSteps),
              
              const SizedBox(height: Tokens.spacing24),
              
              // Botão para contatar atendimento
              TrackActions(),
            ],
          ),
        ),
      ),
    );
  }
  
   List<OrderStep> _getDefaultSteps() {
    return [
      OrderStep(
        title: 'Pedido Recebido',
        subtitle: 'Recebemos seu pedido',
        icon: Icons.receipt_long,
        isCompleted: true,
        time: '12:30',
      ),
      OrderStep(
        title: 'Pedido Confirmado',
        subtitle: 'Seu pedido foi confirmado',
        icon: Icons.check_circle,
        isCompleted: true,
        time: '12:35',
      ),
      OrderStep(
        title: 'Pedido em Preparação',
        subtitle: 'Estamos preparando seu pedido',
        icon: Icons.restaurant,
        isCompleted: order.status != 'Pedido recebido',
        time: '12:40',
      ),
      OrderStep(
        title: 'Pronto para Entrega',
        subtitle: 'Seu pedido está pronto',
        icon: Icons.inventory_2,
        isCompleted: order.status == 'Saiu para entrega' || order.status == 'Entregue',
        time: '12:50',
      ),
      OrderStep(
        title: 'Saiu para Entrega',
        subtitle: 'Seu pedido está a caminho',
        icon: Icons.delivery_dining,
        isCompleted: order.status == 'Saiu para entrega' || order.status == 'Entregue',
        time: '13:00',
      ),
      OrderStep(
        title: 'Entregue',
        subtitle: 'Seu pedido foi entregue',
        icon: Icons.check_circle,
        isCompleted: order.status == 'Entregue',
        time: '13:15',
      ),
    ];
  }
} 