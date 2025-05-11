import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/order/components/OrderCard.dart';

class OrderList extends StatefulWidget {
  final List<Order> orders;
  final bool isActive;
  final Function(Order) orderAgain;
  final Function(Order, double) rateOrder;

  const OrderList({
    super.key,
    required this.orders,
    required this.isActive,
    this.orderAgain = _defaultOrderAgain,
    this.rateOrder = _defaultRateOrder,
  });

  static void _defaultOrderAgain(Order order) {}

  static void _defaultRateOrder(Order order, double rating) {}

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late List<Order> _orders;

  @override
  void initState() {
    super.initState();
    _orders = widget.orders;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return _orders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isActive ? Icons.shopping_bag_outlined : Icons.history,
                  size: Tokens.fontSize24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: Tokens.spacing16),
                Text(
                  widget.isActive
                      ? 'Nenhum pedido ativo'
                      : 'Nenhum pedido no histórico',
                  style: TextStyle(
                    fontSize: Tokens.spacing16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(Tokens.spacing16),
            itemCount: _orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: Tokens.spacing12),
            itemBuilder: (context, index) {
              final order = _orders[index];
              return OrderCard(order: order, isActive: widget.isActive, orderAgain: widget.orderAgain, rateOrder: widget.rateOrder);
            },
          );
  }
}