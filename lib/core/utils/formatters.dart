import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Formatters {
  static NumberFormat? _decimalFormat;
  static NumberFormat? _scientificFormat;
  static DateFormat? _dateFormat;

  // Getters com inicialização lazy e fallback
  static NumberFormat get decimalFormat {
    _decimalFormat ??= _createSafeNumberFormat('#,##0.####');
    return _decimalFormat!;
  }

  static NumberFormat get scientificFormat {
    _scientificFormat ??= _createSafeScientificFormat();
    return _scientificFormat!;
  }

  static DateFormat get dateFormat {
    _dateFormat ??= _createSafeDateFormat();
    return _dateFormat!;
  }

  // Criadores seguros de formatters
  static NumberFormat _createSafeNumberFormat(String pattern) {
    try {
      return NumberFormat(pattern, 'pt_BR');
    } catch (e) {
      try {
        return NumberFormat(pattern, 'en_US');
      } catch (e) {
        return NumberFormat(pattern);
      }
    }
  }

  static NumberFormat _createSafeScientificFormat() {
    try {
      return NumberFormat.scientificPattern('pt_BR');
    } catch (e) {
      try {
        return NumberFormat.scientificPattern('en_US');
      } catch (e) {
        return NumberFormat.scientificPattern();
      }
    }
  }

  static DateFormat _createSafeDateFormat() {
    try {
      return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    } catch (e) {
      try {
        return DateFormat('MM/dd/yyyy HH:mm', 'en_US');
      } catch (e) {
        return DateFormat('yyyy-MM-dd HH:mm');
      }
    }
  }

  /// Formata um número decimal com até 4 casas decimais
  static String formatDecimal(double value) {
    try {
      if (value.abs() > 1e6 || (value.abs() < 1e-3 && value != 0)) {
        return scientificFormat.format(value);
      }
      return decimalFormat.format(value);
    } catch (e) {
      // Fallback simples se a formatação falhar
      if (value.abs() > 1e6 || (value.abs() < 1e-3 && value != 0)) {
        return value.toStringAsExponential(3);
      }
      return value.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
    }
  }

  /// Formata uma data e hora
  static String formatDateTime(DateTime dateTime) {
    try {
      return dateFormat.format(dateTime);
    } catch (e) {
      // Fallback para formato ISO se a formatação falhar
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Formata uma função matemática para exibição
  static String formatMathFunction(String function) {
    return function
        .replaceAll('*', '·')
        .replaceAll('^2', '²')
        .replaceAll('^3', '³')
        .replaceAll('^4', '⁴')
        .replaceAll('^5', '⁵')
        .replaceAll('sqrt', '√')
        .replaceAll('pi', 'π')
        .replaceAll('inf', '∞');
  }

  /// Converte função para formato LaTeX
  static String toLatex(String function) {
    return function
        .replaceAll('^', '^{')
        .replaceAll('sqrt(', '\\sqrt{')
        .replaceAll('sin(', '\\sin(')
        .replaceAll('cos(', '\\cos(')
        .replaceAll('tan(', '\\tan(')
        .replaceAll('log(', '\\log(')
        .replaceAll('ln(', '\\ln(')
        .replaceAll('pi', '\\pi')
        .replaceAll('*', '\\cdot ');
  }

  /// Formata um intervalo [a, b]
  static String formatInterval(double a, double b) {
    return '[${formatDecimal(a)}, ${formatDecimal(b)}]';
  }

  /// Trunca texto longo com reticências
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formata duração em formato legível
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Reseta os formatters (útil para mudanças de locale)
  static void resetFormatters() {
    _decimalFormat = null;
    _scientificFormat = null;
    _dateFormat = null;
  }
}

/// Utilitário para SnackBars centralizadas
class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
