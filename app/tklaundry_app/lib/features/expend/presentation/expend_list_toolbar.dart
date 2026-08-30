import 'package:flutter/material.dart';

import '../../../shared/widgets/list/tk_date_picker_overlay.dart';
import '../../../shared/widgets/tk_primary_button.dart';

class ExpendListSearchToolbar extends StatelessWidget {
  const ExpendListSearchToolbar({
    super.key,
    required this.startDateController,
    required this.endDateController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onRegister,
    required this.onSearch,
    required this.isLoading,
  });

  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateSelected;
  final ValueChanged<DateTime> onEndDateSelected;
  final VoidCallback onRegister;
  final VoidCallback onSearch;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '지출',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 24),
        TkDatePickerField(
          label: '시작일',
          controller: startDateController,
          date: startDate,
          onDateSelected: onStartDateSelected,
        ),
        const SizedBox(width: 12),
        TkDatePickerField(
          label: '종료일',
          controller: endDateController,
          date: endDate,
          onDateSelected: onEndDateSelected,
        ),
        const Spacer(),
        TkPrimaryButton(
          label: '등록',
          variant: TkButtonVariant.outline,
          icon: Icons.add_outlined,
          onPressed: onRegister,
        ),
        const SizedBox(width: 8),
        TkPrimaryButton(
          label: '조회',
          variant: TkButtonVariant.outline,
          icon: Icons.search,
          isLoading: isLoading,
          onPressed: isLoading ? null : onSearch,
        ),
      ],
    );
  }
}
