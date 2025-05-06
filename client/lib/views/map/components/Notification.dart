import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class Notification extends StatelessWidget {
  final Map<String, dynamic> driver;
  final bool isDarkMode;

  const Notification({
    super.key,
    required this.driver,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: theme.colorScheme.surface.withOpacity(0.9),
        padding: const EdgeInsets.fromLTRB(
          Tokens.spacing16,
          Tokens.spacing56,
          Tokens.spacing16,
          Tokens.spacing12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode ? Tokens.neutral800 : Tokens.neutral200,
                borderRadius: BorderRadius.circular(Tokens.radius8),
              ),
              child: const Icon(Icons.local_taxi, size: Tokens.fontSize24),
            ),
            const SizedBox(width: Tokens.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu motorista está a caminho',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Chegando em ${driver['arrivalTime']} min aproximadamente',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: Tokens.fontSize14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'agora',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: Tokens.fontSize14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}