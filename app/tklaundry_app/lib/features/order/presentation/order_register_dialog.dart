import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/code_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_confirm_dialog.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../../customer/domain/customer.dart';
import '../../product/data/product_api.dart';
import '../../product/domain/product.dart';
import '../data/order_api.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';

/// 다이얼로그 결과: 저장·삭제 후 목록 새로고침 구분.
abstract final class OrderFormResult {
  static const saved = 'saved';
  static const deleted = 'deleted';
}

/// 레거시 `FrmOrder` 레이아웃:
/// 좌측 제품 정보 · 우측 접수 내역(일자/결제/저장 + 상세 그리드 + 합계).
class OrderRegisterDialog extends ConsumerStatefulWidget {
  const OrderRegisterDialog({
    super.key,
    required this.customer,
    this.order,
    this.initialDetails = const [],
    this.productNames = const {},
  });

  final Customer customer;
  final Order? order;
  final List<OrderDetail> initialDetails;
  final Map<String, String> productNames;

  bool get isEdit => order != null;

  static Future<bool?> showCreate(
    BuildContext context, {
    required Customer customer,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => OrderRegisterDialog(customer: customer),
    );
  }

  static Future<Object?> showEdit(
    BuildContext context, {
    required Customer customer,
    required Order order,
    required List<OrderDetail> details,
    required Map<String, String> productNames,
  }) {
    return showDialog<Object?>(
      context: context,
      builder: (_) => OrderRegisterDialog(
        customer: customer,
        order: order,
        initialDetails: details,
        productNames: productNames,
      ),
    );
  }

  @override
  ConsumerState<OrderRegisterDialog> createState() =>
      _OrderRegisterDialogState();
}

class _OrderRegisterDialogState extends ConsumerState<OrderRegisterDialog> {
  static const _productColumns = [
    TkGridColumn(label: '제품명'),
    TkGridColumn(label: '단가', flexRatio: 0.32, numeric: true),
  ];

  static const _detailColumns = [
    TkGridColumn(label: '순번', width: 48, numeric: true),
    TkGridColumn(label: '제품'),
    TkGridColumn(label: '처리방법', flexRatio: 0.12),
    TkGridColumn(label: '단가', width: 88, numeric: true),
    TkGridColumn(label: '수량', width: 64, numeric: true),
    TkGridColumn(label: '할인', width: 72, numeric: true),
    TkGridColumn(label: '금액', width: 88, numeric: true),
    TkGridColumn(label: '비고', flexRatio: 0.16),
  ];

  final _orderApi = OrderApi();
  final _productApi = ProductApi();

  late DateTime _orderDate;
  late final TextEditingController _orderDateController;

  String? _statusCode;
  bool _bankingYn = false;

  String? _processCode;
  String? _groupCode;
  bool _processDefaultsApplied = false;

  List<Product> _products = [];
  bool _productsLoading = false;
  int? _selectedProductIndex;

  final List<_DetailLine> _lines = [];

  bool _isSubmitting = false;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _traceId;
  bool _defaultStatusApplied = false;

  bool get _isEdit => widget.isEdit;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    if (order == null) {
      final now = DateTime.now();
      _orderDate = now;
      _orderDateController =
          TextEditingController(text: now.toDisplayDateTime());
      return;
    }

    final parsed = DateTime.tryParse(order.orderDate) ?? DateTime.now();
    _orderDate = parsed;
    _orderDateController =
        TextEditingController(text: parsed.toDisplayDateTime());
    _statusCode = order.status.isEmpty ? null : order.status;
    _bankingYn = order.bankingYn == 'Y';
    _defaultStatusApplied = true;

