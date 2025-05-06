import 'package:flutter/material.dart';
import 'package:damd_trabalho_1/theme/Tokens.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive 
                  ? selectedColor.withOpacity(0.15) 
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? selectedColor : unselectedColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: Tokens.fontSize12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}