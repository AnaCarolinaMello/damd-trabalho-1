import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:damd_trabalho_1/components/Button.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:damd_trabalho_1/models/User.dart';
import 'package:damd_trabalho_1/models/enum/UserType.dart';
import 'package:damd_trabalho_1/controllers/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterAction extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final UserType type;

  const RegisterAction({
    super.key,
    required this.formKey,
    required this.name,
    required this.email,
    required this.password,
    required this.type,
  });

  @override
  State<RegisterAction> createState() => _RegisterActionState();
}

class _RegisterActionState extends State<RegisterAction> {
  bool loading = false;

  void register(BuildContext context) async {
    final user = User(
      name: widget.name.text,
      email: widget.email.text,
      password: widget.password.text,
      type: widget.type,
    );

    setState(() {
      loading = true;
    });
    try {
      final createdUser = await UserController.createUser(user);

      // Save user data to SharedPreferences as JSON string
      SharedPreferences.getInstance().then((prefs) {
        final userJson = jsonEncode(createdUser!.toJson());
        prefs.setString('user', userJson);
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar usuário!')),
      );
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Button(
        text: "Cadastrar",
        loading: loading,
        variant: ButtonVariant.primary,
        onPressed: () {
          if (widget.formKey.currentState!.validate()) {
            register(context);
          }
        },
      ),
    );
  }
}
