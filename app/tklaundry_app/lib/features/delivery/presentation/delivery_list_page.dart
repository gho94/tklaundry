import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/code_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/lookup/tk_lookup_field.dart';
import '../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../../customer/data/customer_api.dart';
import '../../customer/domain/customer.dart';
import '../../order/domain/order.dart';
import '../../product/data/product_api.dart';
import '../data/delivery_api.dart';
import 'delivery_detail_panel.dart';
import 'delivery_provider.dart';
import 'delivery_summary_footer.dart';

class DeliveryListPage extends ConsumerStatefulWidget {
  const DeliveryListPage({super.key});

  @override
  ConsumerState<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends ConsumerState<DeliveryListPage> {
  static const _masterColumns = [
    TkGridColumn(label: '접수 일자'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
    TkGridColumn(label: '출고 일자'),
  ];

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

  String _paymentStatusLabel(List<Code> codes, String statusCode) {
    final label = codes.displayName(statusCode);
    if (label == '일반') return '';
    return label;
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

  bool _isFirstStatus(List<TkComboItem<String>> statusItems) {
    if (_statusCode == null || statusItems.isEmpty) return true;
    return _statusCode == statusItems.first.value;
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

    final statusItems = _statusItems(codes);
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

      final bankingYn =
          _isFirstStatus(statusItems) ? 'N' : (_bankingYn ? 'Y' : 'N');

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
    final showBanking = _selectedOrderNo != null && !_isFirstStatus(statusItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '출고',
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
              isLoading: deliveryListAsync.isLoading,
              onPressed:
                  !_customersReady || deliveryListAsync.isLoading ? null : _search,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: TkGridPanel(
            child: !_customersReady
                ? const Center(child: CircularProgressIndicator())
                : deliveryListAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => TkAsyncErrorBody(
                      error: error,
                      fallbackMessage: '출고 대상 접수 목록을 불러오지 못했습니다.',
                    ),
                    data: (result) => TkGridTable(
                      columns: _masterColumns,
                      itemCount: result.items.length,
                      itemBuilder: (index) =>
                          _buildMasterRow(codes, result.items[index]),
                      selectedRowIndex: _selectedRowIndex,
                      onRowTap: (index) {
                        _selectOrder(result.items[index], index);
                      },
                    ),
                  ),
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
          Row(
            children: [
              SizedBox(
                width: 120,
                child: TkComboBox<String>(
                  label: '결제 상태',
                  items: statusItems,
                  value: _statusCode,
                  showAllOption: false,
                  compact: true,
                  enabled: statusItems.isNotEmpty && !_isSubmitting,
                  onChanged: statusItems.isEmpty || _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _statusCode = value;
                            if (_isFirstStatus(statusItems)) {
                              _bankingYn = false;
                            }
                          });
                        },
                ),
              ),
              if (showBanking) ...[
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _bankingYn,
                      visualDensity: VisualDensity.compact,
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() => _bankingYn = value ?? false);
                            },
                    ),
                    const Text('뱅킹'),
                  ],
                ),
              ],
              const Spacer(),
              TkPrimaryButton(
                label: '출고',
                icon: Icons.local_shipping_outlined,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ||
                        _selectedOrderSeqs.isEmpty ||
                        statusItems.isEmpty
                    ? null
                    : () => _registerDelivery(codes),
              ),
            ],
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

  List<Widget> _buildMasterRow(List<Code> codes, Order order) {
    return [
      Text(order.orderDate.toDisplayDateTime()),
      Text(_customerName(order.custCode)),
      Text(order.qty.formatted),
      Text(order.discount.formatted),
      Text(order.cost.formatted),
      Text(_paymentStatusLabel(codes, order.status)),
      Text(order.deliveryDate.toDisplayDateTime(hideUnassigned: true)),
    ];
  }
}
