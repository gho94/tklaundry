import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF0D9488);
  static const primaryHover = Color(0xFF0F766E);
  static const primaryMuted = Color(0xFFCCFBF1);
  static const secondary = Color(0xFF334155);

  // Neutral
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral600 = Color(0xFF475569);
  static const neutral900 = Color(0xFF0F172A);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
  static const errorSurface = Color(0xFFFEF2F2);

  // Aliases (기존 위젯 호환)
  static const surface = neutral50;
  static const surfaceCard = neutral0;
  static const border = neutral200;
  static const textPrimary = neutral900;
  static const textSecondary = neutral600;
  static const primaryDark = primaryHover;
}
