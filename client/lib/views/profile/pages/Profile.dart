import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/views/profile/components/Configuration.dart';
import 'package:damd_trabalho_1/components/ActionButton.dart';
import 'package:damd_trabalho_1/views/setup/pages/Welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          ],
        ),
      ),
    );
  }
}
