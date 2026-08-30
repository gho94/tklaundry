import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../domain/sales.dart';
import '../domain/sales_list_result.dart';

class SalesViewMasterPanel extends StatelessWidget {
  const SalesViewMasterPanel({
    super.key,
    required this.customersReady,
    required this.salesViewListAsync,
    required this.codes,
    required this.customerName,
    required this.selectedRowIndex,
    required this.onSalesSelected,
  });

  final bool customersReady;
  final AsyncValue<SalesListResult> salesViewListAsync;
  final List<Code> codes;
  final String Function(String custCode) customerName;
  final int? selectedRowIndex;
  final void Function(Sales sales, int index) onSalesSelected;

  static const _masterColumns = [
    TkGridColumn(label: '매출 일자'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
  ];

  @override
  Widget build(BuildContext context) {
    return TkGridPanel(
      child: !customersReady
          ? const Center(child: CircularProgressIndicator())
          : salesViewListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => TkAsyncErrorBody(
                error: error,
                fallbackMessage: '매출 목록을 불러오지 못했습니다.',
              ),
              data: (result) => TkGridTable(
                columns: _masterColumns,
                itemCount: result.items.length,
                itemBuilder: (index) => _buildMasterRow(codes, result.items[index]),
                selectedRowIndex: selectedRowIndex,
                onRowTap: (index) {
                  onSalesSelected(result.items[index], index);
                },
              ),
            ),
    );
  }

  List<Widget> _buildMasterRow(List<Code> codes, Sales sales) {
    return [
      Text(sales.salesDate.toDisplayDateTime()),
      Text(customerName(sales.custCode)),
      Text(sales.qty.formatted),
      Text(sales.discount.formatted),
      Text(sales.cost.formatted),
      Text(_paymentStatusLabel(codes, sales.status)),
    ];
  }

  String _paymentStatusLabel(List<Code> codes, String statusCode) {
    final label = codes.displayName(statusCode);
    if (label == '일반') return '';
    return label;
  }
}
