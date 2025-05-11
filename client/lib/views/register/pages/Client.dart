import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/Input.dart';
import 'package:damd_trabalho_1/components/AppBar.dart';
import 'package:damd_trabalho_1/views/register/components/Header.dart';
import 'package:damd_trabalho_1/views/register/components/HasLogin.dart';
import 'package:damd_trabalho_1/views/register/components/RegisterAction.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:damd_trabalho_1/models/User.dart';
import 'package:damd_trabalho_1/models/enum/UserType.dart';
import 'package:damd_trabalho_1/controllers/user.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Cadastro de cliente"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Tokens.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const RegisterHeader(),

                  const SizedBox(height: Tokens.spacing40),

                  CustomInput(
                    controller: _nameController,
                    labelText: "Nome",
                    hintText: "Digite seu nome",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite seu nome';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: Tokens.spacing24),

                  CustomInput(
                    controller: _emailController,
                    labelText: "E-mail",
                    hintText: "Digite seu e-mail",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite seu e-mail';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: Tokens.spacing24),

                  CustomInput(
                    controller: _passwordController,
                    labelText: "Senha",
                    type: InputType.password,
                    hintText: "Digite sua senha",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite sua senha';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: Tokens.spacing40),

                  // Don't have an account text and register link
                  const HasLogin(),

                  const SizedBox(height: Tokens.spacing24),

                  // Login Button
                  RegisterAction(
                    formKey: _formKey,
                    name: _nameController,
                    email: _emailController,
                    password: _passwordController,
                    type: UserType.customer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for register page
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(child: Text('Register page coming soon')),
    );
  }
}
