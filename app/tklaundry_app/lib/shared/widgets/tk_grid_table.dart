import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'tk_combo_box.dart';

class TkGridColumn {
  const TkGridColumn({
    required this.label,
    this.width,
    this.numeric = false,
    this.align = TextAlign.start,
  });

  final String label;
  final double? width;
  final bool numeric;
  final TextAlign align;
}

typedef TkGridRowBuilder = List<Widget> Function(int index);

class TkGridTable extends StatelessWidget {
  const TkGridTable({
    super.key,
    required this.columns,
    this.rows,
    this.itemCount,
    this.itemBuilder,
    this.emptyMessage = '데이터가 없습니다.',
    this.rowHeight = 44,
    this.headerHeight = 44,
    this.onRowTap,
    this.onRowDoubleTap,
    this.selectedRowIndex,
  }) : assert(
          rows != null || (itemCount != null && itemBuilder != null),
          'rows 또는 itemCount·itemBuilder가 필요합니다.',
        );

  final List<TkGridColumn> columns;
  final List<List<Widget>>? rows;
  final int? itemCount;
  final TkGridRowBuilder? itemBuilder;
  final String emptyMessage;
  final double rowHeight;
  final double headerHeight;
  final void Function(int index)? onRowTap;
  final void Function(int index)? onRowDoubleTap;
  final int? selectedRowIndex;

  static const _borderSide = BorderSide(color: AppColors.border, width: 1);

  int get _length => rows?.length ?? itemCount!;

  List<Widget> _cellsAt(int index) {
    return rows != null ? rows![index] : itemBuilder!(index);
  }

  @override
  Widget build(BuildContext context) {
    if (_length == 0) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidths = _buildColumnWidths(constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderRow(
              columns: columns,
              widths: columnWidths,
              height: headerHeight,
            ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    left: _borderSide,
                    right: _borderSide,
                  ),
                ),
                child: ListView.builder(
                  itemCount: _length,
                  itemExtent: rowHeight,
                  itemBuilder: (context, index) {
                    return _DataRow(
                      cells: _cellsAt(index),
                      columns: columns,
                      widths: columnWidths,
                      selected: selectedRowIndex == index,
                      rowHeight: rowHeight,
                      onTap: onRowTap == null
                          ? null
                          : () => onRowTap!(index),
                      onDoubleTap: onRowDoubleTap == null
                          ? null
                          : () => onRowDoubleTap!(index),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<double> _buildColumnWidths(double totalWidth) {
    final fixedTotal = columns
        .where((column) => column.width != null)
        .fold(0.0, (sum, column) => sum + column.width!);
    final flexibleCount = columns.where((column) => column.width == null).length;
    final remaining = (totalWidth - fixedTotal).clamp(0, double.infinity);
    final equalWidth = flexibleCount == 0 ? 0.0 : remaining / flexibleCount;

    return [
      for (final column in columns)
        column.width ?? equalWidth,
    ];
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.widths,
    required this.height,
  });

  final List<TkGridColumn> columns;
  final List<double> widths;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.neutral100,
        border: Border(
          top: TkGridTable._borderSide,
          left: TkGridTable._borderSide,
          right: TkGridTable._borderSide,
          bottom: TkGridTable._borderSide,
        ),
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++)
              _HeaderCell(
                column: columns[i],
                width: widths[i],
                showRightBorder: i < columns.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.width,
    required this.showRightBorder,
  });

  final TkGridColumn column;
  final double width;
  final bool showRightBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: showRightBorder
            ? const Border(right: TkGridTable._borderSide)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: _alignment(column.align, column.numeric),
        child: Text(
          column.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.cells,
    required this.columns,
    required this.widths,
    required this.selected,
    required this.rowHeight,
    this.onTap,
    this.onDoubleTap,
  });

  final List<Widget> cells;
  final List<TkGridColumn> columns;
  final List<double> widths;
  final bool selected;
  final double rowHeight;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final row = DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : null,
        border: const Border(bottom: TkGridTable._borderSide),
      ),
      child: SizedBox(
        height: rowHeight,
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++)
              _DataCell(
                column: columns[i],
                width: widths[i],
                showRightBorder: i < columns.length - 1,
                child: cells[i],
              ),
          ],
        ),
      ),
    );

    if (onTap == null && onDoubleTap == null) return row;

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.child,
    required this.column,
    required this.width,
    required this.showRightBorder,
  });

  final Widget child;
  final TkGridColumn column;
  final double width;
  final bool showRightBorder;

  @override
  Widget build(BuildContext context) {
    final isInteractive = child is TkGridComboBox || child is TkComboBox;

    return Container(
      width: width,
      decoration: BoxDecoration(
        border: showRightBorder
            ? const Border(right: TkGridTable._borderSide)
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isInteractive ? 4 : 12,
        vertical: isInteractive ? 4 : 0,
      ),
      child: Align(
        alignment: _alignment(column.align, column.numeric),
        child: child,
      ),
    );
  }
}

Alignment _alignment(TextAlign align, bool numeric) {
  if (numeric) return Alignment.centerRight;
  return switch (align) {
    TextAlign.center => Alignment.center,
    TextAlign.end => Alignment.centerRight,
    _ => Alignment.centerLeft,
  };
}
