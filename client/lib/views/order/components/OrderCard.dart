import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/components/Card.dart';
import 'package:damd_trabalho_1/views/order/components/OrderStatus.dart';
import 'package:damd_trabalho_1/views/order/components/OrderActions.dart';
import 'package:damd_trabalho_1/utils/index.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isActive;
  final Function(Order) orderAgain;
  final Function(Order, double) rateOrder;

  const OrderCard({super.key, required this.order, required this.isActive, required this.orderAgain, required this.rateOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Column(
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
                    Utils.getIconForOrderType(order.name),
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
                            order.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Tokens.fontSize16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'R\$ ${order.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Tokens.fontSize16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Tokens.spacing4),
                      Row(
                        children: [
                          Text(
                            order.description,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: Tokens.fontSize14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${order.date} ${order.time}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: Tokens.fontSize14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Informações de status
          OrderStatus(order: order, isActive: isActive),

          // Separador
          Divider(
            height: Tokens.borderSize1,
            thickness: Tokens.borderSize1,
            color: theme.colorScheme.surfaceVariant,
          ),

          // Botões de ação
          OrderActions(order: order, isActive: isActive, orderAgain: () => orderAgain(order), rateOrder: rateOrder),
        ],
      ),
    );
  }
}
