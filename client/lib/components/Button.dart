import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

enum ButtonColor {
  primary,
  neutral
}

enum ButtonVariant {
  primary,
  outline,
  text,
}

class Button extends StatelessWidget {
  final ButtonColor color;
  final ButtonVariant variant;
  final String text;
  final void Function() onPressed;

  const Button({
    super.key,
    this.color = ButtonColor.primary,
    this.variant = ButtonVariant.primary,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get the base colors based on the selected color
    final Color primaryColor = color == ButtonColor.primary 
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
    
    final Color onPrimaryColor = color == ButtonColor.primary 
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSecondary;

    // Configure button based on variant
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: onPrimaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Tokens.spacing16, 
              vertical: Tokens.spacing12
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Tokens.radius8),
            ),
          ),
          child: Text(text),
        );
        
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: Tokens.borderSize1),
            padding: const EdgeInsets.symmetric(
              horizontal: Tokens.spacing16, 
              vertical: Tokens.spacing12
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Tokens.radius8),
            ),
          ),
          child: Text(text),
        );
        
      case ButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Tokens.spacing16, 
              vertical: Tokens.spacing12
            ),
          ),
          child: Text(text),
        );
    }
  }
}
