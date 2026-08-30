import 'package:flutter/material.dart';

import '../tk_text_field.dart';

class TkDateField extends StatelessWidget {
  const TkDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.onTap,
    this.width = 150,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TkTextField(
            label: label,
            readOnly: true,
            controller: controller,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
        ),
      ),
    );
  }
}
