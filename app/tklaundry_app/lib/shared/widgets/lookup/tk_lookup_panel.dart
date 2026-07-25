import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../tk_grid_table.dart';
import 'tk_lookup_item.dart';

class TkLookupGridPanel<T> extends StatelessWidget {
  const TkLookupGridPanel({
    super.key,
    required this.width,
    required this.items,
    required this.query,
    required this.selectedValue,
    required this.primaryColumnLabel,
    required this.secondaryColumnLabel,
    required this.onItemTap,
    this.maxHeight = 280,
    this.showAllOption = true,
    this.allSelected = false,
    this.onAllTap,
    this.emptyMessage = '검색 결과가 없습니다.',
  });

  final double width;
  final List<TkLookupItem<T>> items;
  final String query;
  final T? selectedValue;
  final String primaryColumnLabel;
  final String secondaryColumnLabel;
  final ValueChanged<TkLookupItem<T>> onItemTap;
  final double maxHeight;
  final bool showAllOption;
  final bool allSelected;
  final VoidCallback? onAllTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = items.indexWhere(
      (item) => item.value == selectedValue,
    );

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(6),
      color: AppColors.surfaceCard,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAllOption && onAllTap != null)
              _AllOptionRow(
                selected: allSelected,
                onTap: onAllTap!,
              ),
            SizedBox(
              height: maxHeight,
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        emptyMessage,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : TkGridTable(
                      columns: [
                        TkGridColumn(label: primaryColumnLabel),
                        TkGridColumn(label: secondaryColumnLabel),
                      ],
                      itemCount: items.length,
                      itemBuilder: (index) {
                        final item = items[index];
                        return [
                          TkLookupHighlightText(
                            text: item.label,
                            query: query,
                          ),
                          TkLookupHighlightText(
                            text: item.subtitle ?? '',
                            query: query,
                          ),
                        ];
                      },
                      selectedRowIndex:
                          selectedIndex >= 0 ? selectedIndex : null,
                      onRowTap: (index) => onItemTap(items[index]),
                      onRowDoubleTap: (index) => onItemTap(items[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllOptionRow extends StatelessWidget {
  const _AllOptionRow({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => onTap(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Text(
            '전체',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}

class TkLookupHighlightText extends StatelessWidget {
  const TkLookupHighlightText({
    super.key,
    required this.text,
    required this.query,
  });

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    if (query.isEmpty) {
      return Text(text, overflow: TextOverflow.ellipsis);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Color(0xFFFFCC80),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = index + query.length;
    }

    return Text.rich(
      TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
