import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../../customer/data/customer_api.dart';
import '../../customer/domain/customer.dart';
import '../../product/data/product_api.dart';
import '../../sales/presentation/sales_view_detail_panel.dart';
import '../domain/sales_chart_daily_item.dart';
import 'sales_chart_provider.dart';

class SalesChartDailyDialog extends ConsumerStatefulWidget {
  const SalesChartDailyDialog({
    super.key,
    required this.salesDate,
  });

  final DateTime salesDate;

  static Future<void> show(
    BuildContext context, {
    required DateTime salesDate,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => SalesChartDailyDialog(salesDate: salesDate),
    );
  }

  @override
  ConsumerState<SalesChartDailyDialog> createState() =>
      _SalesChartDailyDialogState();
}

class _SalesChartDailyDialogState extends ConsumerState<SalesChartDailyDialog> {
  static const _columns = [
    TkGridColumn(label: '매출 번호'),
    TkGridColumn(label: '구분'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '지출 종류'),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
    TkGridColumn(label: '뱅킹', width: 80, align: TextAlign.center),
    TkGridColumn(label: '매출 일자'),
  ];

  final _customerApi = CustomerApi();
  final _productApi = ProductApi();

  List<Customer> _customers = [];
  Map<String, String> _productNameByCode = {};
  int? _selectedRowIndex;
  SalesChartDailyItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final customers = await _customerApi.listCustomers();
      final products = await _productApi.listProducts();
      if (!mounted) return;
      setState(() {
        _customers = customers;
        _productNameByCode = {
          for (final product in products)
            product.productCode: product.productName,
        };
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  Map<String, Customer> get _customerByCode {
    return {for (final customer in _customers) customer.custCode: customer};
  }

  String _customerName(String custCode) {
    if (custCode.isEmpty) return '';
    return _customerByCode[custCode]?.custName ?? custCode;
  }

  String _productName(String productCode) {
    return _productNameByCode[productCode] ?? productCode;
  }

  String _paymentStatusLabel(List<Code> codes, String statusCode) {
    if (statusCode.isEmpty) return '';
    final label = codes.displayName(statusCode);
    if (label == '일반') return '';
    return label;
  }

  String _expendTypeLabel(List<Code> codes, SalesChartDailyItem item) {
    if (!item.isExpendRow || item.expendCode.isEmpty) return '';
    return codes.displayName(item.expendCode);
  }

  void _selectItem(SalesChartDailyItem item, int index) {
    setState(() {
      _selectedRowIndex = index;
      _selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    final codes = ref.watch(codeProvider);
    final dailyAsync =
        ref.watch(salesChartDailyProvider(widget.salesDate.toApiDate()));

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: Text('일매출 상세 · ${widget.salesDate.toApiDate()}'),
      content: SizedBox(
        width: 1200,
        height: 640,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: TkGridPanel(
                child: dailyAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => TkAsyncErrorBody(
                    error: error,
                    fallbackMessage: '일매출 상세를 불러오지 못했습니다.',
                  ),
                  data: (result) {
                    if (result.items.isEmpty) {
                      return const Center(child: Text('내역이 없습니다.'));
                    }

                    return TkGridTable(
                      columns: _columns,
                      itemCount: result.items.length,
                      itemBuilder: (index) =>
                          _buildRow(codes, result.items[index]),
                      selectedRowIndex: _selectedRowIndex,
                      onRowTap: (index) {
                        _selectItem(result.items[index], index);
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: TkGridPanel(
                child: _selectedItem == null
                    ? const Center(child: Text('항목을 선택하면 상세가 표시됩니다.'))
                    : SalesViewDetailPanel(
                        sales: _selectedItem!.toSales(),
                        codes: codes,
                        productName: _productName,
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  List<Widget> _buildRow(List<Code> codes, SalesChartDailyItem item) {
    return [
      Text(item.salesNo),
      Text(item.salesType),
      Text(_customerName(item.custCode)),
      Text(item.qty.formatted),
      Text(item.discount.formatted),
      Text(_expendTypeLabel(codes, item)),
      Text(item.cost.formatted),
      Text(_paymentStatusLabel(codes, item.status)),
      Checkbox(
        value: item.bankingYn == 'Y',
        onChanged: null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      Text(item.salesDate),
    ];
  }
}
