import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tk_sidebar.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../member/presentation/member_list_page.dart';

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  String? _selectedItemId;

  static const _mainGroups = [
    TkSidebarGroup(
      label: '메뉴',
      icon: Icons.widgets_outlined,
      items: [
        TkSidebarItem(id: 'order', label: '접수', icon: Icons.inbox_outlined),
        TkSidebarItem(
          id: 'delivery',
          label: '출고',
          icon: Icons.local_shipping_outlined,
        ),
        TkSidebarItem(
          id: 'expend',
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
          id: 'deliveryView',
          label: '출고 내역',
          icon: Icons.list_alt_outlined,
        ),
        TkSidebarItem(
          id: 'salesView',
          label: '매출',
          icon: Icons.receipt_long_outlined,
        ),
        TkSidebarItem(
          id: 'salesChart',
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
          id: 'customer',
          label: '고객 관리',
          icon: Icons.people_outline,
        ),
        TkSidebarItem(
          id: 'product',
          label: '제품 관리',
          icon: Icons.inventory_2_outlined,
        ),
      ],
    ),
  ];

  static const _bottomGroups = [
    TkSidebarGroup(
      label: '설정',
      icon: Icons.settings_outlined,
      items: [
        TkSidebarItem(
          id: 'code',
          label: '코드',
          icon: Icons.account_tree_outlined,
        ),
        TkSidebarItem(
          id: 'member',
          label: '사용자',
          icon: Icons.person_outline,
        ),
      ],
    ),
  ];

  void _logout() {
    ref.read(authProvider.notifier).logout();
  }

  void _onItemSelected(TkSidebarItem item) {
    setState(() => _selectedItemId = item.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TkSidebar(
            groups: _mainGroups,
            bottomGroups: _bottomGroups,
            selectedItemId: _selectedItemId,
            onItemSelected: _onItemSelected,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TkShellTopBar(
                  userName: user?.userName ?? '',
                  onLogout: _logout,
                ),
                Expanded(child: _ShellContent(selectedItemId: _selectedItemId)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellContent extends StatelessWidget {
  const _ShellContent({required this.selectedItemId});

  final String? selectedItemId;

  @override
  Widget build(BuildContext context) {
    if (selectedItemId == 'member') {
      return Container(
        color: AppColors.neutral50,
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: const MemberListPage(),
      );
    }

    return Container(
      color: AppColors.neutral50,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 48,
                color: AppColors.neutral400,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                selectedItemId == null
                    ? '왼쪽 메뉴에서 항목을 선택하세요.'
                    : '1단계에서 구현 예정입니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral600,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
