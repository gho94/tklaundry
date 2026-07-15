import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 목록 그리드용 흰색 패널 (테두리·모서리 라운드).
class TkGridPanel extends StatelessWidget {
  const TkGridPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
