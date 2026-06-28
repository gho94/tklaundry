import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import 'member_provider.dart';

class MemberListPage extends ConsumerWidget {
  const MemberListPage({super.key});

  static const _columns = [
    TkGridColumn(label: '아이디', width: 140),
    TkGridColumn(label: '이름'),
    TkGridColumn(label: '사용여부', width: 100, align: TextAlign.center),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(memberListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '회원',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TkPrimaryButton(
              label: '새로고침',
              variant: TkButtonVariant.outline,
              icon: Icons.refresh,
              isLoading: membersAsync.isLoading,
              onPressed: membersAsync.isLoading
                  ? null
                  : () => ref.read(memberListProvider.notifier).refresh(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: membersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorBody(error: error),
                data: (members) => TkGridTable(
                  columns: _columns,
                  rows: [
                    for (final member in members)
                      [
                        Text(member.userId),
                        Text(member.userName),
                        Text(
                          member.useYn == 'Y' ? 'Y' : 'N',
                          style: TextStyle(
                            color: member.useYn == 'Y'
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final apiError = error is ApiException ? error as ApiException : null;
    final message = apiError?.message ?? '회원 목록을 불러오지 못했습니다.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    height: 1.4,
                  ),
            ),
            if (apiError?.traceId != null) ...[
              const SizedBox(height: 8),
              Text(
                'traceId: ${apiError!.traceId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
