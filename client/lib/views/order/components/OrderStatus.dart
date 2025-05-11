import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/utils/index.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/order/components/Status.dart';

class OrderStatus extends StatelessWidget {
  final Order order;
  final bool isActive;

  const OrderStatus({
    super.key,
    required this.order,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.spacing16,
        vertical: Tokens.spacing12
      ),
      color: isActive 
        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
        : theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Row(
        children: [
          Status(order: order, isActive: isActive),
          const Spacer(),
          if (isActive)
            SizedBox()
          else if (order.rating != 0)
            Row(
              children: [
                Text(
                  'Você avaliou ',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: Tokens.fontSize14,
                  ),
                ),
                const SizedBox(width: Tokens.spacing4),
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < order.rating
                        ? Icons.star
                        : (index == order.rating.floor() && order.rating % 1 > 0)
                            ? Icons.star_half
                            : Icons.star_border,
                    size: Tokens.fontSize16,
                    color: Colors.amber,
                  ),
                ),
              ],
            )
          else
            SizedBox()
        ],
      ),
    );
  }
}