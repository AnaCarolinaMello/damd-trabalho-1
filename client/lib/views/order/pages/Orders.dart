import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/views/order/components/OrderList.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/controllers/order.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String userId = '';

  getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    userId = jsonDecode(prefs.getString('user')!)['id'];
    _orders = await OrderController.getOrders(userId);

    setState(() {
      _activeOrders =
          _orders.where((order) => order.status != Status.delivered).toList();
      _pastOrders =
          _orders.where((order) => order.status == Status.delivered).toList();
      isLoading = false;
    });
  }

  void orderAgain(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = jsonDecode(prefs.getString('user')!)['id'];
    final newOrder = await OrderController.createOrder(order, userId);

    setState(() {
      _activeOrders.add(newOrder);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido realizado com sucesso')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Erro ao pedir novamente')));
  }

  void rateOrder(Order order, double rating) async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, avalie o pedido')),
      );
      return;
    }

    try {
      await OrderController.rateOrder(order.id!, userId, rating);
      if (mounted) {
        setState(() {
          order.rating = rating;
          final index = _pastOrders.indexOf(order);
          _pastOrders[index] = order;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação enviada com sucesso')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao avaliar o pedido')));
    }
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
        automaticallyImplyLeading: false,
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
          OrderList(
            orders: _pastOrders,
            isActive: false,
            orderAgain: orderAgain,
            rateOrder: rateOrder,
          ),
        ],
      ),
    );
  }
}
