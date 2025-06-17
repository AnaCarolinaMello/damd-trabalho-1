import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/ActionButton.dart';
import 'package:damd_trabalho_1/views/order/pages/OrderDetail.dart';
import 'package:damd_trabalho_1/views/order/pages/OrderTracking.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart' as OrderStatus;

class OrderActions extends StatelessWidget {
  final Order order;
  final bool isActive;
  final Function() orderAgain;
  final Function(Order, double) rateOrder;


  const OrderActions({
    super.key,
    required this.order,
    required this.isActive,
    required this.orderAgain,
    required this.rateOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Tokens.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionButton(
            label: 'Detalhes',
            icon: isActive ? Icons.info_outline : Icons.receipt_long_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetail(
                    order: order,
                    isActive: isActive,
                    orderAgain: orderAgain,
                    rateOrder: rateOrder,
                  ),
                ),
              );
            },
          ),

          if (isActive)
            ActionButton(
              label: 'Rastrear',
              icon: Icons.map_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTracking(
                      order: order,
                    ),
                  ),
                );
              },
              isPrimary: true,
            )
          else
            ActionButton(
              label: 'Pedir novamente',
              icon: Icons.replay_outlined,
              onTap: orderAgain,
              isPrimary: order.rating == 0 && order.status != OrderStatus.Status.cancelled,
            ),
        ],
      ),
    );
  }
}