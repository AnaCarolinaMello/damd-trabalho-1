import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/Button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aguardando jogadores...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: Tokens.fontSize24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Tokens.spacing16),
            Button(
              text: 'Iniciar jogo',
              onPressed: () {
                print('Iniciar jogo');
              },
            ),
          ],
        ),
      ),
    );
  }
}