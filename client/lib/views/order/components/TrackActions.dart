import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/Card.dart';

class TrackActions extends StatelessWidget {
  const TrackActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(Tokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Precisa de ajuda?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Tokens.fontSize16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Tokens.spacing16),
          OutlinedButton.icon(
            onPressed: () {
              // Ação para contatar suporte
            },
            icon: Icon(
              Icons.support_agent,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              'Falar com Atendimento',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: Tokens.spacing12, horizontal: Tokens.spacing16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Tokens.radius8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}