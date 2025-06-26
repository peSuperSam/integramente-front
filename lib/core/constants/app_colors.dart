import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Tons de azul científico
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary Colors - Tons de verde para matemática
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);

  // Accent Colors - Cores de destaque
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  // Background Colors - Tema escuro moderno
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color backgroundCard = Color(0xFF1A1A1A);
  static const Color backgroundSurface = Color(0xFF2A2A2A);
  static const Color backgroundElevated = Color(0xFF3A3A3A);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textTertiary = Color(0xFF78909C);
  static const Color textDisabled = Color(0xFF455A64);

  // Graph Colors - Paleta para gráficos matemáticos
  static const Color graphFunction = Color(0xFF2196F3);
  static const Color graphArea = Color(0x332196F3);
  static const Color graphGrid = Color(0xFF37474F);
  static const Color graphAxis = Color(0xFF607D8B);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Glass Effect Colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, backgroundCard],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundCard, backgroundSurface],
  );

  // Mathematical Colors - Cores específicas para elementos matemáticos
  static const Color integralColor = Color(0xFF9C27B0);
  static const Color derivativeColor = Color(0xFF673AB7);
  static const Color functionColor = Color(0xFF3F51B5);
  static const Color variableColor = Color(0xFF009688);
  static const Color constantColor = Color(0xFF795548);
}
