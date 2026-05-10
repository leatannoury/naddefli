import 'package:flutter/material.dart';

/// Material 3 App Colors - Naddefli Design System
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0058BC);
  static const Color primaryContainer = Color(0xFF0070EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFEFCFF);

  // Secondary Colors
  static const Color secondary = Color(0xFF4C4ACA);
  static const Color secondaryContainer = Color(0xFF6664E4);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFFFFBFF);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF9E3D00);
  static const Color tertiaryContainer = Color(0xFFC64F00);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surface Colors
  static const Color surface = Color(0xFFF9F9FE);
  static const Color surfaceContainer = Color(0xFFEDEDF2);
  static const Color surfaceContainerLow = Color(0xFFF3F3F8);
  static const Color surfaceContainerHigh = Color(0xFFE8E8ED);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1F);
  static const Color onSurfaceVariant = Color(0xFF414755);

  // Error Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Outline
  static const Color outline = Color(0xFF717786);
  static const Color outlineVariant = Color(0xFFC1C6D7);

  // Legacy compatibility
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFB800);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color gray = Color(0xFF9CA3AF);
  static const Color darkGray = Color(0xFF6B7280);
}

/// App Styles & Spacing
class AppStyles {
  // Padding & Spacing (Material 3 scale)
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingBase = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double marginMobile = 20.0;

  // Border Radius (Material 3)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;

  // Text Styles - Typography System
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle headingMedium = headlineMedium;
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.02,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.27,
    letterSpacing: 0.5,
  );
}
