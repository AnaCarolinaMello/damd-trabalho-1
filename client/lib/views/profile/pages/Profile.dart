import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/views/profile/components/Configuration.dart';
import 'package:damd_trabalho_1/components/ActionButton.dart';
import 'package:damd_trabalho_1/views/setup/pages/Welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:damd_trabalho_1/controllers/notification.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Tokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Configuration(),
            ActionButton(
              label: 'Sair',
              icon: Icons.logout,
              onTap: logout,
            ),
            const SizedBox(height: Tokens.spacing24),
            
            // Seção de Notificações
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(Tokens.radius12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificações',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Tokens.spacing12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final notifications = await NotificationController.getNotifications();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${notifications.length} notificações encontradas'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erro ao buscar notificações'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.notifications),
                      label: const Text('Buscar Notificações'),
                    ),
                  ),
                  const SizedBox(height: Tokens.spacing8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        NotificationController.clearNotificationCache();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cache de notificações limpo!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Limpar Cache'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
