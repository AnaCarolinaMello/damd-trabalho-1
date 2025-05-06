import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/views/order/components/OrderList.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/models/OrderItem.dart';
import 'package:damd_trabalho_1/controllers/order.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  late List<Order> _orders;
  late List<Order> _activeOrders;
  late List<Order> _pastOrders;

  getOrders() async {
    _orders = await OrderController.getOrders();

    setState(() {
      _activeOrders = _orders.where((order) => order.status != 'Entregue').toList();
      _pastOrders = _orders.where((order) => order.status == 'Entregue').toList();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          tabs: const [Tab(text: 'Pedidos Ativos'), Tab(text: 'Histórico')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba de pedidos ativos
          OrderList(orders: _activeOrders, isActive: true),

          // Aba de histórico de pedidos
          OrderList(orders: _pastOrders, isActive: false),
        ],
      ),
    );
  }
}
