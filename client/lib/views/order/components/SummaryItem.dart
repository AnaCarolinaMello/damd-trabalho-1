import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const SummaryItem({
    super.key,
    required this.label,
    required this.value, 
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? Tokens.fontSize16 : Tokens.fontSize14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal 
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? Tokens.fontSize16 : Tokens.fontSize14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount 
                ? Colors.green
                : (isTotal 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}