import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/OrderStep.dart';
import 'package:damd_trabalho_1/views/order/components/Step.dart';
import 'package:damd_trabalho_1/components/Card.dart';

class Track extends StatelessWidget {
  final List<OrderStep> steps;

  const Track({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                'Rastrear Pedido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Tokens.fontSize16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: Tokens.spacing24),
          
          for (int i = 0; i < steps.length; i++)
            OrderStepComponent(
              step: steps[i],
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}