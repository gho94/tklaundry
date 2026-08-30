import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

abstract final class TkDatePickerMetrics {
  static const columnCount = 7;
  static const rowCount = 6;

  /// 열 1칸 너비 × 7 = 패널 본문 너비
  static const columnWidth = AppSpacing.s8;
  static const panelWidth = columnWidth * columnCount;

  static const cellHeight = AppSpacing.s6 + AppSpacing.s1;
  static const dayMarkSize = AppSpacing.s6;

  static const navButtonSize = AppSpacing.s6;
  static const navIconSize = AppSpacing.s4 + AppSpacing.s1;
  static const cornerRadius = AppSpacing.s1;

  static const gridRowCount = 3;
  static const gridColumnCount = 4;

  static const yearLabelSpan = 10;

  /// year · month 그리드 셀 (기본).
  static double get gridCellHeight => cellHeight * 2 + AppSpacing.s2;

  static double get gridMarkSize => dayMarkSize * 1.75;
}

enum _ViewMode { year, month, day }

/// 커스텀 날짜 선택 패널 (월 헤더 · 요일 행 · 6×7 그리드).
class TkDatePickerPanel extends StatefulWidget {
  const TkDatePickerPanel({
    super.key,
    required this.initialDate,
    this.onChanged,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime>? onChanged;

  @override
  State<TkDatePickerPanel> createState() => _TkDatePickerPanelState();
}

class _TkDatePickerPanelState extends State<TkDatePickerPanel> {
  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
  static final _monthFormat = DateFormat('yyyy년 M월', 'ko');
  static final _yearFormat = DateFormat('yyyy년', 'ko');

  late DateTime _displayMonth;
  late int _yearDecadeStart;
  _ViewMode _viewMode = _ViewMode.day;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
    _yearDecadeStart = _yearDecadeStartFor(widget.initialDate.year);
  }

  int _yearDecadeStartFor(int year) => (year ~/ 10) * 10;

  int _yearGridStartYear(int decadeStart) => decadeStart - 1;

  void _openMonth() {
    setState(() => _viewMode = _ViewMode.month);
  }

  void _openYear() {
    setState(() {
      _yearDecadeStart = _yearDecadeStartFor(_displayMonth.year);
      _viewMode = _ViewMode.year;
    });
  }

  void _moveMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + delta);
    });
  }

  void _moveYear(int delta) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year + delta, _displayMonth.month);
    });
  }

  void _moveYearDecade(int delta) {
    setState(() {
      _yearDecadeStart += delta * TkDatePickerMetrics.yearLabelSpan;
    });
  }

  void _selectYear(int year) {
    setState(() {
      _displayMonth = DateTime(year, _displayMonth.month);
      _viewMode = _ViewMode.month;
    });
  }

  void _selectMonth(int month) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, month);
      _viewMode = _ViewMode.day;
    });
  }

  void _selectDate(DateTime date) {
    widget.onChanged?.call(date);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(TkDatePickerMetrics.cornerRadius),
      color: AppColors.surfaceCard,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: TkDatePickerMetrics.panelWidth,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(TkDatePickerMetrics.cornerRadius),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.s3),
        child: switch (_viewMode) {
          _ViewMode.year => _buildYearBody(),
          _ViewMode.month => _buildMonthBody(),
          _ViewMode.day => _buildDayBody(),
        },
      ),
    );
  }

  Widget _buildYearBody() {
    final labelEndYear =
        _yearDecadeStart + TkDatePickerMetrics.yearLabelSpan - 1;
    final gridStartYear = _yearGridStartYear(_yearDecadeStart);

    return _PickerSection(
      headerLabel: '$_yearDecadeStart ~ $labelEndYear',
      onNav: _moveYearDecade,
      grid: _YearMonthGrid(
        cellAt: (index) {
          final year = gridStartYear + index;
          final isSelected = widget.initialDate.year == year;
          final inDecade =
              year >= _yearDecadeStart && year <= labelEndYear;
          return _DatePickerCell(
            label: '$year',
            isSelected: isSelected,
            onTap: () => _selectYear(year),
            textColor: isSelected || inDecade ? null : AppColors.neutral400,
          );
        },
      ),
    );
  }

  Widget _buildMonthBody() {
    return _PickerSection(
      headerLabel: _yearFormat.format(_displayMonth),
      onNav: _moveYear,
      onHeaderTap: _openYear,
      grid: _YearMonthGrid(
        cellAt: (index) {
          final month = index + 1;
          return _DatePickerCell(
            label: '$month월',
            isSelected: widget.initialDate.year == _displayMonth.year &&
                widget.initialDate.month == month,
            onTap: () => _selectMonth(month),
          );
        },
      ),
    );
  }

  Widget _buildDayBody() {
    return _PickerSection(
      headerLabel: _monthFormat.format(_displayMonth),
      onNav: _moveMonth,
      onHeaderTap: _openMonth,
      belowHeader: const _WeekdayRow(labels: _weekdayLabels),
      grid: _DateGrid(
        displayMonth: _displayMonth,
        selectedDate: widget.initialDate,
        onDateSelected: _selectDate,
        isSameDay: _isSameDay,
      ),
    );
  }
}

