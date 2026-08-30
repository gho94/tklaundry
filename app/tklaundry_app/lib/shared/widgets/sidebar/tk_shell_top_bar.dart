import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_layout.dart';
import '../../../core/theme/app_spacing.dart';

class TkShellTopBar extends StatelessWidget {
  const TkShellTopBar({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppLayout.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: const BoxDecoration(
        color: AppColors.neutral0,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(userName, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.s2),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('로그아웃')),
            ],
          ),
        ],
      ),
    );
  }
}
