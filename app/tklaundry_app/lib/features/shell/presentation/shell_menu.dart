import 'package:flutter/material.dart';

import '../../../shared/widgets/sidebar/tk_sidebar_item.dart';
import '../constants/menu.dart';
import '../../code/presentation/code_list_page.dart';
import '../../customer/presentation/customer_list_page.dart';
import '../../delivery/presentation/release/delivery_list_page.dart';
import '../../delivery/presentation/view/delivery_view_page.dart';
import '../../expend/presentation/expend_list_page.dart';
import '../../member/presentation/member_list_page.dart';
import '../../order/presentation/order_list_page.dart';
import '../../product/presentation/product_list_page.dart';
import '../../sales/presentation/sales_view_page.dart';
import '../../sales_chart/presentation/sales_chart_page.dart';

class ShellMenuConfig {
  ShellMenuConfig._();

  static List<TkSidebarGroup> get mainGroups => _groupsFor(bottom: false);

  static List<TkSidebarGroup> get bottomGroups => _groupsFor(bottom: true);

  static List<TkSidebarGroup> _groupsFor({required bool bottom}) {
    return [
      for (final section in MenuSection.values.where((s) => s.bottom == bottom))
        TkSidebarGroup(
          label: section.label,
          icon: section.icon,
          items: [
            for (final menu in MenuId.values.where((m) => m.section == section))
              menu.sidebarItem,
          ],
        ),
    ];
  }

  static Widget pageFor(MenuId menu) {
    return switch (menu) {
      MenuId.order => const OrderListPage(),
      MenuId.delivery => const DeliveryListPage(),
      MenuId.expend => const ExpendListPage(),
      MenuId.deliveryView => const DeliveryViewPage(),
      MenuId.salesView => const SalesViewPage(),
      MenuId.salesChart => const SalesChartPage(),
      MenuId.code => const CodeListPage(),
      MenuId.member => const MemberListPage(),
      MenuId.customer => const CustomerListPage(),
      MenuId.product => const ProductListPage(),
    };
  }
}
