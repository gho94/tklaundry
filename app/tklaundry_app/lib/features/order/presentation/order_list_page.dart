import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../shared/widgets/tk_confirm_dialog.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../code/presentation/code_provider.dart';
import '../../customer/data/customer_api.dart';
import '../../customer/domain/customer.dart';
import '../../product/data/product_api.dart';
import '../data/order_api.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';
import 'order_list_detail_panel.dart';
import 'order_list_master_panel.dart';
import 'order_list_summary_footer.dart';
import 'order_list_toolbar.dart';
import 'order_provider.dart';
import 'order_register_dialog.dart';

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
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

  void _selectOrder(Order order, int index) {
    setState(() {
      _selectedRowIndex = index;
      _selectedOrderNo = order.orderNo;
    });
  }

  void _editOrder(Order order, int index) {
    _selectOrder(order, index);
    _openEditDialog(order);
  }

  @override
  Widget build(BuildContext context) {
    final orderListAsync = ref.watch(orderListProvider);
    final codes = ref.watch(codeProvider);
    _ensureInitialSearch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderListSearchToolbar(
          startDateController: _startDateController,
          endDateController: _endDateController,
          onPickStartDate: () => _pickDate(
            initialDate: _startDate,
            onSelected: (date) {
              setState(() => _startDate = date);
              _startDateController.text = date.toApiDate();
            },
          ),
          onPickEndDate: () => _pickDate(
            initialDate: _endDate,
            onSelected: (date) {
              setState(() => _endDate = date);
              _endDateController.text = date.toApiDate();
            },
          ),
          customerLookupItems: _customerLookupItems,
          selectedCustCode: _selectedCustCode,
          customersReady: _customersReady,
          onCustomerChanged: (custCode) {
            setState(() => _selectedCustCode = custCode);
            _search();
          },
          onRegister: _openRegisterDialog,
          onDelete: () {
            final orders = orderListAsync.asData?.value.items;
            if (orders == null || _selectedRowIndex! >= orders.length) {
              return;
            }
            _deleteSelected(orders[_selectedRowIndex!]);
          },
          onSearch: _search,
          isLoading: orderListAsync.isLoading,
          isDeleting: _isDeleting,
          canDelete: _selectedRowIndex != null,
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: OrderListMasterPanel(
            customersReady: _customersReady,
            orderListAsync: orderListAsync,
            codes: codes,
            customerName: _customerName,
            selectedRowIndex: _selectedRowIndex,
            onOrderSelected: _selectOrder,
            onOrderEdit: _editOrder,
          ),
        ),
        if (_selectedCustCode != null) ...[
          const SizedBox(height: 8),
          OrderListSummaryFooter(result: orderListAsync.asData?.value),
        ],
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: TkGridPanel(
            child: _selectedOrderNo == null
                ? const Center(child: Text('접수를 선택하면 상세가 표시됩니다.'))
                : OrderListDetailPanel(
                    orderNo: _selectedOrderNo!,
                    codes: codes,
                    productName: _productName,
                  ),
          ),
        ),
      ],
    );
  }
}
