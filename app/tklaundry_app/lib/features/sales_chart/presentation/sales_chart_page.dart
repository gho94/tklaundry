import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_async_error_body.dart';
import '../../../shared/widgets/tk_grid_panel.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../domain/chart_unit.dart';
import '../domain/sales_chart_item.dart';
import 'sales_chart_bar_panel.dart';
import 'sales_chart_provider.dart';

class SalesChartPage extends ConsumerStatefulWidget {
  const SalesChartPage({super.key});

  @override
  ConsumerState<SalesChartPage> createState() => _SalesChartPageState();
}

class _SalesChartPageState extends ConsumerState<SalesChartPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  ChartUnit _unit = ChartUnit.day;
  bool _initialized = false;

  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    _endDate = todayDate;
    _startDate = DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
    _startDateController = TextEditingController(text: _startDate.toApiDate());
    _endDateController = TextEditingController(text: _endDate.toApiDate());
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String get _title {
    return switch (_unit) {
      ChartUnit.day => '일매출현황',
      ChartUnit.month => '월매출현황',
      ChartUnit.year => '연매출현황',
    };
  }

  Future<void> _search() async {
    await ref.read(salesChartProvider.notifier).search(
          SalesChartSearchParams(
            startDate: _startDate,
            endDate: _endDate,
            unit: _unit,
          ),
        );
  }

  void _ensureInitialSearch() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search();
    });
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    onSelected(DateTime(picked.year, picked.month, picked.day));
    await _search();
  }

  void _selectUnit(ChartUnit unit) {
    setState(() {
      _unit = unit;
      if (unit == ChartUnit.month) {
        _startDate = DateTime(_startDate.year, _startDate.month, 1);
        _startDateController.text = _startDate.toApiDate();
      } else if (unit == ChartUnit.year) {
        _startDate = DateTime(_startDate.year, 1, 1);
        _startDateController.text = _startDate.toApiDate();
      }
    });
    _search();
  }

  String _formatPeriodLabel(SalesChartItem item) {
    final salesDate = item.salesDate;
    return switch (_unit) {
      ChartUnit.day => _formatDayLabel(salesDate),
      ChartUnit.month => _formatMonthLabel(salesDate),
      ChartUnit.year => _formatYearLabel(salesDate),
    };
  }

  String _formatDayLabel(String salesDate) {
    final parsed = DateTime.tryParse(salesDate);
    if (parsed == null) return salesDate;
    final date = DateTime(parsed.year, parsed.month, parsed.day);
    if (_startDate.year == _endDate.year) {
      return '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
    final year = date.year % 100;
    return '$year-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatMonthLabel(String salesDate) {
    if (salesDate.length >= 7) {
      final year = int.tryParse(salesDate.substring(0, 4));
      final month = int.tryParse(salesDate.substring(5, 7));
      if (year != null && month != null) {
        final shortYear = year % 100;
        return '$shortYear년 ${month.toString().padLeft(2, '0')}월';
      }
    }
    return salesDate;
  }

  String _formatYearLabel(String salesDate) {
    final parsed = DateTime.tryParse(salesDate);
    if (parsed != null) {
      return '${parsed.year}년';
    }
    if (salesDate.length >= 4) {
      return '${salesDate.substring(0, 4)}년';
    }
    return salesDate;
  }

  @override
  Widget build(BuildContext context) {
    final chartAsync = ref.watch(salesChartProvider);
    _ensureInitialSearch();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '매출현황',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: () => _pickDate(
                  initialDate: _startDate,
                  onSelected: (date) {
                    setState(() => _startDate = date);
                    _startDateController.text = date.toApiDate();
                  },
                ),
                child: AbsorbPointer(
                  child: TkTextField(
                    label: '시작일',
                    readOnly: true,
                    controller: _startDateController,
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: GestureDetector(
                onTap: () => _pickDate(
                  initialDate: _endDate,
                  onSelected: (date) {
                    setState(() => _endDate = date);
                    _endDateController.text = date.toApiDate();
                  },
                ),
                child: AbsorbPointer(
                  child: TkTextField(
                    label: '종료일',
                    readOnly: true,
                    controller: _endDateController,
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TkPrimaryButton(
              label: '일매출',
              variant: _unit == ChartUnit.day
                  ? TkButtonVariant.primary
                  : TkButtonVariant.outline,
              onPressed: () => _selectUnit(ChartUnit.day),
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '월매출',
              variant: _unit == ChartUnit.month
                  ? TkButtonVariant.primary
                  : TkButtonVariant.outline,
              onPressed: () => _selectUnit(ChartUnit.month),
            ),
            const SizedBox(width: 8),
            TkPrimaryButton(
              label: '연매출',
              variant: _unit == ChartUnit.year
                  ? TkButtonVariant.primary
                  : TkButtonVariant.outline,
              onPressed: () => _selectUnit(ChartUnit.year),
            ),
            const Spacer(),
            TkPrimaryButton(
              label: '조회',
              variant: TkButtonVariant.outline,
              icon: Icons.search,
              isLoading: chartAsync.isLoading,
              onPressed: chartAsync.isLoading ? null : _search,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TkGridPanel(
            child: chartAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => TkAsyncErrorBody(
                error: error,
                fallbackMessage: '매출현황을 불러오지 못했습니다.',
              ),
              data: (result) => SalesChartBarPanel(
                items: result.items,
                periodLabel: _formatPeriodLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
