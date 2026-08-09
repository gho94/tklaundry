import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/code_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/utils/tk_feedback.dart';
import '../../../../shared/utils/tk_format.dart';
import '../../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../../shared/widgets/tk_combo_box.dart';
import '../../../../shared/widgets/tk_grid_panel.dart';
import '../../../code/domain/code.dart';
import '../../../code/presentation/code_list_extensions.dart';
import '../../../code/presentation/code_provider.dart';
import '../../../customer/data/customer_api.dart';
import '../../../customer/domain/customer.dart';
import '../../../order/domain/order.dart';
import '../../../product/data/product_api.dart';
import '../../data/delivery_api.dart';
import 'delivery_detail_panel.dart';
import '../delivery_provider.dart';
import '../delivery_summary_footer.dart';
import 'delivery_list_action_bar.dart';
import 'delivery_list_master_panel.dart';
import 'delivery_list_toolbar.dart';

class DeliveryListPage extends ConsumerStatefulWidget {
  const DeliveryListPage({super.key});

  @override
  ConsumerState<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends ConsumerState<DeliveryListPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedCustCode;
  int? _selectedRowIndex;
  String? _selectedOrderNo;
  Order? _selectedOrder;
  Set<int> _selectedOrderSeqs = {};
  String? _statusCode;
  bool _bankingYn = false;
  bool _defaultStatusApplied = false;
  bool _isSubmitting = false;
  bool _initialized = false;

  List<Customer> _customers = [];
  bool _customersReady = false;

  Map<String, String> _productNameByCode = {};

  final _customerApi = CustomerApi();
  final _productApi = ProductApi();
  final _deliveryApi = DeliveryApi();
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    _endDate = todayDate;
    _startDate = DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
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
      _selectedOrder = null;
      _selectedOrderSeqs = {};
      _statusCode = null;
      _bankingYn = false;
      _defaultStatusApplied = false;
    });
    await ref.read(deliveryListProvider.notifier).search(
          DeliverySearchParams(
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

  List<TkComboItem<String>> _statusItems(List<Code> codes) {
    return codes
        .comboItems(CodeConstants.paymentStatus)
        .where((item) => item.label != '선불')
        .toList();
  }

  void _ensureDefaultStatus(List<TkComboItem<String>> statusItems) {
    if (_defaultStatusApplied || statusItems.isEmpty) return;
    _defaultStatusApplied = true;
    final first = statusItems.first.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _statusCode != null) return;
      setState(() => _statusCode = first);
    });
  }

  void _selectOrder(Order order, int index) {
    setState(() {
      _selectedRowIndex = index;
      _selectedOrderNo = order.orderNo;
      _selectedOrder = order;
      _selectedOrderSeqs = {};
      _statusCode = null;
      _bankingYn = order.bankingYn == 'Y';
      _defaultStatusApplied = false;
    });
  }

  Future<void> _registerDelivery(List<Code> codes) async {
    final order = _selectedOrder;
    final orderNo = _selectedOrderNo;
    if (order == null || orderNo == null) return;

    if (_selectedOrderSeqs.isEmpty) {
      context.showTkMessage('출고할 내역이 없습니다.');
      return;
    }

    final statusCode = _statusCode;
    if (statusCode == null || statusCode.isEmpty) {
      context.showTkMessage('결제 상태를 선택해 주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final details = await ref.read(deliveryDetailListProvider(orderNo).future);
      final selectedDetails = details
          .where((detail) => _selectedOrderSeqs.contains(detail.orderSeq))
          .map(DeliveryDetailInput.fromOrderDetail)
          .toList();

      if (selectedDetails.isEmpty) {
        if (!mounted) return;
        context.showTkMessage('출고할 내역이 없습니다.');
        return;
      }

      final bankingYn = _bankingYn ? 'Y' : 'N';

      await _deliveryApi.registerDelivery(
        orderNo: order.orderNo,
        orderDate: order.orderDate,
        custCode: order.custCode,
        orderStatus: order.status,
        status: statusCode,
        bankingYn: bankingYn,
        details: selectedDetails,
      );

      if (!mounted) return;
      context.showTkMessage('저장이 완료되었습니다.');
      setState(() {
        _selectedRowIndex = null;
        _selectedOrderNo = null;
        _selectedOrder = null;
        _selectedOrderSeqs = {};
        _statusCode = null;
        _bankingYn = false;
        _defaultStatusApplied = false;
      });
      ref.invalidate(deliveryDetailListProvider);
      await _search();
    } on ApiException catch (error) {
      if (!mounted) return;
      context.showTkApiError(error);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryListAsync = ref.watch(deliveryListProvider);
    final codes = ref.watch(codeProvider);
    final statusItems = _statusItems(codes);
    _ensureInitialSearch();
    if (_selectedOrderNo != null) {
      _ensureDefaultStatus(statusItems);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DeliveryListSearchToolbar(
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
          onSearch: _search,
          isLoading: deliveryListAsync.isLoading,
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: DeliveryListMasterPanel(
            customersReady: _customersReady,
            deliveryListAsync: deliveryListAsync,
            codes: codes,
            customerName: _customerName,
            selectedRowIndex: _selectedRowIndex,
            onOrderSelected: _selectOrder,
          ),
        ),
        if (_selectedCustCode != null) ...[
          const SizedBox(height: 8),
          DeliverySummaryFooter(
            count: deliveryListAsync.asData?.value.count,
            totalAmount: deliveryListAsync.asData?.value.totalAmount,
          ),
        ],
        if (_selectedOrderNo != null) ...[
          const SizedBox(height: 12),
          DeliveryListActionBar(
            statusItems: statusItems,
            statusCode: _statusCode,
            bankingYn: _bankingYn,
            isSubmitting: _isSubmitting,
            hasSelectedDetails: _selectedOrderSeqs.isNotEmpty,
            onStatusChanged: (value) {
              setState(() => _statusCode = value);
            },
            onBankingChanged: (value) {
              setState(() => _bankingYn = value);
            },
            onRegister: () => _registerDelivery(codes),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: TkGridPanel(
            child: _selectedOrderNo == null
                ? const Center(child: Text('접수를 선택하면 미출고 상세가 표시됩니다.'))
                : DeliveryDetailPanel(
                    orderNo: _selectedOrderNo!,
                    codes: codes,
                    productName: _productName,
                    onSelectionChanged: (orderSeqs) {
                      setState(() => _selectedOrderSeqs = Set.from(orderSeqs));
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