class _PickerSection extends StatelessWidget {
  const _PickerSection({
    required this.headerLabel,
    required this.onNav,
    required this.grid,
    this.onHeaderTap,
    this.belowHeader,
  });

  final String headerLabel;
  final ValueChanged<int> onNav;
  final VoidCallback? onHeaderTap;
  final Widget? belowHeader;
  final Widget grid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MonthHeader(
          label: headerLabel,
          onMoveMonth: onNav,
          onLabelTap: onHeaderTap,
        ),
        const SizedBox(height: AppSpacing.s2),
        if (belowHeader != null) ...[
          belowHeader!,
          const SizedBox(height: AppSpacing.s2),
        ],
        grid,
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onMoveMonth,
    this.onLabelTap,
  });

  final String label;
  final ValueChanged<int> onMoveMonth;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return Row(
      children: [
        _MonthNavButton(
          icon: Icons.chevron_left,
          onTap: () => onMoveMonth(-1),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onLabelTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
          ),
        ),
        _MonthNavButton(
          icon: Icons.chevron_right,
          onTap: () => onMoveMonth(1),
        ),
      ],
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TkDatePickerMetrics.navButtonSize,
      height: TkDatePickerMetrics.navButtonSize,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          icon,
          size: TkDatePickerMetrics.navIconSize,
          color: AppColors.textSecondary,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _YearMonthGrid extends StatelessWidget {
  const _YearMonthGrid({required this.cellAt});

  final Widget Function(int index) cellAt;

  static const _columnCount = TkDatePickerMetrics.gridColumnCount;
  static const _rowCount = TkDatePickerMetrics.gridRowCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        _rowCount,
        (row) => Row(
          children: List.generate(
            _columnCount,
            (col) {
              final index = row * _columnCount + col;
              return Expanded(child: cellAt(index));
            },
          ),
        ),
      ),
    );
  }
}

class _DatePickerCell extends StatelessWidget {
  const _DatePickerCell({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.textColor,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? textColor;

  /// true = day 달력 (작은 칸 · 작은 마크).
  final bool compact;

  static Color dayTextColor({
    required bool isSelected,
    required bool isCurrentMonth,
    required DateTime date,
  }) {
    if (isSelected) return AppColors.neutral0;
    if (!isCurrentMonth) return AppColors.neutral400;
    if (date.weekday == DateTime.sunday) return AppColors.error;
    if (date.weekday == DateTime.saturday) return AppColors.info;
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final cellHeight = compact
        ? TkDatePickerMetrics.cellHeight
        : TkDatePickerMetrics.gridCellHeight;
    final markSize = compact
        ? TkDatePickerMetrics.dayMarkSize
        : TkDatePickerMetrics.gridMarkSize;

    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor ??
              (isSelected ? AppColors.neutral0 : AppColors.textPrimary),
          fontWeight: FontWeight.w500,
        );

    final decoration = isSelected
        ? BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(
              TkDatePickerMetrics.cornerRadius,
            ),
          )
        : null;

    return SizedBox(
      height: cellHeight,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: markSize,
            height: markSize,
            alignment: Alignment.center,
            decoration: decoration,
            child: Text(label, style: style),
          ),
        ),
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        );

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Center(
              child: Text(
                labels[i],
                style: style?.copyWith(color: _weekdayColor(i)),
              ),
            ),
          ),
      ],
    );
  }

  Color _weekdayColor(int index) {
    if (index == 0) return AppColors.error;
    if (index == 6) return AppColors.info;
    return AppColors.textSecondary;
  }
}

class _DateGrid extends StatelessWidget {
  const _DateGrid({
    required this.displayMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isSameDay,
  });

  final DateTime displayMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime a, DateTime b) isSameDay;

  static const _rowCount = TkDatePickerMetrics.rowCount;
  static const _columnCount = TkDatePickerMetrics.columnCount;

  @override
  Widget build(BuildContext context) {
    final dates = _buildMonthGrid(displayMonth);
    final currentMonth = displayMonth.month;

    return Column(
      children: [
        for (var row = 0; row < _rowCount; row++)
          Row(
            children: [
              for (var col = 0; col < _columnCount; col++)
                Builder(
                  builder: (context) {
                    final date = dates[row * _columnCount + col];
                    final selected = isSameDay(date, selectedDate);

                    return Expanded(
                      child: _DatePickerCell(
                        label: '${date.day}',
                        isSelected: selected,
                        onTap: () => onDateSelected(date),
                        compact: true,
                        textColor: _DatePickerCell.dayTextColor(
                          isSelected: selected,
                          isCurrentMonth: date.month == currentMonth,
                          date: date,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }

  /// 일요일(0)부터 시작하는 6×7 그리드용 날짜 목록.
  List<DateTime> _buildMonthGrid(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month);
    final leadingDays = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: leadingDays));

    return List.generate(
      _rowCount * _columnCount,
      (index) => gridStart.add(Duration(days: index)),
    );
  }
}

