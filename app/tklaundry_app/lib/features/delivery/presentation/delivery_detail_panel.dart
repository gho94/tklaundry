import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../order/domain/order_detail.dart';
import 'delivery_provider.dart';

class DeliveryDetailPanel extends ConsumerStatefulWidget {
  const DeliveryDetailPanel({
    super.key,
    required this.orderNo,
    required this.codes,
    required this.productName,
    this.onSelectionChanged,
  });

  static const _columns = [
    TkGridColumn(label: '', width: 44, align: TextAlign.center),
    TkGridColumn(label: '제품'),
    TkGridColumn(label: '처리 방법'),
    TkGridColumn(label: '단가', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '비고'),
  ];

  final String orderNo;
  final List<Code> codes;
  final String Function(String productCode) productName;
  final ValueChanged<Set<int>>? onSelectionChanged;

  @override
  ConsumerState<DeliveryDetailPanel> createState() => _DeliveryDetailPanelState();
}

class _DeliveryDetailPanelState extends ConsumerState<DeliveryDetailPanel> {
  final Set<int> _selectedOrderSeqs = {};
  bool _selectionInitialized = false;

  @override
  void didUpdateWidget(DeliveryDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderNo != widget.orderNo) {
      _selectedOrderSeqs.clear();
      _selectionInitialized = false;
    }
  }

  void _scheduleSelectAll(List<OrderDetail> details) {
    if (_selectionInitialized) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectionInitialized) return;
      setState(() {
        _selectedOrderSeqs.addAll(details.map((detail) => detail.orderSeq));
        _selectionInitialized = true;
      });
      widget.onSelectionChanged?.call(Set.unmodifiable(_selectedOrderSeqs));
    });
  }

  Set<int> _selectedForDisplay(List<OrderDetail> details) {
    if (_selectionInitialized) return _selectedOrderSeqs;
    return details.map((detail) => detail.orderSeq).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(deliveryDetailListProvider(widget.orderNo));

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => TkAsyncErrorBody(
        error: error,
        fallbackMessage: '출고 대상 접수 상세를 불러오지 못했습니다.',
      ),
      data: (details) {
        if (details.isEmpty) {
          return const Center(child: Text('미출고 상세가 없습니다.'));
        }

        _scheduleSelectAll(details);
        final selectedOrderSeqs = _selectedForDisplay(details);

        return TkGridTable(
          columns: DeliveryDetailPanel._columns,
          headerCellBuilder: (columnIndex, column) {
            if (columnIndex != 0) return null;
            return Checkbox(
              tristate: true,
              value: _headerCheckboxValue(details, selectedOrderSeqs),
              onChanged: (value) => _toggleSelectAll(details, value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          },
          itemCount: details.length,
          itemBuilder: (index) => _buildDetailRow(
            widget.codes,
            details[index],
            selectedOrderSeqs,
          ),
        );
      },
    );
  }

  List<Widget> _buildDetailRow(
    List<Code> codes,
    OrderDetail detail,
    Set<int> selectedOrderSeqs,
  ) {
    return [
      Checkbox(
        value: selectedOrderSeqs.contains(detail.orderSeq),
        onChanged: (selected) => _toggleSelection(detail.orderSeq, selected),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      Text(widget.productName(detail.productCode)),
      Text(codes.displayName(detail.processCode)),
      Text(detail.price.formatted),
      Text(detail.discount.formatted),
      Text(detail.cost.formatted),
      Text(detail.qty.formatted),
      Text(detail.remark ?? ''),
    ];
  }

  bool? _headerCheckboxValue(
    List<OrderDetail> details,
    Set<int> selectedOrderSeqs,
  ) {
    if (details.isEmpty) return false;

    final detailSeqs = details.map((detail) => detail.orderSeq);
    final selectedCount =
        detailSeqs.where(selectedOrderSeqs.contains).length;

    if (selectedCount == 0) return false;
    if (selectedCount == details.length) return true;
    return null;
  }

  void _toggleSelectAll(List<OrderDetail> details, bool? value) {
    setState(() {
      _selectionInitialized = true;
      _selectedOrderSeqs.clear();
      if (value == true) {
        _selectedOrderSeqs.addAll(details.map((detail) => detail.orderSeq));
      }
    });
    widget.onSelectionChanged?.call(Set.unmodifiable(_selectedOrderSeqs));
  }

  void _toggleSelection(int orderSeq, bool? selected) {
    setState(() {
      _selectionInitialized = true;
      if (selected == true) {
        _selectedOrderSeqs.add(orderSeq);
      } else {
        _selectedOrderSeqs.remove(orderSeq);
      }
    });
    widget.onSelectionChanged?.call(Set.unmodifiable(_selectedOrderSeqs));
  }
}
