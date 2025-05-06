import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
class MapAction extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final bool isActive;

  const MapAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: Tokens.spacing40,
        height: Tokens.spacing40,
        decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: Tokens.radius4,
            offset: const Offset(0, Tokens.borderSize2),
          ),
        ],
        border: isActive ? Border.all(color: theme.colorScheme.primary, width: Tokens.borderSize2) : null,
      ),
      child: Icon(
        icon,
        color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        size: Tokens.fontSize20,
      ),
      ),
    );
  }
}