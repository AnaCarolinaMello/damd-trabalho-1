import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';
import 'package:damd_trabalho_1/components/NavItem.dart';

class NavItemModel {
  final IconData icon;
  final IconData activeIcon;
  final String value;
  final String label;
  final Widget screen;

  NavItemModel({
    required this.icon,
    required this.activeIcon,
    required this.value,
    required this.label,
    required this.screen,
  });
}

class BottomNavBar extends StatelessWidget {
  final String currentItem;
  final Function(NavItemModel) onTap;
  final List<NavItemModel> items;

  const BottomNavBar({
    super.key,
    required this.currentItem,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define colors based on theme
    final backgroundColor = theme.colorScheme.onSecondary;
    final selectedItemColor = theme.colorScheme.primary;
    final unselectedItemColor = theme.colorScheme.onSurfaceVariant;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.surfaceVariant,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Tokens.spacing8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) => NavItem(
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              isActive: currentItem == item.value,
              onTap: () => onTap(item),
              selectedColor: selectedItemColor,
              unselectedColor: unselectedItemColor,
            )).toList(),
          ),
        ),
      ),
    );
  }
}