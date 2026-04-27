/// App theme primitives used across the UI.
///
/// Contains shared color, spacing, radius, shadow and text style
/// constants so widgets can remain visually consistent.
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4DB6AC);
  static const background = Color(0xFFF5F7F6);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF2E2E2E);
  static const textSecondary = Color(0xFF7A7A7A);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
}

class AppShadows {
  static const soft = BoxShadow(
    color: Colors.black12,
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}

class AppTextStyles {
  static const bodyPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodySecondary = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );
}
