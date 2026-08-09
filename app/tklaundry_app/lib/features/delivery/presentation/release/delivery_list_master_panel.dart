import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/tk_format.dart';
import '../../../../shared/widgets/tk_async_error_body.dart';
import '../../../../shared/widgets/tk_grid_panel.dart';
import '../../../../shared/widgets/tk_grid_table.dart';
import '../../../code/domain/code.dart';
import '../../../code/presentation/code_list_extensions.dart';
import '../../../order/domain/order.dart';
import '../../../order/domain/order_list_result.dart';

class DeliveryListMasterPanel extends StatelessWidget {
  const DeliveryListMasterPanel({
    super.key,
    required this.customersReady,
    required this.deliveryListAsync,
    required this.codes,
    required this.customerName,
    required this.selectedRowIndex,
    required this.onOrderSelected,
  });

  final bool customersReady;
  final AsyncValue<OrderListResult> deliveryListAsync;
  final List<Code> codes;
  final String Function(String custCode) customerName;
  final int? selectedRowIndex;
  final void Function(Order order, int index) onOrderSelected;

  static const _masterColumns = [
    TkGridColumn(label: '접수 일자'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
    TkGridColumn(label: '출고 일자'),
  ];

  @override
  Widget build(BuildContext context) {
    return TkGridPanel(
      child: !customersReady
          ? const Center(child: CircularProgressIndicator())
          : deliveryListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => TkAsyncErrorBody(
                error: error,
                fallbackMessage: '출고 대상 접수 목록을 불러오지 못했습니다.',
              ),
              data: (result) => TkGridTable(
                columns: _masterColumns,
                itemCount: result.items.length,
                itemBuilder: (index) => _buildMasterRow(codes, result.items[index]),
                selectedRowIndex: selectedRowIndex,
                onRowTap: (index) {
                  onOrderSelected(result.items[index], index);
                },
              ),
            ),
    );
  }

  List<Widget> _buildMasterRow(List<Code> codes, Order order) {
    return [
      Text(order.orderDate.toDisplayDateTime()),
      Text(customerName(order.custCode)),
      Text(order.qty.formatted),
      Text(order.discount.formatted),
      Text(order.cost.formatted),
      Text(_paymentStatusLabel(codes, order.status)),
      Text(order.deliveryDate.toDisplayDateTime(hideUnassigned: true)),
    ];
  }

  String _paymentStatusLabel(List<Code> codes, String statusCode) {
    final label = codes.displayName(statusCode);
    if (label == '일반') return '';
    return label;
  }
}