    for (final detail in widget.initialDetails) {
      final line = _DetailLine.fromOrderDetail(
        detail,
        productName: widget.productNames[detail.productCode] ?? detail.productCode,
      );
      line.addListeners(_onLineChanged);
      _lines.add(line);
    }
  }

  @override
  void dispose() {
    _orderDateController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  List<TkComboItem<String>> _statusItems(List<Code> codes) {
    return codes
        .comboItems(CodeConstants.paymentStatus)
        .where((item) => item.label != '외상')
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

  void _ensureProcessDefaults(
    List<TkComboItem<String>> processItems,
    List<Code> codes,
  ) {
    if (_processDefaultsApplied || processItems.isEmpty) return;
    final processCode = processItems.first.value;
    final groupItems = codes.comboItems(processCode);
    if (groupItems.isEmpty) return;

    _processDefaultsApplied = true;
    final groupCode = groupItems.first.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _selectProcessGroup(processCode: processCode, groupCode: groupCode);
    });
  }

  bool _isFirstStatus(List<TkComboItem<String>> statusItems) {
    if (_statusCode == null || statusItems.isEmpty) return true;
    return _statusCode == statusItems.first.value;
  }

  Future<void> _selectProcessGroup({
    required String processCode,
    required String groupCode,
  }) async {
    setState(() {
      _processCode = processCode;
      _groupCode = groupCode;
      _productsLoading = true;
      _selectedProductIndex = null;
      _errorMessage = null;
    });

    try {
      final products = await _productApi.listProducts(
        processCode: processCode,
        groupCode: groupCode,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _productsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _productsLoading = false;
        _errorMessage = '제품 목록을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _onProcessChanged(
    String? processCode,
    List<Code> codes,
  ) async {
    if (processCode == null) return;
    final groupItems = codes.comboItems(processCode);
    if (groupItems.isEmpty) {
      setState(() {
        _processCode = processCode;
        _groupCode = null;
        _products = [];
        _selectedProductIndex = null;
      });
      return;
    }
    await _selectProcessGroup(
      processCode: processCode,
      groupCode: groupItems.first.value,
    );
  }

  Future<void> _onGroupChanged(String? groupCode) async {
    final processCode = _processCode;
    if (groupCode == null || processCode == null) return;
    await _selectProcessGroup(
      processCode: processCode,
      groupCode: groupCode,
    );
  }

  void _addOrIncrementProduct(Product product, int productIndex) {
    if (_isSubmitting) return;

    setState(() => _selectedProductIndex = productIndex);

    final index = _lines.indexWhere(
      (line) => line.productCode == product.productCode,
    );

    if (index >= 0) {
      final existing = _lines[index];
      setState(() {
        existing.qtyController.text = (existing.qty + 1).toString();
        _errorMessage = null;
      });
      return;
    }

    final line = _DetailLine.fromProduct(product);
    line.addListeners(_onLineChanged);
    setState(() {
      _lines.add(line);
      _errorMessage = null;
    });
  }

  Future<void> _decrementProduct(Product product) async {
    if (_isSubmitting) return;

    final index = _lines.indexWhere(
      (line) => line.productCode == product.productCode,
    );
    if (index < 0) return;

    final line = _lines[index];
    final nextQty = line.qty - 1;
    if (nextQty > 0) {
      setState(() {
        line.qtyController.text = nextQty.toString();
        _errorMessage = null;
      });
      return;
    }

    final confirmed = await showTkConfirmDialog(
      context,
      title: '삭제',
      message: '수량이 없습니다. 자료를 삭제 하시겠습니까?',
    );
    if (!confirmed || !mounted) return;
    _removeLineAt(index);
  }

  void _removeLineAt(int index) {
    if (index < 0 || index >= _lines.length) return;
    final line = _lines.removeAt(index);
    line.dispose();
    setState(() => _errorMessage = null);
  }

  Future<void> _confirmRemoveLine(int index) async {
    final confirmed = await showTkConfirmDialog(
      context,
      title: '삭제',
      message: '자료를 삭제하시겠습니까?',
    );
    if (!confirmed || !mounted) return;
    _removeLineAt(index);
  }

  void _onLineChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickOrderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    final now = DateTime.now();
    setState(() {
      _orderDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        now.hour,
        now.minute,
        now.second,
      );
      _orderDateController.text = _orderDate.toDisplayDateTime();
    });
  }

  int get _totalQty => _lines.fold(0, (sum, line) => sum + line.qty);

  int get _totalCost => _lines.fold(0, (sum, line) => sum + line.cost);

  Future<void> _submit(List<TkComboItem<String>> statusItems) async {
    final statusCode = _statusCode;
    if (statusCode == null || statusCode.isEmpty) {
      setState(() => _errorMessage = '결제 상태를 선택해 주세요.');
      return;
    }

    if (_lines.isEmpty) {
      setState(() => _errorMessage = '접수할 항목이 없습니다.');
      return;
    }

    final details = <OrderDetailInput>[
      for (final line in _lines)
        OrderDetailInput(
          productCode: line.productCode,
          processCode: line.processCode,
          price: line.price,
          qty: line.qty,
          discount: line.discount,
          remark: line.remark,
        ),
    ];

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _traceId = null;
    });

    final bankingYn =
        _isFirstStatus(statusItems) ? 'N' : (_bankingYn ? 'Y' : 'N');

    try {
      if (_isEdit) {
        await _orderApi.updateOrder(
          orderNo: widget.order!.orderNo,
          custCode: widget.customer.custCode,
          orderDate: _orderDate,
          status: statusCode,
          bankingYn: bankingYn,
          details: details,
        );
      } else {
        await _orderApi.registerOrder(
          custCode: widget.customer.custCode,
          orderDate: _orderDate,
          status: statusCode,
          bankingYn: bankingYn,
          details: details,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(_isEdit ? OrderFormResult.saved : true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _traceId = error.traceId;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteOrder() async {
    final order = widget.order;
    if (order == null || _isDeleting || _isSubmitting) return;

    final confirmed = await showTkConfirmDialog(
      context,
      title: '접수 삭제',
      message: '데이터를 삭제하시겠습니까?',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
      _traceId = null;
    });

    try {
      await _orderApi.deleteOrder(order.orderNo);
      if (!mounted) return;
      Navigator.of(context).pop(OrderFormResult.deleted);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _traceId = error.traceId;
      });
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final codes = ref.watch(codeProvider);
    final statusItems = _statusItems(codes);
    final processItems = codes.comboItems(CodeConstants.productProcess);
    final effectiveProcessCode = _processCode ??
        (processItems.isNotEmpty ? processItems.first.value : null);
    final groupItems = codes.comboItems(effectiveProcessCode ?? '');
    final effectiveGroupCode = _groupCode ??
        (groupItems.isNotEmpty ? groupItems.first.value : null);

    _ensureDefaultStatus(statusItems);
    _ensureProcessDefaults(processItems, codes);
    final showBanking = !_isFirstStatus(statusItems);

    final customer = widget.customer;
    final titleCustomer = customer.custPhone.isEmpty
        ? customer.custName
        : '${customer.custName} (${customer.custPhone})';

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Row(
        children: [
          Text(
            '접수',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titleCustomer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 1100,
        height: 580,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 280,
                    child: _buildProductPanel(
                      codes: codes,
                      processItems: processItems,
                      groupItems: groupItems,
                      effectiveProcessCode: effectiveProcessCode,
                      effectiveGroupCode: effectiveGroupCode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailPanel(
                      codes: codes,
                      statusItems: statusItems,
                      showBanking: showBanking,
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                      height: 1.4,
                    ),
              ),
            ],
            if (_traceId != null) ...[
              const SizedBox(height: 4),
              Text(
                'traceId: $_traceId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting || _isDeleting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildProductPanel({
    required List<Code> codes,
    required List<TkComboItem<String>> processItems,
    required List<TkComboItem<String>> groupItems,
    required String? effectiveProcessCode,
    required String? effectiveGroupCode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('제품 정보'),
        const SizedBox(height: 8),
        Expanded(
          child: TkGridPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TkComboBox<String>(
                          label: '처리',
                          items: processItems,
                          value: effectiveProcessCode,
                          showAllOption: false,
                          compact: true,
                          enabled: processItems.isNotEmpty && !_isSubmitting,
                          onChanged: processItems.isEmpty
                              ? null
                              : (value) => _onProcessChanged(value, codes),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TkComboBox<String>(
                          label: '그룹',
                          items: groupItems,
                          value: effectiveGroupCode,
                          showAllOption: false,
                          compact: true,
                          enabled: groupItems.isNotEmpty && !_isSubmitting,
                          onChanged:
                              groupItems.isEmpty ? null : _onGroupChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _productsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : processItems.isEmpty
                          ? const Center(child: Text('처리 코드가 없습니다.'))
                          : groupItems.isEmpty
                              ? const Center(child: Text('그룹 코드가 없습니다.'))
                              : TkGridTable(
                                  columns: _productColumns,
                                  emptyMessage: '제품이 없습니다.',
                                  selectedRowIndex: _selectedProductIndex,
                                  itemCount: _products.length,
                                  itemBuilder: (index) {
                                    final product = _products[index];
                                    return [
                                      Text(product.productName),
                                      Text((product.price ?? 0).formatted),
                                    ];
                                  },
                                  onRowTap: _isSubmitting
                                      ? null
                                      : (index) => _addOrIncrementProduct(
                                            _products[index],
                                            index,
                                          ),
                                  onRowSecondaryTap: _isSubmitting
                                      ? null
                                      : (index) =>
                                          _decrementProduct(_products[index]),
                                ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPanel({
    required List<Code> codes,
    required List<TkComboItem<String>> statusItems,
    required bool showBanking,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('접수 내역'),
        const SizedBox(height: 8),
        Expanded(
          child: TkGridPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: GestureDetector(
                          onTap: _isSubmitting ? null : _pickOrderDate,
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _orderDateController,
                              readOnly: true,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: const InputDecoration(
                                labelText: '접수일자',
                                isDense: true,
                                suffixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                ),
                                suffixIconConstraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: TkComboBox<String>(
                          label: '결제 상태',
                          items: statusItems,
                          value: _statusCode,
                          showAllOption: false,
                          compact: true,
                          enabled: statusItems.isNotEmpty && !_isSubmitting,
                          onChanged: statusItems.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    _statusCode = value;
                                    if (_isFirstStatus(statusItems)) {
                                      _bankingYn = false;
                                    }
                                    _errorMessage = null;
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
                                      setState(
                                        () => _bankingYn = value ?? false,
                                      );
                                    },
                            ),
                            const Text('뱅킹'),
                          ],
                        ),
                      ],
                      const Spacer(),
                      if (_isEdit) ...[
                        TkPrimaryButton(
                          label: '삭제',
                          variant: TkButtonVariant.outline,
                          icon: Icons.delete_outline,
                          isLoading: _isDeleting,
                          onPressed: _isSubmitting || _isDeleting
                              ? null
                              : _deleteOrder,
                        ),
                        const SizedBox(width: 8),
                      ],
                      TkPrimaryButton(
                        label: '저장',
                        icon: Icons.save_outlined,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting || _isDeleting
                            ? null
                            : () => _submit(statusItems),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _lines.isEmpty
                      ? const Center(
                          child: Text('좌측 제품을 선택하면 접수 내역에 추가됩니다.'),
                        )
                      : TkGridTable(
                          columns: _detailColumns,
                          rowHeight: 40,
                          itemCount: _lines.length,
                          itemBuilder: (index) =>
                              _buildDetailCells(codes, _lines[index], index),
                        ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                    color: AppColors.neutral50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _SummaryBox(
                        label: '수량',
                        value: _totalQty.formatted,
                        width: 72,
                      ),
                      const SizedBox(width: 12),
                      _SummaryBox(
                        label: '금액',
                        value: _totalCost.formatted,
                        width: 110,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetailCells(
    List<Code> codes,
    _DetailLine line,
    int index,
  ) {
    return [
      Text('${index + 1}'),
      Text(line.productName, overflow: TextOverflow.ellipsis),
      Text(
        codes.displayName(line.processCode),
        overflow: TextOverflow.ellipsis,
      ),
      _GridNumberField(
        controller: line.priceController,
        readOnly: _isSubmitting,
      ),
      _GridNumberField(
        controller: line.qtyController,
        readOnly: _isSubmitting,
      ),
      _GridNumberField(
        controller: line.discountController,
        readOnly: _isSubmitting,
      ),
      Text(line.cost.formatted),
      Row(
        children: [
          Expanded(
            child: _GridTextField(
              controller: line.remarkController,
              readOnly: _isSubmitting,
            ),
          ),
          SizedBox(
            width: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: '행 삭제',
              onPressed:
                  _isSubmitting ? null : () => _confirmRemoveLine(index),
              icon: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    ];
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.width,
  });

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
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

class _DetailLine {
  _DetailLine.fromProduct(Product product)
      : productCode = product.productCode,
        processCode = product.processCode,
        productName = product.productName {
    priceController =
        TextEditingController(text: (product.price ?? 0).toString());
    qtyController = TextEditingController(text: '1');
    discountController = TextEditingController(text: '0');
    remarkController = TextEditingController();
  }

  _DetailLine.fromOrderDetail(
    OrderDetail detail, {
    required this.productName,
  })  : productCode = detail.productCode,
        processCode = detail.processCode {
    priceController = TextEditingController(text: detail.price.toString());
    qtyController = TextEditingController(text: detail.qty.toString());
    discountController =
        TextEditingController(text: detail.discount.toString());
    remarkController = TextEditingController(text: detail.remark ?? '');
  }

  final String productCode;
  final String processCode;
  final String productName;

  late final TextEditingController priceController;
  late final TextEditingController qtyController;
  late final TextEditingController discountController;
  late final TextEditingController remarkController;

  VoidCallback? _listener;

  void addListeners(VoidCallback onChanged) {
    _listener = onChanged;
    priceController.addListener(onChanged);
    qtyController.addListener(onChanged);
    discountController.addListener(onChanged);
  }

  int get price => _parseInt(priceController.text);
  int get qty => _parseInt(qtyController.text);
  int get discount => _parseInt(discountController.text);
  int get cost => price * qty - discount;

  String? get remark {
    final value = remarkController.text.trim();
    return value.isEmpty ? null : value;
  }

  void dispose() {
    if (_listener != null) {
      priceController.removeListener(_listener!);
      qtyController.removeListener(_listener!);
      discountController.removeListener(_listener!);
    }
    priceController.dispose();
    qtyController.dispose();
    discountController.dispose();
    remarkController.dispose();
  }

  static int _parseInt(String raw) {
    final cleaned = raw.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }
}
