import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../data/code_api.dart';
import '../domain/code.dart';

class CodeEditDialog extends StatefulWidget {
  const CodeEditDialog({
    super.key,
    required this.code,
  });

  final Code code;

  static Future<bool?> show(BuildContext context, Code code) {
    return showDialog<bool>(
      context: context,
      builder: (_) => CodeEditDialog(code: code),
    );
  }

  @override
  State<CodeEditDialog> createState() => _CodeEditDialogState();
}

class _CodeEditDialogState extends State<CodeEditDialog> {
  final _codeApi = CodeApi();
  late final TextEditingController _codeNameController;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _traceId;

  @override
  void initState() {
    super.initState();
    _codeNameController = TextEditingController(text: widget.code.codeName);
  }

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
      await _codeApi.updateCode(
        codeId: widget.code.codeId,
        codeName: codeName,
      );
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
      title: const Text('코드 수정'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReadOnlyField(label: '코드 ID', value: widget.code.codeId),
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
          label: '저장',
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
