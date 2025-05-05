import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class ThemeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final Widget child;

  const ThemeOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Tokens.radius12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(Tokens.spacing4),
                  child: child,
                ),
                if (isSelected)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: Tokens.spacing8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}