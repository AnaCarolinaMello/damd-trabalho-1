import 'package:flutter/material.dart';

class Utils {
  static IconData getIconForOrderType(String title) {
    if (title.contains('Restaurante') ||
        title.contains('Hamburgueria') ||
        title.contains('Pizza')) {
    return Icons.restaurant;
  } else if (title.contains('Farmácia')) {
    return Icons.local_pharmacy;
  } else if (title.contains('Supermercado')) {
    return Icons.shopping_cart;
  } else if (title.contains('Açaí')) {
      return Icons.icecream;
    }
    return Icons.store;
  }

  static IconData getStatusIcon(String status) {
    if (status.contains('preparação')) {
      return Icons.restaurant;
    } else if (status.contains('entrega')) {
      return Icons.delivery_dining;
    } else if (status.contains('Pedido')) {
      return Icons.receipt;
    }
    return Icons.pending;
  }
}
