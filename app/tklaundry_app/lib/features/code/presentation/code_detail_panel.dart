import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/code.dart';
import '../domain/code_tree.dart';

class CodeDetailPanel extends StatelessWidget {
  const CodeDetailPanel({
    super.key,
    required this.selectedCode,
    required this.codes,
  });

  final Code? selectedCode;
  final List<Code> codes;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Text(
              '선택한 코드',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Divider(height: 1, color: AppColors.neutral200),
          Expanded(
            child: selectedCode == null
                ? Center(
                    child: Text(
                      '왼쪽 트리에서 코드를 선택하세요.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DetailField(
                          label: '코드 ID',
                          value: selectedCode!.codeId,
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        _DetailField(
                          label: '코드명',
                          value: selectedCode!.codeName,
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        _DetailField(
                          label: '상위 ID',
                          value: selectedCode!.parentLabel,
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        _DetailField(
                          label: '등급',
                          value: '${codeDepth(selectedCode!.codeId, codes)}',
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
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
