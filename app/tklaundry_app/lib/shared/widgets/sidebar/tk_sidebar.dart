import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_layout.dart';
import '../../../core/theme/app_spacing.dart';
import 'tk_sidebar_item.dart';

export 'tk_shell_top_bar.dart';
export 'tk_sidebar_item.dart';

class TkSidebar extends StatelessWidget {
  const TkSidebar({
    super.key,
    required this.groups,
    required this.selectedItemId,
    required this.onItemSelected,
    this.bottomGroups = const [],
    this.title = '태강세탁소',
  });

  final List<TkSidebarGroup> groups;
  final List<TkSidebarGroup> bottomGroups;
  final String? selectedItemId;
  final ValueChanged<TkSidebarItem> onItemSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppLayout.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.neutral100,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.s2),
              children: _buildGroupSections(groups),
            ),
          ),
          if (bottomGroups.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.s2,
                bottom: AppSpacing.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildGroupSections(bottomGroups),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildGroupSections(List<TkSidebarGroup> sectionGroups) {
    return [
      for (var i = 0; i < sectionGroups.length; i++) ...[
        _SidebarGroupLabel(
          label: sectionGroups[i].label,
          icon: sectionGroups[i].icon,
        ),
        for (final item in sectionGroups[i].items)
          _SidebarNavItem(
            item: item,
            isActive: item.id == selectedItemId,
            onTap: () => onItemSelected(item),
          ),
        if (i < sectionGroups.length - 1) ...[
          const SizedBox(height: AppSpacing.s2),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.s2),
        ],
      ],
    ];
  }
}

class _SidebarGroupLabel extends StatelessWidget {
  const _SidebarGroupLabel({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s3,
        AppSpacing.s4,
        AppSpacing.s1,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.s2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final TkSidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textPrimary;

    return Material(
      color: isActive ? AppColors.primaryMuted : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: isActive
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            children: [
              Icon(item.icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
