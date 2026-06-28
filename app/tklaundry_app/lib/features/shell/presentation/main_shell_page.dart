import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../member/presentation/member_list_page.dart';

enum _ShellMenu {
  home('home', '홈', Icons.home_outlined),
  member('member', '회원', Icons.person_outline),
  code('code', '공통코드', Icons.account_tree_outlined),
  customer('customer', '고객', Icons.people_outline),
  product('product', '제품', Icons.inventory_2_outlined);

  const _ShellMenu(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
}

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  _ShellMenu _selected = _ShellMenu.home;

  void _logout() {
    ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SideMenu(
            selected: _selected,
            onSelected: (menu) => setState(() => _selected = menu),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  userName: user?.userName ?? '',
                  onLogout: _logout,
                ),
                Expanded(child: _ShellContent(menu: _selected)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({
    required this.selected,
    required this.onSelected,
  });

  final _ShellMenu selected;
  final ValueChanged<_ShellMenu> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(
              '태강세탁소',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final menu in _ShellMenu.values)
                  _MenuTile(
                    menu: menu,
                    selected: menu == selected,
                    onTap: () => onSelected(menu),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.menu,
    required this.selected,
    required this.onTap,
  });

  final _ShellMenu menu;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textPrimary;

    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(menu.icon, size: 20, color: color),
              const SizedBox(width: 10),
              Text(
                menu.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.userName,
    required this.onLogout,
  });

  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '로그인: $userName',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          TkPrimaryButton(
            label: '로그아웃',
            variant: TkButtonVariant.outline,
            icon: Icons.logout,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ShellContent extends StatelessWidget {
  const _ShellContent({required this.menu});

  final _ShellMenu menu;

  @override
  Widget build(BuildContext context) {
    if (menu == _ShellMenu.member) {
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(24),
        child: const MemberListPage(),
      );
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                menu.icon,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                menu.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                menu == _ShellMenu.home
                    ? '메인 화면 뼈대입니다.\n왼쪽 메뉴에서 항목을 선택해 레이아웃을 확인할 수 있습니다.'
                    : '1단계에서 ${menu.label} 화면을 구현합니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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
