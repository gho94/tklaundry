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

class TkGridTable extends StatelessWidget {
  const TkGridTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = '데이터가 없습니다.',
    this.rowHeight = 44,
    this.headerHeight = 44,
  });

  final List<TkGridColumn> columns;
  final List<List<Widget>> rows;
  final String emptyMessage;
  final double rowHeight;
  final double headerHeight;

  static const _borderSide = BorderSide(color: AppColors.border, width: 1);

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Table(
              border: const TableBorder(
                top: _borderSide,
                bottom: _borderSide,
                left: _borderSide,
                right: _borderSide,
                horizontalInside: _borderSide,
                verticalInside: _borderSide,
              ),
              columnWidths: columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                  children: [
                    for (final column in columns) _headerCell(column),
                  ],
                ),
                for (final row in rows)
                  TableRow(
                    children: [
                      for (var i = 0; i < columns.length; i++)
                        _dataCell(row[i], columns[i]),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths(double totalWidth) {
    final fixedTotal = columns
        .where((column) => column.width != null)
        .fold(0.0, (sum, column) => sum + column.width!);
    final flexibleCount = columns.where((column) => column.width == null).length;
    final remaining = (totalWidth - fixedTotal).clamp(0, double.infinity);
    final equalWidth = flexibleCount == 0 ? 0.0 : remaining / flexibleCount;

    return {
      for (var i = 0; i < columns.length; i++)
        i: columns[i].width != null
            ? FixedColumnWidth(columns[i].width!)
            : FixedColumnWidth(equalWidth),
    };
  }

  Widget _headerCell(TkGridColumn column) {
    return SizedBox(
      height: headerHeight,
      child: Padding(
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
      ),
    );
  }

  Widget _dataCell(Widget child, TkGridColumn column) {
    final isInteractive = child is TkGridComboBox || child is TkComboBox;

    return SizedBox(
      height: rowHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isInteractive ? 4 : 12,
          vertical: isInteractive ? 4 : 0,
        ),
        child: Align(
          alignment: _alignment(column.align, column.numeric),
          child: child,
        ),
      ),
    );
  }

  Alignment _alignment(TextAlign align, bool numeric) {
    if (numeric) return Alignment.centerRight;
    return switch (align) {
      TextAlign.center => Alignment.center,
      TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };
  }
}
