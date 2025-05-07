import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/UserType.dart';

class UserTypeCard extends StatelessWidget {
  final UserType type;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const UserTypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primaryContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(Tokens.radius16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: Tokens.spacing8,
                      offset: const Offset(0, Tokens.borderSize2),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color:
                  isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
            ),
            const SizedBox(height: Tokens.spacing16),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: Tokens.fontSize14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
