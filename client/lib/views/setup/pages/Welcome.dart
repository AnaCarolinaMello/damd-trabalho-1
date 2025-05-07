import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/Button.dart';
import 'package:damd_trabalho_1/views/register/pages/Index.dart';
import 'package:damd_trabalho_1/views/setup/pages/Login.dart';
import 'package:damd_trabalho_1/components/ThemeSwitcher.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ThemeSwitcher
            const Positioned(
              top: Tokens.spacing16,
              right: Tokens.spacing16,
              child: ThemeSwitcher(),
            ),
            Padding(
              padding: const EdgeInsets.all(Tokens.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  // Illustration
                  Container(
                    width: 250,
                    height: 250,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Tokens.neutral50,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/welcome_illustration.png',
                        width: 220,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.people_alt_outlined,
                            size: 120,
                            color: theme.colorScheme.primary,
                          );
                        },
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // App name
                  Text(
                    "Bem-vindo ao",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    "DeliveryTrack",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: Tokens.spacing16),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tokens.spacing24,
                    ),
                    child: Text(
                      "Acompanhe suas entregas em tempo real, gerencie pedidos e garanta que seus pacotes cheguem com segurança.",
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: Tokens.fontSize16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      text: "Login",
                      variant: ButtonVariant.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: Tokens.spacing16),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      text: "Register",
                      variant: ButtonVariant.outline,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserTypePage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: Tokens.spacing32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
