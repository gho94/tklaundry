import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/tk_format.dart';
import '../../../../shared/widgets/tk_async_error_body.dart';
import '../../../../shared/widgets/tk_grid_table.dart';
import '../../../code/domain/code.dart';
import '../../../code/presentation/code_list_extensions.dart';
import '../../../order/domain/order_detail.dart';
import '../../data/delivery_api.dart';
import '../delivery_provider.dart';

class DeliveryDetailPanel extends ConsumerStatefulWidget {
  const DeliveryDetailPanel({
    super.key,
    required this.orderNo,
    required this.codes,
    required this.productName,
    this.enabled = true,
    this.onSelectionChanged,
    this.onEditsChanged,
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
  final bool enabled;
  final ValueChanged<Set<int>>? onSelectionChanged;
  final ValueChanged<Map<int, DeliveryLineEdit>>? onEditsChanged;

  @override
  ConsumerState<DeliveryDetailPanel> createState() =>
      _DeliveryDetailPanelState();
}

class _DeliveryDetailPanelState extends ConsumerState<DeliveryDetailPanel> {
  final Set<int> _selectedOrderSeqs = {};
  final Map<int, TextEditingController> _discountControllers = {};
  final Map<int, TextEditingController> _remarkControllers = {};
  bool _selectionInitialized = false;

  @override
  void didUpdateWidget(DeliveryDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderNo != widget.orderNo) {
      _selectedOrderSeqs.clear();
      _selectionInitialized = false;
      _disposeLineControllers();
    }
  }

  @override
  void dispose() {
    _disposeLineControllers();
    super.dispose();
  }

  void _disposeLineControllers() {
    for (final controller in _discountControllers.values) {
      controller.dispose();
    }
    for (final controller in _remarkControllers.values) {
      controller.dispose();
    }
    _discountControllers.clear();
    _remarkControllers.clear();
  }

  void _syncLineControllers(List<OrderDetail> details) {
    final seqs = details.map((detail) => detail.orderSeq).toSet();
    final removed = _remarkControllers.keys
        .where((seq) => !seqs.contains(seq))
        .toList();
    for (final seq in removed) {
      _discountControllers.remove(seq)?.dispose();
      _remarkControllers.remove(seq)?.dispose();
    }

    for (final detail in details) {
      _discountControllers.putIfAbsent(
        detail.orderSeq,
        () => TextEditingController(text: detail.discount.toString())
          ..addListener(() => _onLineChanged(details)),
      );
      _remarkControllers.putIfAbsent(
        detail.orderSeq,
        () => TextEditingController(text: detail.remark ?? '')
          ..addListener(() => _onLineChanged(details)),
      );
    }
  }

  void _onLineChanged(List<OrderDetail> details) {
    if (!mounted) return;
    setState(() {});
    widget.onEditsChanged?.call(_editsOf(details));
  }

  Map<int, DeliveryLineEdit> _editsOf(List<OrderDetail> details) {
    return {
      for (final detail in details)
        detail.orderSeq: DeliveryLineEdit(
          discount: _discountOf(detail.orderSeq),
          cost: _costOf(detail),
          remark: _remarkOf(detail.orderSeq),
        ),
    };
  }

  int _discountOf(int orderSeq) {
    return _parseInt(_discountControllers[orderSeq]?.text ?? '');
  }

  int _costOf(OrderDetail detail) {
    return detail.price * detail.qty - _discountOf(detail.orderSeq);
  }

  String? _remarkOf(int orderSeq) {
    final value = _remarkControllers[orderSeq]?.text.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static int _parseInt(String raw) {
    final cleaned = raw.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
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

        _syncLineControllers(details);
        _scheduleSelectAll(details);
        final selectedOrderSeqs = _selectedForDisplay(details);

        return TkGridTable(
          columns: DeliveryDetailPanel._columns,
          headerCellBuilder: (columnIndex, column) {
            if (columnIndex != 0) return null;
            return Checkbox(
              tristate: true,
              value: _headerCheckboxValue(details, selectedOrderSeqs),
              onChanged: widget.enabled
                  ? (value) => _toggleSelectAll(details, value)
                  : null,
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
        onChanged: widget.enabled
            ? (selected) => _toggleSelection(detail.orderSeq, selected)
            : null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      Text(widget.productName(detail.productCode)),
      Text(codes.displayName(detail.processCode)),
      Text(detail.price.formatted),
      _GridNumberField(
        controller: _discountControllers[detail.orderSeq]!,
        readOnly: !widget.enabled,
      ),
      Text(_costOf(detail).formatted),
      Text(detail.qty.formatted),
      _GridTextField(
        controller: _remarkControllers[detail.orderSeq]!,
        readOnly: !widget.enabled,
      ),
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

class _GridNumberField extends StatelessWidget {
  const _GridNumberField({
    required this.controller,
    required this.readOnly,
  });

  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      textAlign: TextAlign.right,
      style: Theme.of(context).textTheme.bodyMedium,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'-?[0-9]*')),
      ],
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }
}

class _GridTextField extends StatelessWidget {
  const _GridTextField({
    required this.controller,
    required this.readOnly,
  });

  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }
}
