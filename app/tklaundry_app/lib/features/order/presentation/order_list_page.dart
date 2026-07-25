import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/lookup/tk_lookup_field.dart';
import '../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_confirm_dialog.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../../customer/data/customer_api.dart';
import '../../customer/domain/customer.dart';
import '../../product/data/product_api.dart';
import '../data/order_api.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';
import '../domain/order_list_result.dart';
import 'order_provider.dart';
import 'order_register_dialog.dart';

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  static const _masterColumns = [
    TkGridColumn(label: '접수 일자'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
    TkGridColumn(label: '출고 일자'),
  ];

  static const _detailColumns = [
    TkGridColumn(label: '순번', numeric: true),
    TkGridColumn(label: '제품'),
    TkGridColumn(label: '처리 방법'),
    TkGridColumn(label: '단가', numeric: true),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '비고'),
  ];

  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedCustCode;
  int? _selectedRowIndex;
  String? _selectedOrderNo;
  bool _initialized = false;

  List<Customer> _customers = [];
  bool _customersReady = false;

  Map<String, String> _productNameByCode = {};

  final _customerApi = CustomerApi();
  final _productApi = ProductApi();
  final _orderApi = OrderApi();
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _startDate = DateTime(today.year, today.month, today.day);
    _endDate = _startDate;
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
      _selectedOrderNo = null;
    });
    await ref.read(orderListProvider.notifier).search(
          OrderSearchParams(
            startDate: _startDate,
            endDate: _endDate,
            custCode: _selectedCustCode,
          ),
        );
  }

  Future<void> _openRegisterDialog() async {
    // 레거시 FrmOrderView: 목록에서 고객 선택 후에만 등록 화면 진입.
    final custCode = _selectedCustCode;
    if (custCode == null || custCode.isEmpty) {
      context.showTkMessage('고객을 선택해 주세요.');
      return;
    }

    final customer = _customerByCode[custCode];
    if (customer == null) {
      context.showTkMessage('고객을 선택해 주세요.');
      return;
    }

    final created = await OrderRegisterDialog.showCreate(
      context,
      customer: customer,
    );
    if (!mounted || created != true) return;
    await _search();
    if (!mounted) return;
    context.showTkMessage('접수가 등록되었습니다.');
  }

  bool _hasCompletedDetail(List<OrderDetail> details) {
    return details.any((detail) => detail.completeYn == 'Y');
  }

  Future<void> _openEditDialog(Order order) async {
    List<OrderDetail> details;
    try {
      details = await _orderApi.listOrderDetails(order.orderNo);
    } on ApiException catch (error) {
      if (!mounted) return;
      context.showTkApiError(error);
      return;
    }

    if (!mounted) return;

    // 레거시: 출고된 상세가 있으면 수정 불가.
    if (_hasCompletedDetail(details)) {
      context.showTkMessage('출고된 내역이 있어서 수정이 불가합니다.');
      return;
    }

    final customer = _customerByCode[order.custCode] ??
        Customer(
          custCode: order.custCode,
          custName: _customerName(order.custCode),
          aptCode: '',
          buildingCode: '',
          floorCode: '',
          roomCode: '',
          custPhone: '',
        );

    final result = await OrderRegisterDialog.showEdit(
      context,
      customer: customer,
      order: order,
      details: details,
      productNames: _productNameByCode,
    );
    if (!mounted || result == null || result == false) return;

    await _search();
    if (!mounted) return;

    if (result == OrderFormResult.deleted) {
      context.showTkMessage('접수가 삭제되었습니다.');
    } else {
      context.showTkMessage('접수가 수정되었습니다.');
    }
  }

  Future<void> _deleteSelected(Order order) async {
    List<OrderDetail> details;
    try {
      details = await _orderApi.listOrderDetails(order.orderNo);
    } on ApiException catch (error) {
      if (!mounted) return;
      context.showTkApiError(error);
      return;
    }

    if (!mounted) return;

    if (_hasCompletedDetail(details)) {
      context.showTkMessage('출고된 내역이 있어서 삭제가 불가합니다.');
      return;
    }

    final confirmed = await showTkConfirmDialog(
      context,
      title: '접수 삭제',
      message: '선택한 접수를 삭제하시겠습니까?',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _orderApi.deleteOrder(order.orderNo);
      if (!mounted) return;
      await _search();
      if (!mounted) return;
      context.showTkMessage('접수가 삭제되었습니다.');
    } on ApiException catch (error) {
      if (!mounted) return;
      context.showTkApiError(error);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final orderListAsync = ref.watch(orderListProvider);
    final codes = ref.watch(codeProvider);
    _ensureInitialSearch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '접수',
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
              label: '등록',
              variant: TkButtonVariant.outline,
              icon: Icons.add,
              onPressed: !_customersReady ? null : _openRegisterDialog,
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '삭제',
              variant: TkButtonVariant.outline,
              icon: Icons.delete_outline,
              isLoading: _isDeleting,
              onPressed: _isDeleting || _selectedRowIndex == null
                  ? null
                  : () {
                      final orders = orderListAsync.asData?.value.items;
                      if (orders == null ||
                          _selectedRowIndex! >= orders.length) {
                        return;
                      }
                      _deleteSelected(orders[_selectedRowIndex!]);
                    },
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: orderListAsync.isLoading,
              onPressed: !_customersReady || orderListAsync.isLoading ? null : _search,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: TkGridPanel(
            child: !_customersReady
                ? const Center(child: CircularProgressIndicator())
                : orderListAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => TkAsyncErrorBody(
                      error: error,
                      fallbackMessage: '접수 목록을 불러오지 못했습니다.',
                    ),
                    data: (result) => TkGridTable(
                      columns: _masterColumns,
                      itemCount: result.items.length,
                      itemBuilder: (index) =>
                          _buildMasterRow(codes, result.items[index]),
                      selectedRowIndex: _selectedRowIndex,
                      onRowTap: (index) {
                        final order = result.items[index];
                        setState(() {
                          _selectedRowIndex = index;
                          _selectedOrderNo = order.orderNo;
                        });
                      },
                      onRowDoubleTap: (index) {
                        setState(() {
                          _selectedRowIndex = index;
                          _selectedOrderNo = result.items[index].orderNo;
                        });
                        _openEditDialog(result.items[index]);
                      },
                    ),
                  ),
          ),
        ),
        if (_selectedCustCode != null) ...[
          const SizedBox(height: 8),
          _OrderSummaryFooter(result: orderListAsync.asData?.value),
        ],
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: TkGridPanel(
            child: _selectedOrderNo == null
                ? const Center(child: Text('접수를 선택하면 상세가 표시됩니다.'))
                : _OrderDetailPanel(
                    orderNo: _selectedOrderNo!,
                    codes: codes,
                    productName: _productName,
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMasterRow(List<Code> codes, Order order) {
    return [
      Text(order.orderDate.toDisplayDateTime()),
      Text(_customerName(order.custCode)),
      Text(order.qty.formatted),
      Text(order.discount.formatted),
      Text(order.cost.formatted),
      Text(codes.displayName(order.status)),
      Text(order.deliveryDate.toDisplayDateTime(hideUnassigned: true)),
    ];
  }
}

class _OrderSummaryFooter extends StatelessWidget {
  const _OrderSummaryFooter({required this.result});

  final OrderListResult? result;

  @override
  Widget build(BuildContext context) {
    final count = result?.count ?? 0;
    final totalAmount = result?.totalAmount ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('건수: ${count.formatted}'),
          const SizedBox(width: 24),
          Text('총액: ${totalAmount.formatted}'),
        ],
      ),
    );
  }
}

class _OrderDetailPanel extends ConsumerWidget {
  const _OrderDetailPanel({
    required this.orderNo,
    required this.codes,
    required this.productName,
  });

  final String orderNo;
  final List<Code> codes;
  final String Function(String productCode) productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(orderDetailListProvider(orderNo));

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => TkAsyncErrorBody(
        error: error,
        fallbackMessage: '접수 상세를 불러오지 못했습니다.',
      ),
      data: (details) => TkGridTable(
        columns: _OrderListPageState._detailColumns,
        itemCount: details.length,
        itemBuilder: (index) => _buildDetailRow(codes, details[index]),
      ),
    );
  }

  List<Widget> _buildDetailRow(List<Code> codes, OrderDetail detail) {
    return [
      Text(detail.orderSeq.formatted),
      Text(productName(detail.productCode)),
      Text(codes.displayName(detail.processCode)),
      Text(detail.price.formatted),
      Text(detail.qty.formatted),
      Text(detail.discount.formatted),
      Text(detail.cost.formatted),
      Text(detail.remark ?? ''),
    ];
  }
}
