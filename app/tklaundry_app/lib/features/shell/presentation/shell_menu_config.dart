import 'package:flutter/material.dart';

import '../../../core/constants/menu_constants.dart';
import '../../../shared/widgets/tk_sidebar.dart';
import '../../code/presentation/code_list_page.dart';
import '../../customer/presentation/customer_list_page.dart';
import '../../member/presentation/member_list_page.dart';
import '../../product/presentation/product_list_page.dart';

class ShellMenuConfig {
  ShellMenuConfig._();

  static const mainGroups = [
    TkSidebarGroup(
      label: '메뉴',
      icon: Icons.widgets_outlined,
      items: [
        TkSidebarItem(
          id: MenuConstants.order,
          label: '접수',
          icon: Icons.inbox_outlined,
        ),
        TkSidebarItem(
          id: MenuConstants.delivery,
          label: '출고',
          icon: Icons.local_shipping_outlined,
        ),
        TkSidebarItem(
          id: MenuConstants.expend,
          label: '지출',
          icon: Icons.payments_outlined,
        ),
      ],
    ),
    TkSidebarGroup(
      label: '통계',
      icon: Icons.insights_outlined,
      items: [
        TkSidebarItem(
          id: MenuConstants.deliveryView,
          label: '출고 내역',
          icon: Icons.list_alt_outlined,
        ),
        TkSidebarItem(
          id: MenuConstants.salesView,
          label: '매출',
          icon: Icons.receipt_long_outlined,
        ),
        TkSidebarItem(
          id: MenuConstants.salesChart,
          label: '매출현황',
          icon: Icons.bar_chart_outlined,
        ),
      ],
    ),
    TkSidebarGroup(
      label: '기초',
      icon: Icons.folder_copy_outlined,
      items: [
        TkSidebarItem(
          id: MenuConstants.customer,
          label: '고객 관리',
          icon: Icons.people_outline,
        ),
        TkSidebarItem(
          id: MenuConstants.product,
          label: '제품 관리',
          icon: Icons.inventory_2_outlined,
        ),
      ],
    ),
  ];

  static const bottomGroups = [
    TkSidebarGroup(
      label: '설정',
      icon: Icons.settings_outlined,
      items: [
        TkSidebarItem(
          id: MenuConstants.code,
          label: '코드',
          icon: Icons.account_tree_outlined,
        ),
        TkSidebarItem(
          id: MenuConstants.member,
          label: '사용자',
          icon: Icons.person_outline,
        ),
      ],
    ),
  ];

  /// 구현된 화면만 반환. 미구현 메뉴는 `null`.
  static Widget? pageFor(String? selectedItemId) {
    return switch (MenuId.fromId(selectedItemId)) {
      MenuId.code => const CodeListPage(),
      MenuId.member => const MemberListPage(),
      MenuId.customer => const CustomerListPage(),
      MenuId.product => const ProductListPage(),
      _ => null,
    };
  }
}
