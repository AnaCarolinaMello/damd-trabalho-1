import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/components/BottomNavBar.dart';
import 'package:damd_trabalho_1/views/register/pages/Index.dart';
import 'package:damd_trabalho_1/views/profile/pages/Profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentItem = 'home';
  Widget _screen = const Register();

  final List<NavItemModel> navItems = [
      NavItemModel(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        value: 'home',
        label: 'Home',
        screen: const Register(),
      ),
      NavItemModel(
        icon: Icons.search,
        activeIcon: Icons.search,
        value: 'search',
        label: 'Search',
        screen: const Center(child: Text('Search')),
      ),

      NavItemModel(
        icon: Icons.pie_chart_outline,
        activeIcon: Icons.pie_chart,
        value: 'analytics',
        label: 'Analytics',
        screen: const Center(child: Text('Analytics')),
      ),

      NavItemModel(
        icon: Icons.history,
        activeIcon: Icons.history,
        value: 'history',
        label: 'History',
        screen: const Center(child: Text('History')),
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
      _currentItem = item.value;
      _screen = item.screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen,
      bottomNavigationBar: BottomNavBar(
        currentItem: _currentItem,
        items: navItems,
        onTap: _onNavTap,
      ),
    );
  }
} 