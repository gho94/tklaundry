import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../domain/expend.dart';
import '../domain/expend_list_result.dart';

class ExpendListGridPanel extends StatelessWidget {
  const ExpendListGridPanel({
    super.key,
    required this.expendListAsync,
    required this.codes,
    required this.selectedRowIndex,
    required this.onRowSelected,
    required this.onRowEdit,
    required this.onSelectionCleared,
  });

  final AsyncValue<ExpendListResult> expendListAsync;
  final List<Code> codes;
  final int? selectedRowIndex;
  final ValueChanged<int> onRowSelected;
  final ValueChanged<Expend> onRowEdit;
  final VoidCallback onSelectionCleared;

  static const _columns = [
    TkGridColumn(label: '지출 일자'),
    TkGridColumn(label: '지출 종류'),
    TkGridColumn(label: '지출 비용', numeric: true),
    TkGridColumn(label: '비고'),
  ];

  @override
  Widget build(BuildContext context) {
    return TkGridPanel(
      child: expendListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => TkAsyncErrorBody(
          error: error,
          fallbackMessage: '지출 목록을 불러오지 못했습니다.',
        ),
        data: (result) {
          if (selectedRowIndex != null &&
              selectedRowIndex! >= result.items.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onSelectionCleared();
            });
          }

          return TkGridTable(
            columns: _columns,
            itemCount: result.items.length,
            itemBuilder: (index) => _buildRow(codes, result.items[index]),
            selectedRowIndex: selectedRowIndex,
            onRowTap: onRowSelected,
            onRowDoubleTap: (index) => onRowEdit(result.items[index]),
          );
        },
      ),
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

  String _formatExpendDate(String expendDate) {
    final parsed = DateTime.tryParse(expendDate);
    if (parsed == null) return expendDate;
    return DateTime(parsed.year, parsed.month, parsed.day).toApiDate();
  }
}
