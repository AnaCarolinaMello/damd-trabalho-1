import 'package:flutter/material.dart';

class OrderStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final String time;

  OrderStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.time,
  });
}