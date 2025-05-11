import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:damd_trabalho_1/components/BottomNavBar.dart';
import 'package:damd_trabalho_1/views/profile/pages/Profile.dart';
import 'package:damd_trabalho_1/views/order/pages/Orders.dart';
import 'package:damd_trabalho_1/views/delivery/pages/Index.dart';
import 'package:damd_trabalho_1/models/User.dart';
import 'package:damd_trabalho_1/models/enum/UserType.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentNavItem = 'home';
  User? _user;
  List<NavItemModel> _navItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void setNavItems() {
    setState(() {
      _navItems = [
        NavItemModel(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          value: 'home',
          label: 'Home',
          screen: const Text('Home'),
        ),
        NavItemModel(
          icon: Icons.receipt_long,
          activeIcon: Icons.receipt_long,
          value: 'orders',
          label: 'Pedidos',
          screen:
              _user?.type == UserType.driver
                  ? const DeliveryIndex()
                  : const Orders(),
        ),
        NavItemModel(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          value: 'profile',
          label: 'Profile',
          screen: const Profile(),
        ),
      ];
    });

    setState(() {
      _isLoading = false;
    });
  }

  void getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null && userString.isNotEmpty) {
      try {
        setState(() {
          _user = User.fromJson(jsonDecode(userString));
        });
      } catch (e) {
        print('Error parsing user data: $e');
        // Handle invalid JSON case
      }
    }
    setNavItems();
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentNavItem.screen,
      bottomNavigationBar: BottomNavBar(
        currentItem: _currentNavItem,
        items: _navItems,
        onTap: _onNavTap,
      ),
    );
  }
}
