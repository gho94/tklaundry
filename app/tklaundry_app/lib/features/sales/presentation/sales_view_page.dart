import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/lookup/tk_lookup_field.dart';
import '../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../../customer/data/customer_api.dart';
import '../../customer/domain/customer.dart';
import '../../delivery/presentation/delivery_summary_footer.dart';
import '../../product/data/product_api.dart';
import '../domain/sales.dart';
import 'sales_view_detail_panel.dart';
import 'sales_view_provider.dart';

class SalesViewPage extends ConsumerStatefulWidget {
  const SalesViewPage({super.key});

  @override
  ConsumerState<SalesViewPage> createState() => _SalesViewPageState();
}

class _SalesViewPageState extends ConsumerState<SalesViewPage> {
  static const _masterColumns = [
    TkGridColumn(label: '매출 일자'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
  ];

  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedCustCode;
  int? _selectedRowIndex;
  String? _selectedSalesNo;
  bool _initialized = false;

  List<Customer> _customers = [];
  bool _customersReady = false;

  Map<String, String> _productNameByCode = {};

  final _customerApi = CustomerApi();
  final _productApi = ProductApi();
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
    _loadCustomers();
    _loadProducts();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _customerApi.listCustomers();
      if (!mounted) return;
      setState(() {
        _customers = customers;
        _customersReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _customersReady = true);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productApi.listProducts();
      if (!mounted) return;
      setState(() {
        _productNameByCode = {
          for (final product in products)
            product.productCode: product.productName,
        };
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  List<TkLookupItem<String>> get _customerLookupItems {
    return [
      for (final customer in _customers)
        TkLookupItem(
          value: customer.custCode,
          label: customer.custName,
          subtitle: customer.custPhone,
        ),
    ];
  }

  Map<String, Customer> get _customerByCode {
    return {for (final customer in _customers) customer.custCode: customer};
  }

  Future<void> _search() async {
    setState(() {
      _selectedRowIndex = null;
      _selectedSalesNo = null;
    });
    await ref.read(salesViewListProvider.notifier).search(
          SalesSearchParams(
            startDate: _startDate,
            endDate: _endDate,
            custCode: _selectedCustCode,
          ),
        );
  }

  void _ensureInitialSearch() {
    if (_initialized || !_customersReady) return;
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

  String _customerName(String custCode) {
    return _customerByCode[custCode]?.custName ?? custCode;
  }

  String _productName(String productCode) {
    return _productNameByCode[productCode] ?? productCode;
  }

  String _paymentStatusLabel(List<Code> codes, String statusCode) {
    final label = codes.displayName(statusCode);
    if (label == '일반') return '';
    return label;
  }

  void _selectSales(Sales sales, int index) {
    setState(() {
      _selectedRowIndex = index;
      _selectedSalesNo = sales.salesNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesViewListAsync = ref.watch(salesViewListProvider);
    final codes = ref.watch(codeProvider);
    _ensureInitialSearch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '매출',
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
                    suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
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
                    suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 220,
              child: TkLookupField<String>(
                label: '고객',
                hint: '고객명 · 전화번호 검색',
                primaryColumnLabel: '고객',
                secondaryColumnLabel: '전화번호',
                panelMinWidth: 360,
                items: _customerLookupItems,
                value: _selectedCustCode,
                enabled: _customersReady,
                showAllOption: true,
                onChanged: (custCode) {
                  setState(() => _selectedCustCode = custCode);
                  _search();
                },
              ),
            ),
            const Spacer(),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: salesViewListAsync.isLoading,
              onPressed: !_customersReady || salesViewListAsync.isLoading
                  ? null
                  : _search,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: TkGridPanel(
            child: !_customersReady
                ? const Center(child: CircularProgressIndicator())
                : salesViewListAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => TkAsyncErrorBody(
                      error: error,
                      fallbackMessage: '매출 목록을 불러오지 못했습니다.',
                    ),
                    data: (result) => TkGridTable(
                      columns: _masterColumns,
                      itemCount: result.items.length,
                      itemBuilder: (index) =>
                          _buildMasterRow(codes, result.items[index]),
                      selectedRowIndex: _selectedRowIndex,
                      onRowTap: (index) {
                        _selectSales(result.items[index], index);
                      },
                    ),
                  ),
          ),
        ),
        if (_selectedCustCode != null) ...[
          const SizedBox(height: 8),
          DeliverySummaryFooter(
            count: salesViewListAsync.asData?.value.count,
            totalAmount: salesViewListAsync.asData?.value.totalAmount,
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: TkGridPanel(
            child: _selectedSalesNo == null
                ? const Center(child: Text('매출 건을 선택하면 상세가 표시됩니다.'))
                : SalesViewDetailPanel(
                    salesNo: _selectedSalesNo!,
                    codes: codes,
                    productName: _productName,
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMasterRow(List<Code> codes, Sales sales) {
    return [
      Text(sales.salesDate.toDisplayDateTime()),
      Text(_customerName(sales.custCode)),
      Text(sales.qty.formatted),
      Text(sales.discount.formatted),
      Text(sales.cost.formatted),
      Text(_paymentStatusLabel(codes, sales.status)),
    ];
  }
}
