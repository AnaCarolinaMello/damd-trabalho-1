import 'package:flutter/material.dart';

enum Status {
  pending,
  accepted,
  delivered,
  cancelled,
}

extension StatusExtension on Status {
  String get displayName {
    switch (this) {
      case Status.pending:
        return 'Pendente';
      case Status.accepted:
        return 'Em rota de entrega';
      case Status.delivered:
        return 'Entregue';
      case Status.cancelled:
        return 'Cancelado';
    }
  }

  IconData get icon {
    switch (this) {
      case Status.pending:
        return Icons.pending;
      case Status.accepted:
        return Icons.check_circle;
      case Status.delivered:
        return Icons.check_circle;
      case Status.cancelled:
        return Icons.cancel;
    }
  }
}
