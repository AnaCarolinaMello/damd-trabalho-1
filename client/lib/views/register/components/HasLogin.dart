import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/views/setup/pages/Login.dart';

class HasLogin extends StatelessWidget {
  const HasLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Já tem uma conta? ",
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          child: Text(
            "Faça login",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}