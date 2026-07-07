import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/code_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/utils/tk_feedback.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_confirm_dialog.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_provider.dart';
import '../data/customer_api.dart';
import '../domain/customer.dart';
import 'customer_provider.dart';
import 'customer_register_dialog.dart';

class CustomerListPage extends ConsumerStatefulWidget {
  const CustomerListPage({super.key});

  @override
  ConsumerState<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends ConsumerState<CustomerListPage> {
  static const _columns = [
    TkGridColumn(label: '이름'),
    TkGridColumn(label: '아파트'),
    TkGridColumn(label: '동'),
    TkGridColumn(label: '층'),
    TkGridColumn(label: '호'),
    TkGridColumn(label: '전화번호'),
  ];

  String? _selectedAptCode;
  int? _selectedRowIndex;
  bool _initialized = false;
  bool _isDeleting = false;
  final _customerApi = CustomerApi();

  List<TkComboItem<String>> _aptComboItems(List<Code> codes) {
    final apartments = codes
        .where((code) => code.pCodeId.trim() == CodeConstants.customerApt)
        .toList()
      ..sort((a, b) => a.codeId.compareTo(b.codeId));

    return [
      for (final apt in apartments)
        TkComboItem(value: apt.codeId.trim(), label: apt.codeName),
      const TkComboItem(value: '', label: '기타'),
    ];
  }

  Map<String, String> _codeNameMap(List<Code> codes) {
    return {for (final code in codes) code.codeId.trim(): code.codeName};
  }

  String _lookupCodeName(Map<String, String> codeNames, String codeId) {
    if (codeId.isEmpty) return '';
    return codeNames[codeId.trim()] ?? codeId;
  }

  Future<void> _search(String? aptCode) async {
    setState(() {
      _selectedAptCode = aptCode;
      _selectedRowIndex = null;
    });
    await ref.read(customerListProvider.notifier).search(aptCode);
  }

  void _ensureInitialSearch(List<TkComboItem<String>> aptItems) {
    if (_initialized || aptItems.isEmpty) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search(null);
    });
  }

  Future<void> _openRegisterDialog() async {
    final created = await CustomerRegisterDialog.showCreate(context);
    if (!mounted || created != true) return;
    await _search(_selectedAptCode);
    if (!mounted) return;
    context.showTkMessage('고객이 등록되었습니다.');
  }

  Future<void> _openEditDialog(Customer customer) async {
    final updated = await CustomerRegisterDialog.showEdit(context, customer);
    if (!mounted || updated != true) return;
    await _search(_selectedAptCode);
    if (!mounted) return;
    context.showTkMessage('고객 정보가 수정되었습니다.');
  }

  Future<void> _deleteSelected(Customer customer) async {
    final confirmed = await showTkConfirmDialog(
      context,
      title: '고객 삭제',
      message: '\'${customer.custName}\' 고객을 삭제하시겠습니까?',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await _customerApi.deleteCustomer(customer.custCode);
      if (!mounted) return;

      await _search(_selectedAptCode);
      if (!mounted) return;

      context.showTkMessage('고객이 삭제되었습니다.');
    } on ApiException catch (error) {
      if (!mounted) return;
      context.showTkApiError(error);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final codes = ref.watch(codeProvider);
    final codeNames = _codeNameMap(codes);
    final aptItems = _aptComboItems(codes);
    _ensureInitialSearch(aptItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '고객',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 180,
              child: TkComboBox<String>(
                label: '아파트',
                items: aptItems,
                value: _selectedAptCode,
                enabled: aptItems.isNotEmpty,
                onChanged: aptItems.isEmpty ? null : _search,
              ),
            ),
            const Spacer(),
            TkPrimaryButton(
              label: '등록',
              variant: TkButtonVariant.outline,
              icon: Icons.person_add_outlined,
              onPressed: _openRegisterDialog,
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
                      final customers = customersAsync.asData?.value;
                      if (customers == null ||
                          _selectedRowIndex! >= customers.length) {
                        return;
                      }
                      _deleteSelected(customers[_selectedRowIndex!]);
                    },
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: customersAsync.isLoading,
              onPressed: customersAsync.isLoading || aptItems.isEmpty
                  ? null
                  : () => _search(_selectedAptCode),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TkGridPanel(
            child: aptItems.isEmpty
                ? const Center(child: Text('아파트 코드가 없습니다.'))
                : customersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => TkAsyncErrorBody(
                      error: error,
                      fallbackMessage: '고객 목록을 불러오지 못했습니다.',
                    ),
                    data: (customers) {
                      if (_selectedRowIndex != null &&
                          _selectedRowIndex! >= customers.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _selectedRowIndex = null);
                          }
                        });
                      }

                      return TkGridTable(
                        columns: _columns,
                        itemCount: customers.length,
                        itemBuilder: (index) =>
                            _buildRow(codeNames, customers[index]),
                        selectedRowIndex: _selectedRowIndex,
                        onRowTap: (index) =>
                            setState(() => _selectedRowIndex = index),
                        onRowDoubleTap: (index) =>
                            _openEditDialog(customers[index]),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRow(Map<String, String> codeNames, Customer customer) {
    return [
      Text(customer.custName),
      Text(_lookupCodeName(codeNames, customer.aptCode)),
      Text(_lookupCodeName(codeNames, customer.buildingCode)),
      Text(_lookupCodeName(codeNames, customer.floorCode)),
      Text(_lookupCodeName(codeNames, customer.roomCode)),
      Text(customer.custPhone),
    ];
  }
}
