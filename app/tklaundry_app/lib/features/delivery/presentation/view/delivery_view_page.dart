import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/tk_format.dart';
import '../../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../../shared/widgets/tk_grid_panel.dart';
import '../../../code/presentation/code_provider.dart';
import '../../../customer/data/customer_api.dart';
import '../../../customer/domain/customer.dart';
import '../../../product/data/product_api.dart';
import '../../domain/delivery.dart';
import '../delivery_provider.dart';
import '../../../../shared/widgets/list/tk_list_summary_footer.dart';
import 'delivery_view_detail_panel.dart';
import '../delivery_view_provider.dart';
import 'delivery_view_master_panel.dart';
import 'delivery_view_toolbar.dart';

class DeliveryViewPage extends ConsumerStatefulWidget {
  const DeliveryViewPage({super.key});

  @override
  ConsumerState<DeliveryViewPage> createState() => _DeliveryViewPageState();
}

class _DeliveryViewPageState extends ConsumerState<DeliveryViewPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedCustCode;
  int? _selectedRowIndex;
  String? _selectedDeliveryNo;
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
      _selectedDeliveryNo = null;
    });
    await ref.read(deliveryViewListProvider.notifier).search(
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

  void _onStartDateSelected(DateTime date) {
    setState(() => _startDate = date);
    _startDateController.text = date.toApiDate();
    _search();
  }

  void _onEndDateSelected(DateTime date) {
    setState(() => _endDate = date);
    _endDateController.text = date.toApiDate();
    _search();
  }

  String _customerName(String custCode) {
    return _customerByCode[custCode]?.custName ?? custCode;
  }

  String _productName(String productCode) {
    return _productNameByCode[productCode] ?? productCode;
  }

  void _selectDelivery(Delivery delivery, int index) {
    setState(() {
      _selectedRowIndex = index;
      _selectedDeliveryNo = delivery.deliveryNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryViewListAsync = ref.watch(deliveryViewListProvider);
    final codes = ref.watch(codeProvider);
    _ensureInitialSearch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DeliveryViewSearchToolbar(
          startDateController: _startDateController,
          endDateController: _endDateController,
          startDate: _startDate,
          endDate: _endDate,
          onStartDateSelected: _onStartDateSelected,
          onEndDateSelected: _onEndDateSelected,
          customerLookupItems: _customerLookupItems,
          selectedCustCode: _selectedCustCode,
          customersReady: _customersReady,
          onCustomerChanged: (custCode) {
            setState(() => _selectedCustCode = custCode);
            _search();
          },
          onSearch: _search,
          isLoading: deliveryViewListAsync.isLoading,
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: DeliveryViewMasterPanel(
            customersReady: _customersReady,
            deliveryViewListAsync: deliveryViewListAsync,
            codes: codes,
            customerName: _customerName,
            selectedRowIndex: _selectedRowIndex,
            onDeliverySelected: _selectDelivery,
          ),
        ),
        if (_selectedCustCode != null) ...[
          const SizedBox(height: 8),
          TkListSummaryFooter(
            count: deliveryViewListAsync.asData?.value.count,
            totalAmount: deliveryViewListAsync.asData?.value.totalAmount,
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: TkGridPanel(
            child: _selectedDeliveryNo == null
                ? const Center(child: Text('출고 건을 선택하면 상세가 표시됩니다.'))
                : DeliveryViewDetailPanel(
                    deliveryNo: _selectedDeliveryNo!,
                    codes: codes,
                    productName: _productName,
                  ),
          ),
        ),
      ],
    );
  }
}
