import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/enum/UserType.dart';
import 'package:damd_trabalho_1/components/AppBar.dart';
import 'package:damd_trabalho_1/components/Button.dart';
import 'package:damd_trabalho_1/views/register/components/UserType.dart';
import 'package:damd_trabalho_1/views/register/components/HasLogin.dart';
import 'package:damd_trabalho_1/views/register/pages/Driver.dart';
import 'package:damd_trabalho_1/views/register/pages/Client.dart';


class UserTypePage extends StatefulWidget {
  final Function(UserType)? onUserTypeSelected;

  const UserTypePage({super.key, this.onUserTypeSelected});

  @override
  State<UserTypePage> createState() => _UserTypePageState();
}

class _UserTypePageState extends State<UserTypePage> {
  UserType? _selectedType;

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void navigateToNextPage(BuildContext context, UserType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => type == UserType.driver ? const DriverPage() : const ClientPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "Cadastro"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header
              Text(
                'Selecione o tipo de usuário',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: Tokens.spacing24),

              // User type options
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  UserTypeCard(
                    type: UserType.driver,
                    icon: Icons.car_crash,
                    isSelected: _selectedType == UserType.driver,
                    onTap: () {
                      setState(() {
                        _selectedType = UserType.driver;
                      });
                    },
                  ),
                  const SizedBox(height: Tokens.spacing16),
                  UserTypeCard(
                    type: UserType.customer,
                    icon: Icons.person_outline,
                    isSelected: _selectedType == UserType.customer,
                    onTap: () {
                      setState(() {
                        _selectedType = UserType.customer;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: Tokens.spacing16),

              const HasLogin(),

              const SizedBox(height: Tokens.spacing16),

              SizedBox(
                width: double.infinity,
                child: Button(
                  text: 'Continue',
                  variant: ButtonVariant.primary,
                  onPressed:
                      _selectedType == null
                          ? () {
                            showSnackBar(
                              context,
                              'Selecione um tipo de usuário',
                            );
                          }
                          : () {
                            if (widget.onUserTypeSelected != null) {
                              widget.onUserTypeSelected!(_selectedType!);
                            }
                            // Navigate to next page or close this one
                            navigateToNextPage(context, _selectedType!);
                          },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
