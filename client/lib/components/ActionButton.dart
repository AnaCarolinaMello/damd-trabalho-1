import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool loading;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color:
            isPrimary
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
      ),
      label:
          loading
              ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color:
                      isPrimary
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                ),
              )
              : Text(
                label,
                style: TextStyle(
                  color:
                      isPrimary
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
