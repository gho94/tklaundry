import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/code_tree.dart';

class CodeTreePanel extends StatelessWidget {
  const CodeTreePanel({
    super.key,
    required this.rows,
    required this.expandedCodeIds,
    required this.selectedCodeId,
    required this.onToggleExpanded,
    required this.onSelect,
  });

  final List<CodeTreeRow> rows;
  final Set<String> expandedCodeIds;
  final String? selectedCodeId;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<String> onSelect;

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
          Container(
            color: AppColors.neutral100,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s3,
              vertical: AppSpacing.s2,
            ),
            child: Text(
              '코드명',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Divider(height: 1, color: AppColors.neutral200),
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Text(
                      '등록된 코드가 없습니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  )
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: AppColors.neutral200,
                    ),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final code = row.node.code;
                      final isSelected = selectedCodeId == code.codeId;
                      final isExpanded =
                          expandedCodeIds.contains(code.codeId);

                      return Material(
                        color: isSelected
                            ? AppColors.primaryMuted
                            : Colors.transparent,
                        child: InkWell(
                          onTap: () => onSelect(code.codeId),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s2,
                              vertical: AppSpacing.s2,
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: row.depth * 16.0),
                                SizedBox(
                                  width: 28,
                                  child: row.node.hasChildren
                                      ? IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 28,
                                            minHeight: 28,
                                          ),
                                          iconSize: 18,
                                          onPressed: () =>
                                              onToggleExpanded(code.codeId),
                                          icon: Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_down
                                                : Icons.keyboard_arrow_right,
                                            color: AppColors.neutral600,
                                          ),
                                        )
                                      : const SizedBox(width: 18),
                                ),
                                Icon(
                                  row.node.hasChildren
                                      ? Icons.folder_outlined
                                      : Icons.description_outlined,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.neutral600,
                                ),
                                const SizedBox(width: AppSpacing.s2),
                                Expanded(
                                  child: Text(
                                    code.codeName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: row.node.hasChildren
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
