import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../data/product_api.dart';
import '../domain/product.dart';

class ProductRegisterDialog extends StatefulWidget {
  const ProductRegisterDialog({
    super.key,
    this.product,
    required this.processCode,
    required this.groupCode,
    required this.processName,
    required this.groupName,
  });

  final Product? product;
  final String processCode;
  final String groupCode;
  final String processName;
  final String groupName;

  bool get _isEdit => product != null;

  static Future<bool?> showCreate(
    BuildContext context, {
    required String processCode,
    required String groupCode,
    required String processName,
    required String groupName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ProductRegisterDialog(
        processCode: processCode,
        groupCode: groupCode,
        processName: processName,
        groupName: groupName,
      ),
    );
  }

  static Future<bool?> showEdit(
    BuildContext context,
    Product product, {
    required String processName,
    required String groupName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ProductRegisterDialog(
        product: product,
        processCode: product.processCode,
        groupCode: product.groupCode,
        processName: processName,
        groupName: groupName,
      ),
    );
  }

  @override
  State<ProductRegisterDialog> createState() => _ProductRegisterDialogState();
}

class _ProductRegisterDialogState extends State<ProductRegisterDialog> {
  final _productApi = ProductApi();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _traceId;

  bool get _isEdit => widget._isEdit;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product == null) return;

    _productNameController.text = product.productName;
    _priceController.text = product.price?.toString() ?? '';
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _traceId = null;
    });

    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final productName = _productNameController.text;

    try {
      if (_isEdit) {
        await _productApi.updateProduct(
          productCode: widget.product!.productCode,
          productName: productName,
          price: price,
        );
      } else {
        await _productApi.registerProduct(
          processCode: widget.processCode,
          groupCode: widget.groupCode,
          productName: productName,
          price: price,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? '제품 수정' : '제품 등록'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadOnlyField(label: '공정', value: widget.processName),
              const SizedBox(height: 12),
              _ReadOnlyField(label: '그룹', value: widget.groupName),
              const SizedBox(height: 12),
              TkTextField(
                controller: _productNameController,
                label: '제품명',
                hint: '제품명',
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TkTextField(
                controller: _priceController,
                label: '단가',
                hint: '단가',
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        height: 1.4,
                      ),
                ),
              ],
              if (_traceId != null) ...[
                const SizedBox(height: 8),
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
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        TkPrimaryButton(
          label: _isEdit ? '저장' : '등록',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
