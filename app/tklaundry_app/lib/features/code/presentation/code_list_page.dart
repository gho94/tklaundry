import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../data/code_api.dart';
import '../domain/code.dart';
import '../domain/code_tree.dart';
import 'code_detail_panel.dart';
import 'code_edit_dialog.dart';
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
  bool _isDeleting = false;
  bool _isSearching = false;
  Object? _searchError;
  final _codeApi = CodeApi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(codeProvider).isEmpty) {
        _search();
      }
    });
  }

  Future<void> _search() async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      await ref.read(codeProvider.notifier).search();
    } catch (error) {
      if (mounted) setState(() => _searchError = error);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
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
    await _search();
    if (!mounted) return;

    final codes = ref.read(codeProvider);

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

  Future<void> _editSelected(Code code) async {
    final updated = await CodeEditDialog.show(context, code);
    if (updated != true || !mounted) return;

    await _search();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('코드가 수정되었습니다.')),
    );
  }

  Future<void> _deleteSelected(Code code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('코드 삭제'),
        content: Text(
          '\'${code.codeName}\' (${code.codeId}) 코드와\n하위 코드를 모두 삭제하시겠습니까?',
        ),
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
      await _codeApi.deleteCode(code.codeId);
      if (!mounted) return;

      await _search();
      if (!mounted) return;

      setState(() => _selectedCodeId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코드가 삭제되었습니다.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Widget _buildBody(List<Code> codes) {
    if (_isSearching && codes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchError != null && codes.isEmpty) {
      return TkAsyncErrorBody(
        error: _searchError!,
        fallbackMessage: '코드 목록을 불러오지 못했습니다.',
      );
    }

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
            isDeleting: _isDeleting,
            onEdit: selectedCode == null || _isDeleting
                ? null
                : () => _editSelected(selectedCode),
            onDelete: selectedCode == null || _isDeleting
                ? null
                : () => _deleteSelected(selectedCode),
            onAddChild: selectedCode == null || _isDeleting
                ? null
                : () => _addChild(selectedCode),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final codes = ref.watch(codeProvider);
    final isBusy = _isSearching || _isDeleting;

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
              onPressed: isBusy ? null : _addTopLevel,
            ),
            const SizedBox(width: AppSpacing.s2),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: _isSearching,
              onPressed: isBusy ? null : _search,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildBody(codes)),
      ],
    );
  }
}
