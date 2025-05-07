import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

enum InputType {
  text,
  email,
  password,
  number,
  phone,
}

class CustomInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final InputType type;
  final void Function(String)? onChanged;

  const CustomInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.type = InputType.text,
    this.onChanged,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late bool _obscureText;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == InputType.password;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine keyboard type based on input type
    TextInputType? keyboardType;
    switch (widget.type) {
      case InputType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case InputType.number:
        keyboardType = TextInputType.number;
        break;
      case InputType.phone:
        keyboardType = TextInputType.phone;
        break;
      default:
        keyboardType = TextInputType.text;
    }

    // Build default validator based on type if none provided
    String? Function(String?)? validator = widget.validator;
    if (validator == null) {
      switch (widget.type) {
        case InputType.email:
          validator = (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          };
          break;
        case InputType.password:
          validator = (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          };
          break;
        case InputType.text:
        case InputType.number:
        case InputType.phone:
          validator = (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          };
          break;
      }
    }

    // Create password toggle button for password fields
    Widget? suffixIcon = widget.suffixIcon;
    if (widget.type == InputType.password && suffixIcon == null) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          widget.labelText ?? '',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: Tokens.fontSize14,
          ),
        ),
        const SizedBox(height: Tokens.spacing8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.type == InputType.password ? _obscureText : widget.obscureText,
          keyboardType: keyboardType,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Tokens.radius8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Tokens.spacing16,
              vertical: Tokens.spacing16,
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
