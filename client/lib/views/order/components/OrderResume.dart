import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/components/Card.dart';

class OrderResume extends StatelessWidget {
  final Order order;

  const OrderResume({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final productImage = Container(
      height: Tokens.spacing80,
      width: Tokens.spacing80,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Tokens.radius12),
      ),
      child: Icon(
        Icons.restaurant,
        size: Tokens.fontSize40,
        color: theme.colorScheme.primary,
      ),
    );

    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido #${order.id}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Tokens.fontSize20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tokens.spacing16),
          
          // Resumo do produto
          Row(
            children: [
              // Imagem do produto
              productImage,
              const SizedBox(width: Tokens.spacing16),
              
              // Detalhes do produto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Tokens.fontSize16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: Tokens.spacing4),
                    Text(
                      order.description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: Tokens.fontSize14,
                      ),
                    ),
                    const SizedBox(height: Tokens.spacing8),
                    // Avaliação
                    Row(
                      children: [
                        const Text(
                          'Avaliação',
                          style: TextStyle(
                            fontSize: Tokens.fontSize14,
                          ),
                        ),
                        const SizedBox(width: Tokens.spacing8),
                        for (int i = 0; i < 5; i++)
                          Icon(
                            i < order.rating ? Icons.star : Icons.star_border,
                            size: Tokens.fontSize16,
                            color: Colors.amber,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Preço
              Text(
                'R\$ ${order.price.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Tokens.fontSize16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}