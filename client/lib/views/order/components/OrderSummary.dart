import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/order/components/SummaryItem.dart';

class OrderSummary extends StatelessWidget {
  final Order order;

  const OrderSummary({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SummaryItem(
          label: 'Subtotal',
          value: 'R\$ ${order.price.toStringAsFixed(2)}',
          isTotal: true,
        ),
        const SizedBox(height: Tokens.spacing8),
        SummaryItem(
          label: 'Taxa de entrega',
          value: 'R\$ ${order.deliveryFee.toStringAsFixed(2)}',
          isTotal: true,
        ),
        const SizedBox(height: Tokens.spacing8),
        if (order.discount > 0) ...[
          SummaryItem(
            label: 'Desconto',
            value: '-R\$ ${order.discount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
          const SizedBox(height: Tokens.spacing16),
        ],
        Divider(color: theme.colorScheme.outlineVariant),
        const SizedBox(height: Tokens.spacing16),
        SummaryItem(
          label: 'Total',
          value: 'R\$ ${order.total.toStringAsFixed(2)}',
          isTotal: true,
        ),
      ],
    );
  }
}
