import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';

class TkAsyncErrorBody extends StatelessWidget {
  const TkAsyncErrorBody({
    super.key,
    required this.error,
    this.fallbackMessage = '데이터를 불러오지 못했습니다.',
  });

  final Object error;
  final String fallbackMessage;

  @override
  Widget build(BuildContext context) {
    final apiError = error is ApiException ? error as ApiException : null;
    final message = apiError?.message ?? fallbackMessage;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    height: 1.4,
                  ),
            ),
            if (apiError?.traceId != null) ...[
              const SizedBox(height: 8),
              Text(
                'traceId: ${apiError!.traceId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
