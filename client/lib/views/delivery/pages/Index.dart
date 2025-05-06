import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/views/delivery/pages/Deliveries.dart';
import 'package:damd_trabalho_1/views/delivery/pages/Delivery.dart';
import 'package:damd_trabalho_1/controllers/order.dart';

class DeliveryIndex extends StatefulWidget {
  const DeliveryIndex({super.key});

  @override
  State<DeliveryIndex> createState() => _DeliveryIndexState();
}

class _DeliveryIndexState extends State<DeliveryIndex> {
  Order? acceptedOrder;
  bool isLoading = true;

  Future<void> getAcceptedOrder() async {
    final order = await OrderController.getAcceptOrder('1');
    setState(() {
      acceptedOrder = order;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAcceptedOrder();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (acceptedOrder == null) {
      return const Deliveries();
    }

    return Delivery(order: acceptedOrder!);
  }
}
