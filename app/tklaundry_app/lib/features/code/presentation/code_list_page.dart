import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../domain/code.dart';
import '../domain/code_tree.dart';
import 'code_detail_panel.dart';
import 'code_provider.dart';
import 'code_register_dialog.dart';
import 'code_tree_panel.dart';

class CodeListPage extends ConsumerStatefulWidget {
  const CodeListPage({super.key});

  @override
  ConsumerState<CodeListPage> createState() => _CodeListPageState();
}

class _CodeListPageState extends ConsumerState<CodeListPage> {
  final Set<String> _expandedCodeIds = {};
  String? _selectedCodeId;
  bool _defaultExpansionApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(codeProvider.notifier).search();
      }
    });
  }

  void _applyDefaultExpansion(List<CodeTreeNode> roots) {
    if (_defaultExpansionApplied || roots.isEmpty) return;

    _defaultExpansionApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        for (final root in roots) {
          if (root.hasChildren) {
            _expandedCodeIds.add(root.code.codeId);
          }
        }
      });
    });
  }

  void _toggleExpanded(String codeId) {
    setState(() {
      if (_expandedCodeIds.contains(codeId)) {
        _expandedCodeIds.remove(codeId);
      } else {
        _expandedCodeIds.add(codeId);
      }
    });
  }

  void _selectCode(String codeId) {
    setState(() => _selectedCodeId = codeId);
  }

  Code? _findSelectedCode(List<Code> codes) {
    if (_selectedCodeId == null) return null;
    for (final code in codes) {
      if (code.codeId == _selectedCodeId) return code;
    }
    return null;
  }

  Code? _findCodeById(List<Code> codes, String codeId) {
    for (final code in codes) {
      if (code.codeId == codeId) return code;
    }
    return null;
  }

  Code? _findParent(List<Code> codes, Code child) {
    final parentId = child.pCodeId;
    return _findCodeById(codes, parentId) ??
        _findCodeById(codes, parentId.trim());
  }

  void _expandAncestorsOf(String codeId, List<Code> codes) {
    var current = _findCodeById(codes, codeId);
    while (current != null && !Code.isRootParent(current.pCodeId)) {
      final parent = _findParent(codes, current);
      if (parent == null) break;
      _expandedCodeIds.add(parent.codeId);
      current = parent;
    }
  }

  Future<void> _onRegistered(Code created, {String? expandParentCodeId}) async {
    await ref.read(codeProvider.notifier).search();
    if (!mounted) return;

    final codes = ref.read(codeProvider).value;
    if (codes == null) return;

    setState(() {
      _selectedCodeId = created.codeId;
      if (expandParentCodeId != null) {
        _expandAncestorsOf(expandParentCodeId, codes);
        _expandedCodeIds.add(expandParentCodeId);
      }
    });
  }

  Future<void> _addTopLevel() async {
    final created = await CodeRegisterDialog.showTopLevel(context);
    if (created == null || !mounted) return;
    await _onRegistered(created);
  }

  Future<void> _addChild(Code parent) async {
    final created = await CodeRegisterDialog.showChild(context, parent);
    if (created == null || !mounted) return;
    await _onRegistered(created, expandParentCodeId: parent.codeId);
  }

  @override
  Widget build(BuildContext context) {
    final codesAsync = ref.watch(codeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '코드',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TkPrimaryButton(
              label: '최상위 추가',
              variant: TkButtonVariant.outline,
              icon: Icons.add,
              onPressed: codesAsync.isLoading ? null : _addTopLevel,
            ),
            const SizedBox(width: AppSpacing.s2),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: codesAsync.isLoading,
              onPressed: codesAsync.isLoading
                  ? null
                  : () => ref.read(codeProvider.notifier).search(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: codesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorBody(error: error),
            data: (codes) {
              final roots = buildCodeTree(codes);
              _applyDefaultExpansion(roots);
              final rows = flattenCodeTree(
                roots,
                expandedCodeIds: _expandedCodeIds,
              );
              final selectedCode = _findSelectedCode(codes);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: CodeTreePanel(
                      rows: rows,
                      expandedCodeIds: _expandedCodeIds,
                      selectedCodeId: _selectedCodeId,
                      onToggleExpanded: _toggleExpanded,
                      onSelect: _selectCode,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    flex: 3,
                    child: CodeDetailPanel(
                      selectedCode: selectedCode,
                      codes: codes,
                      onAddChild: selectedCode == null
                          ? null
                          : () => _addChild(selectedCode),
                    ),
                  ),
                ],
              );
            },
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
    final message = apiError?.message ?? '코드 목록을 불러오지 못했습니다.';

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
