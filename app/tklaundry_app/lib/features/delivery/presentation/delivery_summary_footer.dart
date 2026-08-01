import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/tk_format.dart';

class DeliverySummaryFooter extends StatelessWidget {
  const DeliverySummaryFooter({
    super.key,
    this.count,
    this.totalAmount,
  });

  final int? count;
  final int? totalAmount;

  @override
  Widget build(BuildContext context) {
    final resolvedCount = count ?? 0;
    final resolvedTotalAmount = totalAmount ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('건수: ${resolvedCount.formatted}'),
          const SizedBox(width: 24),
          Text('총액: ${resolvedTotalAmount.formatted}'),
        ],
      ),
    );
  }
}
