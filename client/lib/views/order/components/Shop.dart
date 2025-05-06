import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/utils/index.dart';

class Shop extends StatelessWidget {
  final Order order;
  final bool isActive;
  final EdgeInsets? padding;

  const Shop({
    super.key,
    required this.order,
    required this.isActive,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.all(Tokens.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone do estabelecimento
          Container(
            width: Tokens.spacing64,
            height: Tokens.spacing64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(Tokens.radius12),
            ),
            child: Icon(
              Utils.getIconForOrderType(order.name),
              size: Tokens.fontSize32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: Tokens.spacing16),
          
          // Informações do estabelecimento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Tokens.fontSize20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: Tokens.spacing4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: Tokens.fontSize16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: Tokens.spacing4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Tokens.fontSize14,
                      ),
                    ),
                    const SizedBox(width: Tokens.spacing8),
                    Text(
                      '• Delivery: 15-25 min',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: Tokens.fontSize14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Tokens.spacing4),
                if (!isActive && order.isRated) ...[
                  const SizedBox(height: Tokens.spacing8),
                  Row(
                    children: [
                      Text(
                        'Sua avaliação: ',
                        style: TextStyle(
                          fontSize: Tokens.fontSize14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < order.rating
                              ? Icons.star
                              : (index == order.rating.floor() && 
                                 order.rating % 1 > 0)
                                  ? Icons.star_half
                                  : Icons.star_border,
                          size: Tokens.fontSize16,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}