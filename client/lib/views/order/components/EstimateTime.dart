import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';

class EstimateTime extends StatelessWidget {
  final Order order;
  const EstimateTime({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Tokens.spacing8,
        horizontal: Tokens.spacing12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Tokens.radius8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: Tokens.fontSize16,
          ),
          const SizedBox(width: Tokens.spacing4),
          Text(
            'Entrega estimada: 20-30 min',
            style: TextStyle(
              fontSize: Tokens.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}