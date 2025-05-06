import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';

class OrderItems extends StatelessWidget {
  final List<OrderItem> items;

  const OrderItems({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(height: Tokens.borderSize1, indent: Tokens.spacing16, endIndent: Tokens.spacing16),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Tokens.spacing16, vertical: Tokens.spacing12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(Tokens.spacing12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(Tokens.radius4),
                ),
                child: Text(
                  '${item.quantity}x',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: Tokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Tokens.fontSize16,
                      ),
                    ),
                    const SizedBox(height: Tokens.borderSize2),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: Tokens.fontSize14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'R\$ ${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: Tokens.fontSize16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}