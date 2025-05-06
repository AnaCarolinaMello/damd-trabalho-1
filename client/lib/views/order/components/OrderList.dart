import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/order/components/OrderCard.dart';

class OrderList extends StatelessWidget {
  final List<Order> orders;
  final bool isActive;

  const OrderList({
    super.key,
    required this.orders,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return orders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.shopping_bag_outlined : Icons.history,
                  size: Tokens.fontSize24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: Tokens.spacing16),
                Text(
                  isActive
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
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: Tokens.spacing12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order, isActive: isActive);
            },
          );
  }
}