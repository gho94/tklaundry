import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../data/code_api.dart';
import '../domain/code.dart';

class CodeRegisterDialog extends StatefulWidget {
  const CodeRegisterDialog({
    super.key,
    required this.pCodeId,
    required this.parentLabel,
  });

  final String pCodeId;
  final String parentLabel;

  static Future<Code?> show(
    BuildContext context, {
    required String pCodeId,
    required String parentLabel,
  }) {
    return showDialog<Code>(
      context: context,
      builder: (_) => CodeRegisterDialog(
        pCodeId: pCodeId,
        parentLabel: parentLabel,
      ),
    );
  }

  static Future<Code?> showTopLevel(BuildContext context) {
    return show(
      context,
      pCodeId: 'Root',
      parentLabel: '최상코드',
    );
  }

  static Future<Code?> showChild(BuildContext context, Code parent) {
    return show(
      context,
      pCodeId: parent.codeId,
      parentLabel: parent.codeName,
    );
  }

  @override
  State<CodeRegisterDialog> createState() => _CodeRegisterDialogState();
}

class _CodeRegisterDialogState extends State<CodeRegisterDialog> {
  final _codeApi = CodeApi();
  final _codeNameController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _traceId;

  @override
  void dispose() {
    _codeNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final codeName = _codeNameController.text.trim();
    if (codeName.isEmpty) {
      setState(() {
        _errorMessage = '코드명을 입력해 주세요.';
        _traceId = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _traceId = null;
    });

    try {
      final created = await _codeApi.registerCode(
        pCodeId: widget.pCodeId,
        codeName: codeName,
      );
      if (!mounted) return;
      Navigator.of(context).pop(created);
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
      title: const Text('코드 등록'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReadOnlyField(label: '상위 코드', value: widget.parentLabel),
            const SizedBox(height: AppSpacing.s3),
            _ReadOnlyField(label: '상위 ID', value: widget.pCodeId),
            const SizedBox(height: AppSpacing.s3),
            TkTextField(
              controller: _codeNameController,
              label: '코드명',
              hint: '코드명',
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.s3),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
              ),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TkPrimaryButton(
          label: '등록',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
        ),
        const SizedBox(height: AppSpacing.s1),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s2,
          ),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
