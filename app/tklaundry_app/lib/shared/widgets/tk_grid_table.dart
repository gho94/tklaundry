import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'tk_combo_box.dart';

class TkGridColumn {
  const TkGridColumn({
    required this.label,
    this.width,
    this.flexRatio,
    this.numeric = false,
    this.align = TextAlign.start,
  }) : assert(
          width == null || flexRatio == null,
          'width(고정 px)와 flexRatio(비율)는 동시에 지정할 수 없습니다.',
        ),
        assert(
          flexRatio == null || (flexRatio > 0 && flexRatio <= 1),
          'flexRatio는 0 초과 ~ 1 이하여야 합니다.',
        );

  final String label;

  /// 고정 너비(px). [flexRatio]와 함께 쓸 수 없음.
  final double? width;

  /// 테이블 전체 너비 대비 비율 (0~1). 예: `0.3` = 30%.
  /// 지정하지 않은 컬럼은 남은 너비를 균등 분배.
  final double? flexRatio;

  final bool numeric;
  final TextAlign align;
}

typedef TkGridRowBuilder = List<Widget> Function(int index);

typedef TkGridHeaderCellBuilder = Widget? Function(
  int columnIndex,
  TkGridColumn column,
);

class TkGridTable extends StatelessWidget {
  const TkGridTable({
    super.key,
    required this.columns,
    this.rows,
    this.itemCount,
    this.itemBuilder,
    this.headerCellBuilder,
    this.emptyMessage = '데이터가 없습니다.',
    this.rowHeight = 44,
    this.headerHeight = 44,
    this.onRowTap,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.selectedRowIndex,
    this.showRowNumber = false,
    this.rowNumberWidth = 50,
  }) : assert(
          rows != null || (itemCount != null && itemBuilder != null),
          'rows 또는 itemCount·itemBuilder가 필요합니다.',
        );

  final List<TkGridColumn> columns;
  final List<List<Widget>>? rows;
  final int? itemCount;
  final TkGridRowBuilder? itemBuilder;
  final TkGridHeaderCellBuilder? headerCellBuilder;
  final String emptyMessage;
  final double rowHeight;
  final double headerHeight;
  final void Function(int index)? onRowTap;
  final void Function(int index)? onRowDoubleTap;
  final void Function(int index)? onRowSecondaryTap;
  final int? selectedRowIndex;

  /// 레거시 DevExpress `ShowIndicator` — 왼쪽 행번호 (1부터).
  final bool showRowNumber;

  /// 레거시 `IndicatorWidth` 기본 50.
  final double rowNumberWidth;

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
              headerCellBuilder: headerCellBuilder,
              showRowNumber: showRowNumber,
              rowNumberWidth: rowNumberWidth,
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
                      rowNumber: showRowNumber ? index + 1 : null,
                      rowNumberWidth: rowNumberWidth,
                      onTap: onRowTap == null
                          ? null
                          : () => onRowTap!(index),
                      onDoubleTap: onRowDoubleTap == null
                          ? null
                          : () => onRowDoubleTap!(index),
                      onSecondaryTap: onRowSecondaryTap == null
                          ? null
                          : () => onRowSecondaryTap!(index),
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
    final contentWidth =
        showRowNumber ? totalWidth - rowNumberWidth : totalWidth;
    var remaining = contentWidth;

    for (final column in columns) {
      if (column.width != null) {
        remaining -= column.width!;
      } else if (column.flexRatio != null) {
        remaining -= contentWidth * column.flexRatio!;
      }
    }

    final equalShareCount =
        columns.where((column) => column.width == null && column.flexRatio == null).length;
    final equalWidth = equalShareCount == 0
        ? 0.0
        : (remaining / equalShareCount).clamp(0.0, double.infinity).toDouble();

    return [
      for (final column in columns)
        if (column.width != null)
          column.width!
        else if (column.flexRatio != null)
          contentWidth * column.flexRatio!
        else
          equalWidth,
    ];
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.widths,
    required this.height,
    this.headerCellBuilder,
    this.showRowNumber = false,
    this.rowNumberWidth = 50,
  });

  final List<TkGridColumn> columns;
  final List<double> widths;
  final double height;
  final TkGridHeaderCellBuilder? headerCellBuilder;
  final bool showRowNumber;
  final double rowNumberWidth;

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
            if (showRowNumber)
              _RowNumberCell(
                width: rowNumberWidth,
                isHeader: true,
              ),
            for (var i = 0; i < columns.length; i++)
              _HeaderCell(
                column: columns[i],
                width: widths[i],
                showRightBorder: i < columns.length - 1,
                child: headerCellBuilder?.call(i, columns[i]),
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
    this.child,
  });

  final TkGridColumn column;
  final double width;
  final bool showRightBorder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: showRightBorder
            ? const Border(right: TkGridTable._borderSide)
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: child == null ? 12 : 4),
      child: Align(
        alignment: Alignment.center,
        child: child ??
            Text(
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
    this.onSecondaryTap,
    this.rowNumber,
    this.rowNumberWidth = 50,
  });

  final List<Widget> cells;
  final List<TkGridColumn> columns;
  final List<double> widths;
  final bool selected;
  final double rowHeight;
  final int? rowNumber;
  final double rowNumberWidth;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSecondaryTap;

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
            if (rowNumber != null)
              _RowNumberCell(
                width: rowNumberWidth,
                number: rowNumber,
              ),
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

    if (onTap == null && onDoubleTap == null && onSecondaryTap == null) {
      return row;
    }

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTap: onSecondaryTap,
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
    final isInteractive = child is TkComboBox;

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

class _RowNumberCell extends StatelessWidget {
  const _RowNumberCell({
    required this.width,
    this.number,
    this.isHeader = false,
  });

  final double width;
  final int? number;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        border: Border(right: TkGridTable._borderSide),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Align(
        alignment: Alignment.center,
        child: number == null
            ? const SizedBox.shrink()
            : Text(
                '$number',
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
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
