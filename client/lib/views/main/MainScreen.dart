import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/components/BottomNavBar.dart';
import 'package:damd_trabalho_1/views/profile/pages/Profile.dart';
import 'package:damd_trabalho_1/views/order/pages/Orders.dart';
import 'package:damd_trabalho_1/views/delivery/pages/Index.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentNavItem = 'home';

  final List<NavItemModel> _navItems = [
    NavItemModel(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      value: 'home',
      label: 'Home',
      screen: const Text('Home'),
    ),
    NavItemModel(
      icon: Icons.history,
      activeIcon: Icons.history,
      value: 'history',
      label: 'Histórico',
      screen: const DeliveryIndex(),
    ),
    // NavItemModel(
    //   icon: Icons.search,
    //   activeIcon: Icons.search,
    //   value: 'search',
    //   label: 'Search',
    //   screen: const Center(child: Text('Search Screen')),
    // ),
    // NavItemModel(
    //   icon: Icons.map_outlined,
    //   activeIcon: Icons.map,
    //   value: 'map',
    //   label: 'Tracking',
    //   screen: const Tracking(),
    // ),
    NavItemModel(
      icon: Icons.receipt_long,
      activeIcon: Icons.receipt_long,
      value: 'orders',
      label: 'Pedidos',
      screen: const Orders(),
    ),
    NavItemModel(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      value: 'profile',
      label: 'Profile',
      screen: const Profile(),
    ),
  ];

  void _onNavTap(NavItemModel item) {
    setState(() {
      _currentNavItem = item.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Encontrar o item de navegação atual
    final currentNavItem = _navItems.firstWhere(
      (item) => item.value == _currentNavItem,
      orElse: () => _navItems.first,
    );

    return Scaffold(
      body: currentNavItem.screen,
      bottomNavigationBar: BottomNavBar(
        currentItem: _currentNavItem,
        items: _navItems,
        onTap: _onNavTap,
      ),
    );
  }
} 