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
import '../../code/presentation/code_list_extensions.dart';
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
  static const _columns = [
    TkGridColumn(label: '제품명'),
    TkGridColumn(
      label: '단가',
      flexRatio: 0.3,
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
    final groupItems = codes.comboItems(processCode);
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

  Future<void> _openRegisterDialog({
    required String processCode,
    required String groupCode,
    required List<Code> codes,
  }) async {
    final created = await ProductRegisterDialog.showCreate(
      context,
      processCode: processCode,
      groupCode: groupCode,
      processName: codes.displayName(processCode),
      groupName: codes.displayName(groupCode),
    );
    if (!mounted || created != true) return;
    await _search(processCode: processCode, groupCode: groupCode);
    if (!mounted) return;
    context.showTkMessage('제품이 등록되었습니다.');
  }

  Future<void> _openEditDialog(
    Product product,
    List<Code> codes, {
    required String processCode,
    required String groupCode,
  }) async {
    final updated = await ProductRegisterDialog.showEdit(
      context,
      product,
      processName: codes.displayName(product.processCode),
      groupName: codes.displayName(product.groupCode),
    );
    if (!mounted || updated != true) return;
    await _search(processCode: processCode, groupCode: groupCode);
    if (!mounted) return;
    context.showTkMessage('제품 정보가 수정되었습니다.');
  }

  Future<void> _deleteSelected(Product product) async {
    final confirmed = await showTkConfirmDialog(
      context,
      title: '제품 삭제',
      message: '\'${product.productName}\' 제품을 삭제하시겠습니까?',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await _productApi.deleteProduct(product.productCode);
      if (!mounted) return;

      await _search(
        processCode: _selectedProcessCode!,
        groupCode: _selectedGroupCode!,
      );
      if (!mounted) return;

      context.showTkMessage('제품이 삭제되었습니다.');
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
    final productsAsync = ref.watch(productListProvider);
    final codes = ref.watch(codeProvider);
    final processItems = codes.comboItems(CodeConstants.productProcess);
    final effectiveProcessCode = _selectedProcessCode ??
        (processItems.isNotEmpty ? processItems.first.value : null);
    final groupItems = codes.comboItems(effectiveProcessCode ?? '');
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
                          codes.comboItems(value ?? ''),
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
                  : () => _openRegisterDialog(
                        processCode: effectiveProcessCode,
                        groupCode: effectiveGroupCode,
                        codes: codes,
                      ),
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
          child: TkGridPanel(
            child: processItems.isEmpty
                ? const Center(child: Text('공정 코드가 없습니다.'))
                : groupItems.isEmpty
                    ? const Center(child: Text('그룹 코드가 없습니다.'))
                    : productsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => TkAsyncErrorBody(
                      error: error,
                      fallbackMessage: '제품 목록을 불러오지 못했습니다.',
                    ),
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
                        onRowDoubleTap: (index) => _openEditDialog(
                          products[index],
                          codes,
                          processCode: effectiveProcessCode!,
                          groupCode: effectiveGroupCode!,
                        ),
                      );
                    },
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
