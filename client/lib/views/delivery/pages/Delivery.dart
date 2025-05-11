import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/order/components/Status.dart';
import 'package:damd_trabalho_1/views/order/components/Shop.dart';
import 'package:damd_trabalho_1/views/order/components/EstimateTime.dart';
import 'package:damd_trabalho_1/views/order/components/Address.dart';
import 'package:damd_trabalho_1/views/order/components/SummaryItem.dart';
import 'package:damd_trabalho_1/components/IconButton.dart';
import 'package:damd_trabalho_1/views/delivery/pages/Finish.dart';
import 'package:damd_trabalho_1/views/map/pages/Route.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key, required this.order});

  final Order order;

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Status(order: widget.order, isActive: true),
                  const SizedBox(height: Tokens.spacing4),
                  Text(
                    '${widget.order.date} ${widget.order.time}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: Tokens.fontSize14,
                    ),
                  ),

                  const SizedBox(height: Tokens.spacing16),
                  EstimateTime(order: widget.order),
                ],
              ),
            ),

            // Detalhes do estabelecimento
            Shop(order: widget.order, isActive: true),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: SummaryItem(
                label: 'Total',
                value: 'R\$ ${widget.order.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ),

            const Divider(),

            AddressComponent(address: widget.order.address),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: CustomIconButton(
                icon: Icons.check_circle_outline,
                label: 'Finalizar Entrega',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinishDelivery(order: widget.order),
                    ),
                  );
                  
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entrega finalizada com sucesso!')),
                    );
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tokens.spacing16),
              child: CustomIconButton(
                icon: Icons.check_circle_outline,
                label: 'Ver rota',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutePage(order: widget.order),
                    ),
                  );
                  
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entrega finalizada com sucesso!')),
                    );
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
