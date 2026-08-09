import 'package:flutter/material.dart';

import '../../../../shared/widgets/tk_combo_box.dart';
import '../../../../shared/widgets/tk_primary_button.dart';

class DeliveryListActionBar extends StatelessWidget {
  const DeliveryListActionBar({
    super.key,
    required this.statusItems,
    required this.statusCode,
    required this.bankingYn,
    required this.isSubmitting,
    required this.hasSelectedDetails,
    required this.onStatusChanged,
    required this.onBankingChanged,
    required this.onRegister,
  });

  final List<TkComboItem<String>> statusItems;
  final String? statusCode;
  final bool bankingYn;
  final bool isSubmitting;
  final bool hasSelectedDetails;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<bool> onBankingChanged;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final statusEnabled = statusItems.isNotEmpty && !isSubmitting;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: TkComboBox<String>(
            label: '결제 상태',
            items: statusItems,
            value: statusCode,
            showAllOption: false,
            compact: true,
            enabled: statusEnabled,
            onChanged: statusEnabled ? onStatusChanged : null,
          ),
        ),
        const SizedBox(width: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: bankingYn,
              visualDensity: VisualDensity.compact,
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      onBankingChanged(value ?? false);
                    },
            ),
            const Text('뱅킹'),
          ],
        ),
        const Spacer(),
        TkPrimaryButton(
          label: '출고',
          icon: Icons.local_shipping_outlined,
          isLoading: isSubmitting,
          onPressed: isSubmitting ||
                  !hasSelectedDetails ||
                  statusItems.isEmpty
              ? null
              : onRegister,
        ),
      ],
    );
  }
}
