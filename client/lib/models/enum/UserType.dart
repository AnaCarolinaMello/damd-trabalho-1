import 'package:flutter/material.dart';

enum UserType {
  driver,
  customer,
}

// Extension for user-friendly names
extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.driver:
        return 'Motorista';
      case UserType.customer:
        return 'Cliente';
    }
  }

  IconData get icon {
    switch (this) {
      case UserType.driver:
        return Icons.car_crash;
      case UserType.customer:
        return Icons.person_outline;
    }
  }
} 