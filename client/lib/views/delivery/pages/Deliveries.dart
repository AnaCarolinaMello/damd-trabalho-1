import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/views/order/components/OrderList.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/controllers/order.dart';
import 'package:damd_trabalho_1/views/delivery/components/DeliveryCard.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';

class Deliveries extends StatefulWidget {
  const Deliveries({super.key});

  @override
  State<Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<Deliveries> {
  bool isLoading = true;
  late List<Order> _availableDeliveries;

  getDeliveries() async {
    _availableDeliveries = await OrderController.getAvailableOrders();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Entregas Disponíveis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _availableDeliveries.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delivery_dining,
                  size: Tokens.fontSize24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: Tokens.spacing16),
                Text(
                  'Nenhuma entrega disponível',
                  style: TextStyle(
                    fontSize: Tokens.spacing16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(Tokens.spacing16),
            itemCount: _availableDeliveries.length,
            separatorBuilder: (context, index) => const SizedBox(height: Tokens.spacing12),
            itemBuilder: (context, index) {
              final delivery = _availableDeliveries[index];
              return DeliveryCard(order: delivery);
            },
          ),
    );
  }
}
