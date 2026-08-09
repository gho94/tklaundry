import 'package:flutter/material.dart';

import '../../../shared/widgets/list/tk_date_field.dart';
import '../../../shared/widgets/tk_primary_button.dart';

class ExpendListSearchToolbar extends StatelessWidget {
  const ExpendListSearchToolbar({
    super.key,
    required this.startDateController,
    required this.endDateController,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onRegister,
    required this.onSearch,
    required this.isLoading,
  });

  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
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
        TkDateField(
          label: '시작일',
          controller: startDateController,
          onTap: onPickStartDate,
        ),
        const SizedBox(width: 12),
        TkDateField(
          label: '종료일',
          controller: endDateController,
          onTap: onPickEndDate,
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
