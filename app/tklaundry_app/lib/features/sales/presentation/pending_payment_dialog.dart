import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/lookup/tk_lookup_field.dart';
import '../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../../customer/domain/customer.dart';
import '../data/sales_api.dart';
import '../domain/pending_payment.dart';

class PendingPaymentDialog extends ConsumerStatefulWidget {
  const PendingPaymentDialog({
    super.key,
    required this.customers,
  });

  final List<Customer> customers;

  static Future<bool?> show(
    BuildContext context, {
    required List<Customer> customers,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => PendingPaymentDialog(customers: customers),
    );
  }

  @override
  ConsumerState<PendingPaymentDialog> createState() =>
      _PendingPaymentDialogState();
}

class _PendingPaymentDialogState extends ConsumerState<PendingPaymentDialog> {
  static const _columns = [
    TkGridColumn(label: '출고 일자'),
    TkGridColumn(label: '고객'),
    TkGridColumn(label: '수량', numeric: true),
    TkGridColumn(label: '할인', numeric: true),
    TkGridColumn(label: '금액', numeric: true),
    TkGridColumn(label: '결제 상태'),
    TkGridColumn(label: '뱅킹', width: 80, align: TextAlign.center),
  ];

  final _salesApi = SalesApi();

  String? _selectedCustCode;
  List<PendingPayment> _items = [];
  int? _selectedRowIndex;
  PendingPayment? _selectedItem;
  bool _bankingYn = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _paid = false;
  bool _initialized = false;
  Object? _loadError;

  Map<String, Customer> get _customerByCode {
    return {for (final customer in widget.customers) customer.custCode: customer};
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  String _customerName(String custCode) {
    return _customerByCode[custCode]?.custName ?? custCode;
  }

  List<TkLookupItem<String>> get _customerLookupItems {
    return [
      for (final customer in widget.customers)
        TkLookupItem(
          value: customer.custCode,
          label: customer.custName,
          subtitle: customer.custPhone,
        ),
    ];
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _selectedRowIndex = null;
      _selectedItem = null;
      _initialized = true;
    });

    try {
      final custCode = _selectedCustCode;
      final items = await _salesApi.listPendingPayments(
        custCode: custCode != null && custCode.isNotEmpty ? custCode : null,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  void _selectRow(PendingPayment item, int index) {
    setState(() {
      _selectedRowIndex = index;
      _selectedItem = item;
      _bankingYn = item.bankingYn == 'Y';
    });
  }

  String _paymentStatusLabel(List<Code> codes, String statusCode) {
    final label = codes.displayName(statusCode);
    if (label == '일반') return '';
    return label;
  }

  Future<void> _submit() async {
    final item = _selectedItem;
    if (item == null) {
      context.showTkMessage('미수금 건을 선택해 주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _salesApi.registerPayment(
        salesNo: item.salesNo,
        bankingYn: _bankingYn ? 'Y' : 'N',
      );
      if (!mounted) return;
      context.showTkMessage('미수금 결제가 완료되었습니다.');
      setState(() => _paid = true);
      await _load();
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
    final codes = ref.watch(codeProvider);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: const Text('미수금 결제'),
      content: SizedBox(
        width: 1100,
        height: 580,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 260,
                  child: TkLookupField<String>(
                    label: '고객',
                    hint: '고객명 · 전화번호 검색',
                    primaryColumnLabel: '고객',
                    secondaryColumnLabel: '전화번호',
                    panelMinWidth: 360,
                    items: _customerLookupItems,
                    value: _selectedCustCode,
                    showAllOption: true,
                    onChanged: (custCode) {
                      setState(() => _selectedCustCode = custCode);
                      _load();
                    },
                  ),
                ),
                const Spacer(),
                TkPrimaryButton(
                  label: '조회',
                  variant: TkButtonVariant.outline,
                  icon: Icons.search,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _load,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TkGridPanel(
                child: !_initialized || _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                        ? TkAsyncErrorBody(
                            error: _loadError!,
                            fallbackMessage: '미수금 목록을 불러오지 못했습니다.',
                          )
                        : _items.isEmpty
                            ? const Center(child: Text('미수금 내역이 없습니다.'))
                            : TkGridTable(
                                columns: _columns,
                                itemCount: _items.length,
                                itemBuilder: (index) =>
                                    _buildRow(codes, _items[index]),
                                selectedRowIndex: _selectedRowIndex,
                                onRowTap: (index) {
                                  _selectRow(_items[index], index);
                                },
                              ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _bankingYn,
                  onChanged: _selectedItem == null || _isSubmitting
                      ? null
                      : (value) {
                          setState(() => _bankingYn = value ?? false);
                        },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const Text('뱅킹'),
                const Spacer(),
                TkPrimaryButton(
                  label: '결제',
                  icon: Icons.payments_outlined,
                  isLoading: _isSubmitting,
                  onPressed: _selectedItem == null || _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(_paid),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  List<Widget> _buildRow(List<Code> codes, PendingPayment item) {
    return [
      Text(item.deliveryDate.toDisplayDateTime()),
      Text(_customerName(item.custCode)),
      Text(item.qty.formatted),
      Text(item.discount.formatted),
      Text(item.cost.formatted),
      Text(_paymentStatusLabel(codes, item.status)),
      Checkbox(
        value: item.bankingYn == 'Y',
        onChanged: null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    ];
  }
}
