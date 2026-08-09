import 'package:flutter/material.dart';

import '../../../shared/widgets/sidebar/tk_sidebar_item.dart';

enum MenuSection {
  business('메뉴', Icons.widgets_outlined),
  statistics('통계', Icons.insights_outlined),
  master('기초', Icons.folder_copy_outlined),
  settings('설정', Icons.settings_outlined, bottom: true);

  const MenuSection(this.label, this.icon, {this.bottom = false});

  final String label;
  final IconData icon;
  final bool bottom;
}

enum MenuId {
  order(
    id: 'order',
    label: '접수',
    icon: Icons.inbox_outlined,
    section: MenuSection.business,
  ),
  delivery(
    id: 'delivery',
    label: '출고',
    icon: Icons.local_shipping_outlined,
    section: MenuSection.business,
  ),
  expend(
    id: 'expend',
    label: '지출',
    icon: Icons.payments_outlined,
    section: MenuSection.business,
  ),
  deliveryView(
    id: 'deliveryView',
    label: '출고 내역',
    icon: Icons.list_alt_outlined,
    section: MenuSection.statistics,
  ),
  salesView(
    id: 'salesView',
    label: '매출',
    icon: Icons.receipt_long_outlined,
    section: MenuSection.statistics,
  ),
  salesChart(
    id: 'salesChart',
    label: '매출현황',
    icon: Icons.bar_chart_outlined,
    section: MenuSection.statistics,
  ),
  customer(
    id: 'customer',
    label: '고객 관리',
    icon: Icons.people_outline,
    section: MenuSection.master,
  ),
  product(
    id: 'product',
    label: '제품 관리',
    icon: Icons.inventory_2_outlined,
    section: MenuSection.master,
  ),
  code(
    id: 'code',
    label: '코드',
    icon: Icons.account_tree_outlined,
    section: MenuSection.settings,
  ),
  member(
    id: 'member',
    label: '사용자',
    icon: Icons.person_outline,
    section: MenuSection.settings,
  );

  const MenuId({
    required this.id,
    required this.label,
    required this.icon,
    required this.section,
  });

  final String id;
  final String label;
  final IconData icon;
  final MenuSection section;

  TkSidebarItem get sidebarItem =>
      TkSidebarItem(id: id, label: label, icon: icon);

  static MenuId fromId(String id) {
    for (final menu in MenuId.values) {
      if (menu.id == id) return menu;
    }
    throw ArgumentError.value(id, 'id', 'Unknown menu id');
  }
}
