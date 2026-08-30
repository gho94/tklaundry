import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/sidebar/tk_sidebar.dart';
import '../../auth/presentation/auth_provider.dart';
import '../constants/menu.dart';
import 'shell_menu.dart';

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  MenuId? _selectedMenuId;

  void _logout() {
    ref.read(authProvider.notifier).logout();
  }

  void _onItemSelected(TkSidebarItem item) {
    setState(() => _selectedMenuId = MenuId.fromId(item.id));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TkSidebar(
            groups: ShellMenuConfig.mainGroups,
            bottomGroups: ShellMenuConfig.bottomGroups,
            selectedItemId: _selectedMenuId?.id,
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
                Expanded(child: _ShellContent(selectedMenuId: _selectedMenuId)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellContent extends StatelessWidget {
  const _ShellContent({required this.selectedMenuId});

  final MenuId? selectedMenuId;

  @override
  Widget build(BuildContext context) {
    final menuId = selectedMenuId;
    if (menuId != null) {
      return Container(
        color: AppColors.neutral50,
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: ShellMenuConfig.pageFor(menuId),
      );
    }

    return Container(
      color: AppColors.neutral50,
      alignment: Alignment.center,
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
              '왼쪽 메뉴에서 항목을 선택하세요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
