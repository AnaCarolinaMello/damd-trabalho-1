import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class MapPOI extends StatelessWidget {
  final String label;
  final IconData icon;

  const MapPOI({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Tokens.spacing8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(Tokens.radius4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: Tokens.radius4,
                offset: const Offset(0, Tokens.borderSize2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: Tokens.fontSize16),
              const SizedBox(width: Tokens.spacing4),
              Text(label, style: TextStyle(fontSize: Tokens.fontSize12, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
