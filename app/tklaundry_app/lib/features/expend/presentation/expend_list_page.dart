import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../domain/expend.dart';
import 'expend_provider.dart';
import 'expend_register_dialog.dart';

class ExpendListPage extends ConsumerStatefulWidget {
  const ExpendListPage({super.key});

  @override
  ConsumerState<ExpendListPage> createState() => _ExpendListPageState();
}

class _ExpendListPageState extends ConsumerState<ExpendListPage> {
  static const _columns = [
    TkGridColumn(label: '지출 일자'),
    TkGridColumn(label: '지출 종류'),
    TkGridColumn(label: '지출 비용', numeric: true),
    TkGridColumn(label: '비고'),
  ];

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

  String _formatExpendDate(String expendDate) {
    final parsed = DateTime.tryParse(expendDate);
    if (parsed == null) return expendDate;
    return DateTime(parsed.year, parsed.month, parsed.day).toApiDate();
  }

  @override
  Widget build(BuildContext context) {
    final expendListAsync = ref.watch(expendListProvider);
    final codes = ref.watch(codeProvider);
    _ensureInitialSearch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '지출',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: () => _pickDate(
                  initialDate: _startDate,
                  onSelected: (date) {
                    setState(() => _startDate = date);
                    _startDateController.text = date.toApiDate();
                  },
                ),
                child: AbsorbPointer(
                  child: TkTextField(
                    label: '시작일',
                    readOnly: true,
                    controller: _startDateController,
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: () => _pickDate(
                  initialDate: _endDate,
                  onSelected: (date) {
                    setState(() => _endDate = date);
                    _endDateController.text = date.toApiDate();
                  },
                ),
                child: AbsorbPointer(
                  child: TkTextField(
                    label: '종료일',
                    readOnly: true,
                    controller: _endDateController,
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ),
            ),
            const Spacer(),
            TkPrimaryButton(
              label: '등록',
              variant: TkButtonVariant.outline,
              icon: Icons.add_outlined,
              onPressed: _openRegisterDialog,
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: expendListAsync.isLoading,
              onPressed: expendListAsync.isLoading ? null : _search,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TkGridPanel(
            child: expendListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => TkAsyncErrorBody(
                error: error,
                fallbackMessage: '지출 목록을 불러오지 못했습니다.',
              ),
              data: (result) {
                if (_selectedRowIndex != null &&
                    _selectedRowIndex! >= result.items.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _selectedRowIndex = null);
                    }
                  });
                }

                return TkGridTable(
                  columns: _columns,
                  itemCount: result.items.length,
                  itemBuilder: (index) =>
                      _buildRow(codes, result.items[index]),
                  selectedRowIndex: _selectedRowIndex,
                  onRowTap: (index) =>
                      setState(() => _selectedRowIndex = index),
                  onRowDoubleTap: (index) =>
                      _openEditDialog(result.items[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRow(List<Code> codes, Expend expend) {
    return [
      Text(_formatExpendDate(expend.expendDate)),
      Text(codes.displayName(expend.expendCode)),
      Text(expend.cost.formatted),
      Text(expend.remark),
    ];
  }
}
