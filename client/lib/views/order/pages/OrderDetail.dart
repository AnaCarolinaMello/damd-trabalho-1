import 'package:damd_trabalho_1/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/controllers/order.dart';
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

class OrderDetail extends StatefulWidget {
  final String orderId;
  final bool isActive;
  
  const OrderDetail({
    super.key,
    required this.orderId,
    this.isActive = false,
  });

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  late Order order;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final loadedOrder = await OrderController.getOrder(widget.orderId);
    setState(() {
      order = loadedOrder;
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedido #${widget.orderId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
              color: widget.isActive 
                ? theme.colorScheme.primaryContainer.withOpacity(0.3) 
                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Status(order: order, isActive: widget.isActive),
                  const SizedBox(height: Tokens.spacing4),
                  Text(
                    '${order.date} ${order.time}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: Tokens.fontSize14,
                    ),
                  ),
                  
                  if (widget.isActive) ...[
                    const SizedBox(height: Tokens.spacing16),
                    EstimateTime(order: order),
                  ],
                ],
              ),
            ),
            
            // Detalhes do estabelecimento
            Shop(order: order, isActive: widget.isActive),

            const Divider(),
            
            // Itens do pedido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tokens.spacing16, vertical: Tokens.spacing8),
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
            OrderItems(items: order.items),
            
            // Resumo de valores
            Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: OrderSummary(order: order),
            ),
            
            const Divider(),
            
            // Endereço de entrega
            AddressComponent(order: order),
            
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
                          builder: (context) => OrderTracking(
                            order: order,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
            // Avaliação ou botões para pedidos entregues
            if (!widget.isActive) ...[
              const SizedBox(height: Tokens.spacing16),
              if (!order.isRated) 
                Rate(onRatingSubmit: (rating) {
                  // Implementar ação de avaliação
                })
              else 
                Rating(orderAgain: () {
                  // Implementar ação de pedir novamente
                }),
            ],
            
            const SizedBox(height: Tokens.spacing24),
          ],
        ),
      ),
    );
  }
} 