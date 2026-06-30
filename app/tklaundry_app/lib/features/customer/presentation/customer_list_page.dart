import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_provider.dart';
import '../domain/customer.dart';
import 'customer_provider.dart';

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

  static const _customerManageCodeId = 'A10001';

  String? _selectedAptCode;
  int? _selectedRowIndex;
  bool _initialized = false;

  List<TkComboItem<String>> _aptComboItems(List<Code> codes) {
    final apartments = codes
        .where((code) => code.pCodeId.trim() == _customerManageCodeId)
        .toList()
      ..sort((a, b) => a.codeId.compareTo(b.codeId));

    return [
      for (final apt in apartments)
        TkComboItem(value: apt.codeId.trim(), label: apt.codeName),
      const TkComboItem(value: '', label: '기타'),
    ];
  }

  String _codeName(List<Code> codes, String codeId) {
    if (codeId.isEmpty) return '';
    for (final code in codes) {
      if (code.codeId.trim() == codeId) {
        return code.codeName;
      }
    }
    return codeId;
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

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final codesAsync = ref.watch(codeProvider);
    final codes = codesAsync.asData?.value ?? const <Code>[];
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('등록 API 연동 예정입니다.')),
                );
              },
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '삭제',
              variant: TkButtonVariant.outline,
              icon: Icons.delete_outline,
              onPressed: _selectedRowIndex == null
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('삭제 API 연동 예정입니다.')),
                      );
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: codesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorBody(error: error),
                data: (_) {
                  if (aptItems.isEmpty) {
                    return const Center(child: Text('아파트 코드가 없습니다.'));
                  }

                  return customersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _ErrorBody(error: error),
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
                        selectedRowIndex: _selectedRowIndex,
                        onRowTap: (index) =>
                            setState(() => _selectedRowIndex = index),
                        rows: [
                          for (final customer in customers)
                            _buildRow(codes, customer),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRow(List<Code> codes, Customer customer) {
    return [
      Text(customer.custName),
      Text(_codeName(codes, customer.aptCode)),
      Text(_codeName(codes, customer.buildingCode)),
      Text(_codeName(codes, customer.floorCode)),
      Text(_codeName(codes, customer.roomCode)),
      Text(customer.custPhone),
    ];
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final apiError = error is ApiException ? error as ApiException : null;
    final message = apiError?.message ?? '고객 목록을 불러오지 못했습니다.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    height: 1.4,
                  ),
            ),
            if (apiError?.traceId != null) ...[
              const SizedBox(height: 8),
              Text(
                'traceId: ${apiError!.traceId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
