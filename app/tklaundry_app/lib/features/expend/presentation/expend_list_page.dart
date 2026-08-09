import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/utils/tk_format.dart';
import '../../code/presentation/code_provider.dart';
import '../domain/expend.dart';
import 'expend_list_grid_panel.dart';
import 'expend_list_toolbar.dart';
import 'expend_provider.dart';
import 'expend_register_dialog.dart';

class ExpendListPage extends ConsumerStatefulWidget {
  const ExpendListPage({super.key});

  @override
  ConsumerState<ExpendListPage> createState() => _ExpendListPageState();
}

class _ExpendListPageState extends ConsumerState<ExpendListPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  int? _selectedRowIndex;
  bool _initialized = false;

  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    _startDate = todayDate;
    _endDate = todayDate;
    _startDateController = TextEditingController(text: _startDate.toApiDate());
    _endDateController = TextEditingController(text: _endDate.toApiDate());
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _selectedRowIndex = null);
    await ref.read(expendListProvider.notifier).search(
          ExpendSearchParams(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  void _ensureInitialSearch() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search();
    });
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    onSelected(DateTime(picked.year, picked.month, picked.day));
    await _search();
  }

  Future<void> _openRegisterDialog() async {
    final created = await ExpendRegisterDialog.showCreate(context);
    if (!mounted || created != true) return;
    await _search();
    if (!mounted) return;
    context.showTkMessage('지출이 등록되었습니다.');
  }

  Future<void> _openEditDialog(Expend expend) async {
    final updated = await ExpendRegisterDialog.showEdit(context, expend);
    if (!mounted || updated != true) return;
    await _search();
    if (!mounted) return;
    context.showTkMessage('지출 정보가 수정되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final expendListAsync = ref.watch(expendListProvider);
    final codes = ref.watch(codeProvider);
    _ensureInitialSearch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpendListSearchToolbar(
          startDateController: _startDateController,
          endDateController: _endDateController,
          onPickStartDate: () => _pickDate(
            initialDate: _startDate,
            onSelected: (date) {
              setState(() => _startDate = date);
              _startDateController.text = date.toApiDate();
            },
          ),
          onPickEndDate: () => _pickDate(
            initialDate: _endDate,
            onSelected: (date) {
              setState(() => _endDate = date);
              _endDateController.text = date.toApiDate();
            },
          ),
          onRegister: _openRegisterDialog,
          onSearch: _search,
          isLoading: expendListAsync.isLoading,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ExpendListGridPanel(
            expendListAsync: expendListAsync,
            codes: codes,
            selectedRowIndex: _selectedRowIndex,
            onRowSelected: (index) {
              setState(() => _selectedRowIndex = index);
            },
            onRowEdit: _openEditDialog,
            onSelectionCleared: () {
              if (!mounted) return;
              setState(() => _selectedRowIndex = null);
            },
          ),
        ),
      ],
    );
  }
}
