import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/OrderStep.dart';

class OrderStepComponent extends StatelessWidget {
  final OrderStep step;
  final bool isLast;

  const OrderStepComponent({
    super.key,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna da linha de tempo
        Column(
          children: [
            // Círculo de status
            Container(
              width: Tokens.spacing36,
              height: Tokens.spacing36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.isCompleted
                    ? primaryColor
                    : theme.colorScheme.surfaceVariant,
                border: step.isCompleted
                    ? null
                    : Border.all(
                        color: theme.colorScheme.outline,
                        width: Tokens.borderSize1,
                      ),
              ),
              child: Icon(
                step.icon,
                size: Tokens.fontSize20,
                color: step.isCompleted
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            // Linha conectora (não mostrar para o último item)
            if (!isLast)
              Container(
                width: 2,
                height: Tokens.spacing40,
                color: step.isCompleted
                    ? primaryColor
                    : theme.colorScheme.surfaceVariant,
              ),
          ],
        ),
        
        const SizedBox(width: Tokens.spacing16),
        
        // Conteúdo do passo
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : Tokens.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Tokens.fontSize16,
                    color: step.isCompleted
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Tokens.spacing4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        fontSize: Tokens.fontSize14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (step.isCompleted)
                      Text(
                        step.time,
                        style: TextStyle(
                          fontSize: Tokens.fontSize14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}