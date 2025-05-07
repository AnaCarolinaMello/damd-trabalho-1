import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/components/Button.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';

class RegisterAction extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const RegisterAction({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Button(
        text: "Cadastrar",
        variant: ButtonVariant.primary,
        onPressed: () {
          if (formKey.currentState!.validate()) {
            // TODO: Implement register functionality
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}