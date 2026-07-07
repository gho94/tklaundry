import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../data/member_api.dart';
import '../domain/member.dart';
import 'member_provider.dart';
import 'member_register_dialog.dart';

class MemberListPage extends ConsumerStatefulWidget {
  const MemberListPage({super.key});

  @override
  ConsumerState<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends ConsumerState<MemberListPage> {
  static const _columns = [
    TkGridColumn(label: '아이디'),
    TkGridColumn(label: '이름'),
    TkGridColumn(label: '사용여부', align: TextAlign.center),
  ];

  int? _selectedRowIndex;
  bool _isDeleting = false;
  final _memberApi = MemberApi();

  Future<void> _openRegisterDialog() async {
    final registered = await MemberRegisterDialog.showCreate(context);
    if (registered != true || !mounted) return;

    await ref.read(memberListProvider.notifier).search();
    if (!mounted) return;
    context.showTkMessage('회원이 등록되었습니다.');
  }

  Future<void> _openEditDialog(Member member) async {
    final updated = await MemberRegisterDialog.showEdit(context, member);
    if (updated != true || !mounted) return;

    await ref.read(memberListProvider.notifier).search();
    if (!mounted) return;
    setState(() => _selectedRowIndex = null);
    context.showTkMessage('회원 정보가 수정되었습니다.');
  }

  Future<void> _deleteSelected(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 삭제'),
        content: Text('\'${member.userId}\' 회원을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await _memberApi.deleteMember(member.userId);
      if (!mounted) return;

      await ref.read(memberListProvider.notifier).search();
      if (!mounted) return;

      setState(() => _selectedRowIndex = null);
      context.showTkMessage('회원이 삭제되었습니다.');
    } on ApiException catch (error) {
      if (!mounted) return;
      context.showTkApiError(error);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              label: '등록',
              variant: TkButtonVariant.outline,
              icon: Icons.person_add_outlined,
              onPressed: _openRegisterDialog,
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '수정',
              variant: TkButtonVariant.outline,
              icon: Icons.edit_outlined,
              onPressed: _selectedRowIndex == null || _isDeleting
                  ? null
                  : () {
                      final members = membersAsync.asData?.value;
                      if (members == null ||
                          _selectedRowIndex! >= members.length) {
                        return;
                      }
                      _openEditDialog(members[_selectedRowIndex!]);
                    },
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '삭제',
              variant: TkButtonVariant.outline,
              icon: Icons.delete_outline,
              isLoading: _isDeleting,
              onPressed: _selectedRowIndex == null || _isDeleting
                  ? null
                  : () {
                      final members = membersAsync.asData?.value;
                      if (members == null ||
                          _selectedRowIndex! >= members.length) {
                        return;
                      }
                      _deleteSelected(members[_selectedRowIndex!]);
                    },
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: membersAsync.isLoading,
              onPressed: membersAsync.isLoading || _isDeleting
                  ? null
                  : () => ref.read(memberListProvider.notifier).search(),
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
                error: (error, _) => TkAsyncErrorBody(
                  error: error,
                  fallbackMessage: '회원 목록을 불러오지 못했습니다.',
                ),
                data: (members) {
                  if (_selectedRowIndex != null &&
                      _selectedRowIndex! >= members.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedRowIndex = null);
                    });
                  }

                  return TkGridTable(
                    columns: _columns,
                    selectedRowIndex: _selectedRowIndex,
                    onRowTap: (index) => setState(() => _selectedRowIndex = index),
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
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
