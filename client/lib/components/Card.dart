import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(Tokens.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, Tokens.borderSize2),
            blurRadius: Tokens.radius4,
          ),
        ],
      ),
      child: child,
    );
  }
}