import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TkPageScaffold extends StatelessWidget {
  const TkPageScaffold({
    super.key,
    required this.title,
    this.actions,
    this.toolbar,
    required this.body,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? toolbar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (toolbar != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: toolbar,
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
