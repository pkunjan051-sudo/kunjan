import 'package:flutter/material.dart';

/// Hyper-premium Cinema design system color palette
class AppColors {
  // Base Surface Void
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111726);
  static const Color surfaceContainer = Color(0xFF161E33);
  static const Color surfaceHigh = Color(0xFF1E2842);
  static const Color surfaceHighest = Color(0xFF2B3654);

  // Accents & Glows
  static const Color primary = Color(0xFFE50914); // Netflix Red Accent
  static const Color primaryGlow = Color(0xFFFF2E3B);
  static const Color primaryLight = Color(0xFFFFB3B6);
  static const Color secondary = Color(0xFFFFB95F); // Action Gold / Ratings
  static const Color secondaryDark = Color(0xFFEE9800);
  static const Color tertiary = Color(0xFF38BDF8); // Ambient Neon Blue

  // Text / Content Colors
  static const Color onBackground = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color outline = Color(0xFF334155);

  // Glassmorphic translucent overlays
  static const Color glassBackground = Color(0xD90F172A);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassCardBorder = Color(0x2BFF2E3B);

  // Status & Badges
  static const Color ratingGold = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Ambient Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE50914), Color(0xFFB9090B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x0AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
