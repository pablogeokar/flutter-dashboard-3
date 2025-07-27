import 'package:flutter/material.dart';

class NavigationItem {
  final Widget screen;
  final String title;
  final IconData icon;
  final Color color;

  const NavigationItem({
    required this.screen,
    required this.title,
    required this.icon,
    required this.color,
  });
}
