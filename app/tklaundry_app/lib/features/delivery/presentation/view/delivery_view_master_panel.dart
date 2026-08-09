import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/tk_format.dart';
import '../../../../shared/widgets/tk_async_error_body.dart';
import '../../../../shared/widgets/tk_grid_panel.dart';
import '../../../../shared/widgets/tk_grid_table.dart';
import '../../../code/domain/code.dart';
import '../../../code/presentation/code_list_extensions.dart';
import '../../domain/delivery.dart';
import '../../domain/delivery_list_result.dart';

class DeliveryViewMasterPanel extends StatelessWidget {
  const DeliveryViewMasterPanel({
    super.key,
    required this.customersReady,
    required this.deliveryViewListAsync,
    required this.codes,
    required this.customerName,
    required this.selectedRowIndex,
    required this.onDeliverySelected,
  });

  final bool customersReady;
  final AsyncValue<DeliveryListResult> deliveryViewListAsync;
  final List<Code> codes;
  final String Function(String custCode) customerName;
  final int? selectedRowIndex;
  final void Function(Delivery delivery, int index) onDeliverySelected;

  static const _masterColumns = [
    TkGridColumn(label: '접수 일자'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
    TkGridColumn(label: '뱅킹', width: 80, align: TextAlign.center),
    TkGridColumn(label: '출고 일자'),
  ];

  @override
  Widget build(BuildContext context) {
    return TkGridPanel(
      child: !customersReady
          ? const Center(child: CircularProgressIndicator())
          : deliveryViewListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => TkAsyncErrorBody(
                error: error,
                fallbackMessage: '출고 내역을 불러오지 못했습니다.',
              ),
              data: (result) => TkGridTable(
                columns: _masterColumns,
                itemCount: result.items.length,
                itemBuilder: (index) =>
                    _buildMasterRow(codes, result.items[index]),
                selectedRowIndex: selectedRowIndex,
                onRowTap: (index) {
                  onDeliverySelected(result.items[index], index);
                },
              ),
            ),
    );
  }

  List<Widget> _buildMasterRow(List<Code> codes, Delivery delivery) {
    return [
      Text(delivery.orderDate.toDisplayDateTime()),
      Text(customerName(delivery.custCode)),
      Text(delivery.qty.formatted),
      Text(delivery.discount.formatted),
      Text(delivery.cost.formatted),
      Text(_paymentStatusLabel(codes, delivery.status)),
      Checkbox(
        value: delivery.bankingYn == 'Y',
        onChanged: null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      Text(delivery.deliveryDate.toDisplayDateTime()),
    ];
  }

  String _paymentStatusLabel(List<Code> codes, String statusCode) {
    final label = codes.displayName(statusCode);
    if (label == '일반') return '';
    return label;
  }
}
