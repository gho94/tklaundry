import 'package:flutter/material.dart';

import '../../../../shared/widgets/lookup/tk_lookup_field.dart';
import '../../../../shared/widgets/lookup/tk_lookup_item.dart';
import '../../../../shared/widgets/list/tk_date_field.dart';
import '../../../../shared/widgets/tk_primary_button.dart';

class DeliveryViewSearchToolbar extends StatelessWidget {
  const DeliveryViewSearchToolbar({
    super.key,
    required this.startDateController,
    required this.endDateController,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.customerLookupItems,
    required this.selectedCustCode,
    required this.customersReady,
    required this.onCustomerChanged,
    required this.onSearch,
    required this.isLoading,
  });

  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final List<TkLookupItem<String>> customerLookupItems;
  final String? selectedCustCode;
  final bool customersReady;
  final ValueChanged<String?> onCustomerChanged;
  final VoidCallback onSearch;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '출고 내역',
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
        const SizedBox(width: 12),
        SizedBox(
          width: 220,
          child: TkLookupField<String>(
            label: '고객',
            hint: '고객명 · 전화번호 검색',
            primaryColumnLabel: '고객',
            secondaryColumnLabel: '전화번호',
            panelMinWidth: 360,
            items: customerLookupItems,
            value: selectedCustCode,
            enabled: customersReady,
            showAllOption: true,
            onChanged: onCustomerChanged,
          ),
        ),
        const Spacer(),
        TkPrimaryButton(
          label: '조회',
          variant: TkButtonVariant.outline,
          icon: Icons.search,
          isLoading: isLoading,
          onPressed: !customersReady || isLoading ? null : onSearch,
        ),
      ],
    );
  }
}
