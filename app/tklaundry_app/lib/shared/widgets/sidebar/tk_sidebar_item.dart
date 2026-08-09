import 'package:flutter/material.dart';

class TkSidebarItem {
  const TkSidebarItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class TkSidebarGroup {
  const TkSidebarGroup({
    required this.label,
    required this.icon,
    required this.items,
  });

  final String label;
  final IconData icon;
  final List<TkSidebarItem> items;
}
