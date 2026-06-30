import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_grid_table.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_provider.dart';
import '../data/product_api.dart';
import '../domain/product.dart';
import 'product_provider.dart';
import 'product_register_dialog.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  static const _processParentCodeId = 'B10002';

  static const _columns = [
    TkGridColumn(label: '제품명'),
    TkGridColumn(
      label: '단가',
      width: 120,
      numeric: true,
      align: TextAlign.end,
    ),
  ];

  String? _selectedProcessCode;
  String? _selectedGroupCode;
  int? _selectedRowIndex;
  bool _initialized = false;
  bool _isDeleting = false;
  final _productApi = ProductApi();

  List<TkComboItem<String>> _processComboItems(List<Code> codes) {
    final processes = codes
        .where((code) => code.pCodeId.trim() == _processParentCodeId)
        .toList()
      ..sort((a, b) => a.codeId.compareTo(b.codeId));

    return [
      for (final process in processes)
        TkComboItem(value: process.codeId.trim(), label: process.codeName),
    ];
  }

  List<TkComboItem<String>> _groupComboItems(
    List<Code> codes,
    String? processCode,
  ) {
    if (processCode == null || processCode.isEmpty) return const [];

    final groups = codes
        .where((code) => code.pCodeId.trim() == processCode)
        .toList()
      ..sort((a, b) => a.codeId.compareTo(b.codeId));

    return [
      for (final group in groups)
        TkComboItem(value: group.codeId.trim(), label: group.codeName),
    ];
  }

  Future<void> _search({
    required String processCode,
    required String groupCode,
  }) async {
    setState(() {
      _selectedProcessCode = processCode;
      _selectedGroupCode = groupCode;
      _selectedRowIndex = null;
    });
    await ref.read(productListProvider.notifier).search(
          processCode: processCode,
          groupCode: groupCode,
        );
  }

  Future<void> _onProcessChanged(
    String? processCode,
    List<TkComboItem<String>> groupItems,
  ) async {
    if (processCode == null) return;

    final groupCode =
        groupItems.isNotEmpty ? groupItems.first.value : null;
    if (groupCode == null) {
      setState(() {
        _selectedProcessCode = processCode;
        _selectedGroupCode = null;
        _selectedRowIndex = null;
      });
      return;
    }

    await _search(processCode: processCode, groupCode: groupCode);
  }

  Future<void> _onGroupChanged(String? groupCode) async {
    final processCode = _selectedProcessCode;
    if (groupCode == null || processCode == null) return;
    await _search(processCode: processCode, groupCode: groupCode);
  }

  void _ensureInitialSearch(
    List<TkComboItem<String>> processItems,
    List<Code> codes,
  ) {
    if (_initialized || processItems.isEmpty) return;

    final processCode = processItems.first.value;
    final groupItems = _groupComboItems(codes, processCode);
    if (groupItems.isEmpty) return;

    _initialized = true;
    final groupCode = groupItems.first.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search(processCode: processCode, groupCode: groupCode);
    });
  }

  String _formatPrice(int? price) {
    if (price == null) return '';
    return price.toString();
  }

  String _lookupCodeName(List<Code> codes, String codeId) {
    for (final code in codes) {
      if (code.codeId.trim() == codeId.trim()) {
        return code.codeName;
      }
    }
    return codeId;
  }

  Future<void> _deleteSelected(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('제품 삭제'),
        content: Text('\'${product.productName}\' 제품을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await _productApi.deleteProduct(product.productCode);
      if (!mounted) return;

      await _search(
        processCode: _selectedProcessCode!,
        groupCode: _selectedGroupCode!,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제품이 삭제되었습니다.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final codesAsync = ref.watch(codeProvider);
    final codes = codesAsync.asData?.value ?? const <Code>[];
    final processItems = _processComboItems(codes);
    final effectiveProcessCode = _selectedProcessCode ??
        (processItems.isNotEmpty ? processItems.first.value : null);
    final groupItems = _groupComboItems(codes, effectiveProcessCode);
    _ensureInitialSearch(processItems, codes);

    final effectiveGroupCode = _selectedGroupCode ??
        (groupItems.isNotEmpty ? groupItems.first.value : null);

    final canSearch = effectiveProcessCode != null &&
        effectiveGroupCode != null &&
        processItems.isNotEmpty &&
        groupItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '제품',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 140,
              child: TkComboBox<String>(
                label: '공정',
                items: processItems,
                value: effectiveProcessCode,
                enabled: processItems.isNotEmpty,
                showAllOption: false,
                onChanged: processItems.isEmpty
                    ? null
                    : (value) => _onProcessChanged(
                          value,
                          _groupComboItems(codes, value),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: TkComboBox<String>(
                label: '그룹',
                items: groupItems,
                value: effectiveGroupCode,
                enabled: groupItems.isNotEmpty,
                showAllOption: false,
                onChanged:
                    groupItems.isEmpty ? null : _onGroupChanged,
              ),
            ),
            const Spacer(),
            TkPrimaryButton(
              label: '등록',
              variant: TkButtonVariant.outline,
              icon: Icons.add_outlined,
              onPressed: !canSearch
                  ? null
                  : () async {
                      final created = await ProductRegisterDialog.showCreate(
                        context,
                        processCode: effectiveProcessCode,
                        groupCode: effectiveGroupCode,
                        processName:
                            _lookupCodeName(codes, effectiveProcessCode),
                        groupName: _lookupCodeName(codes, effectiveGroupCode),
                      );
                      if (!mounted || created != true) return;
                      await _search(
                        processCode: effectiveProcessCode,
                        groupCode: effectiveGroupCode,
                      );
                    },
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
                      final products = productsAsync.asData?.value;
                      if (products == null ||
                          _selectedRowIndex! >= products.length) {
                        return;
                      }
                      _deleteSelected(products[_selectedRowIndex!]);
                    },
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: productsAsync.isLoading,
              onPressed: !canSearch || productsAsync.isLoading
                  ? null
                  : () => _search(
                        processCode: effectiveProcessCode,
                        groupCode: effectiveGroupCode,
                      ),
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
                  if (processItems.isEmpty) {
                    return const Center(child: Text('공정 코드가 없습니다.'));
                  }
                  if (groupItems.isEmpty) {
                    return const Center(child: Text('그룹 코드가 없습니다.'));
                  }

                  return productsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _ErrorBody(error: error),
                    data: (products) {
                      if (_selectedRowIndex != null &&
                          _selectedRowIndex! >= products.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _selectedRowIndex = null);
                          }
                        });
                      }

                      return TkGridTable(
                        columns: _columns,
                        itemCount: products.length,
                        itemBuilder: (index) => _buildRow(products[index]),
                        selectedRowIndex: _selectedRowIndex,
                        onRowTap: (index) =>
                            setState(() => _selectedRowIndex = index),
                        onRowDoubleTap: (index) async {
                          final product = products[index];
                          final updated = await ProductRegisterDialog.showEdit(
                            context,
                            product,
                            processName: _lookupCodeName(
                              codes,
                              product.processCode,
                            ),
                            groupName: _lookupCodeName(
                              codes,
                              product.groupCode,
                            ),
                          );
                          if (!mounted || updated != true) return;
                          await _search(
                            processCode: effectiveProcessCode!,
                            groupCode: effectiveGroupCode!,
                          );
                        },
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

  List<Widget> _buildRow(Product product) {
    return [
      Text(product.productName),
      Text(_formatPrice(product.price)),
    ];
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final apiError = error is ApiException ? error as ApiException : null;
    final message = apiError?.message ?? '제품 목록을 불러오지 못했습니다.';

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
