import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/views/order/components/OrderList.dart';
import 'package:damd_trabalho_1/views/order/pages/CreateOrder.dart';
import 'package:damd_trabalho_1/models/Order.dart';
import 'package:damd_trabalho_1/controllers/order.dart';
import 'package:damd_trabalho_1/models/enum/Status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool isLoading = true;
  late List<Order> _orders;
  late List<Order> _activeOrders;
  late List<Order> _pastOrders;
  int userId = 0;

  getOrders() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    userId = jsonDecode(prefs.getString('user')!)['id'] as int;
    _orders = await OrderController.getOrders(userId);

    setState(() {
      _activeOrders =
          _orders.where((order) => order.status != Status.delivered && order.status != Status.cancelled).toList();
      _pastOrders =
          _orders.where((order) => order.status == Status.delivered || order.status == Status.cancelled).toList();
      isLoading = false;
    });
  }

  void orderAgain(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = jsonDecode(prefs.getString('user')!)['id'] as int;
    final newOrder = await OrderController.createOrder(order, userId);

    setState(() {
      _activeOrders.add(newOrder);
    });
    
    await getOrders();

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
        await getOrders();
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
    WidgetsBinding.instance.addObserver(this);
    getOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recarrega as orders quando o app volta ao foco
      getOrders();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega as orders sempre que a tela for exibida
    if (mounted) {
      getOrders();
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrderPage()),
          );
          // Recarrega os pedidos quando voltar da tela de criar
          if (result != null) {
            await getOrders();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Criar Pedido',
      ),
    );
  }
}
