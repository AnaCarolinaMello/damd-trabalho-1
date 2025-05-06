import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/utils/index.dart';
import 'package:damd_trabalho_1/models/Order.dart';

class Status extends StatelessWidget {
  final Order order;
  final bool isActive;

  const Status({
    super.key,
    required this.order,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          isActive ? Utils.getStatusIcon(order.status) : Icons.check_circle_outline,
          size: Tokens.fontSize20,
          color: isActive ? theme.colorScheme.primary : Colors.green,
        ),
        const SizedBox(width: Tokens.spacing8),
        Text(
          order.status,
          style: TextStyle(
            color: isActive ? theme.colorScheme.primary : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}