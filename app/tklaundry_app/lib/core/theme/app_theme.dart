import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_layout.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final textTheme = AppTypography.textTheme();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.neutral0,
      surface: AppColors.neutral0,
      onSurface: AppColors.neutral900,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.neutral0,
        foregroundColor: AppColors.neutral900,
        titleTextStyle: textTheme.titleMedium,
        toolbarHeight: AppLayout.topBarHeight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutral0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
          side: const BorderSide(color: AppColors.neutral200),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: textTheme.bodySmall,
        hintStyle: textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(80, 40),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.neutral0,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: AppColors.neutral0.withValues(alpha: 0.8),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(80, 40),
          foregroundColor: AppColors.neutral900,
          side: const BorderSide(color: AppColors.neutral200),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
        headingTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.neutral600,
          letterSpacing: 0.5,
        ),
        dataTextStyle: textTheme.bodyMedium,
        dataRowMinHeight: AppLayout.tableRowHeight,
        dataRowMaxHeight: AppLayout.tableRowHeight,
        dividerThickness: 1,
        columnSpacing: 16,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.neutral0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
