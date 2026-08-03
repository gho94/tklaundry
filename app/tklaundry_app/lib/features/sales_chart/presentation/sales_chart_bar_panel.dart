import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/tk_format.dart';
import '../domain/sales_chart_item.dart';

class SalesChartBarPanel extends StatelessWidget {
  const SalesChartBarPanel({
    super.key,
    required this.items,
    required this.periodLabel,
    this.onBarTap,
  });

  final List<SalesChartItem> items;
  final String Function(SalesChartItem item) periodLabel;
  final ValueChanged<SalesChartItem>? onBarTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('표시할 매출 데이터가 없습니다.'));
    }

    final maxAbsCost = items
        .map((item) => item.cost.abs())
        .fold<int>(0, (max, cost) => cost > max ? cost : max);
    final chartMaxY = maxAbsCost == 0 ? 1.0 : maxAbsCost * 1.1;
    final minCost = items.map((item) => item.cost).reduce((a, b) => a < b ? a : b);
    final chartMinY = minCost < 0 ? minCost * 1.1 : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: BarChart(
        BarChartData(
          minY: chartMinY,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toInt().formatted,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _bottomLabelInterval(items.length),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      periodLabel(items[index]),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var index = 0; index < items.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: items[index].cost.toDouble(),
                    fromY: items[index].cost < 0 ? items[index].cost.toDouble() : 0,
                    color: AppColors.primary,
                    width: _barWidth(items.length),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: onBarTap == null
                ? null
                : (event, response) {
                    if (event is! FlTapUpEvent || response?.spot == null) {
                      return;
                    }
                    final index = response!.spot!.touchedBarGroupIndex;
                    if (index < 0 || index >= items.length) return;
                    onBarTap!(items[index]);
                  },
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = items[group.x];
                return BarTooltipItem(
                  '${periodLabel(item)}\n${item.cost.formatted}원',
                  Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.neutral0,
                        fontWeight: FontWeight.w600,
                      ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _barWidth(int count) {
    if (count <= 12) return 18;
    if (count <= 24) return 12;
    return 8;
  }

  double _bottomLabelInterval(int count) {
    if (count <= 12) return 1;
    if (count <= 24) return 2;
    if (count <= 40) return 3;
    return (count / 10).ceilToDouble();
  }
}
