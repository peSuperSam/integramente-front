import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SnackBarUtils {
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _longDuration = Duration(seconds: 5);

  /// Mostra uma mensagem de sucesso
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message,
      icon: Icons.check_circle,
      backgroundColor: AppColors.success,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Mostra uma mensagem de erro
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message,
      icon: Icons.error,
      backgroundColor: AppColors.error,
      duration: duration ?? _longDuration,
    );
  }

  /// Mostra uma mensagem de aviso
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message,
      icon: Icons.warning,
      backgroundColor: AppColors.warning,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Mostra uma mensagem informativa
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message,
      icon: Icons.info,
      backgroundColor: AppColors.primary,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Mostra uma mensagem de carregamento
  static void showLoading(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: null,
      backgroundColor: AppColors.backgroundCard,
      duration: const Duration(seconds: 30), // Longa duração para loading
      showProgress: true,
    );
  }

  /// Método privado para criar e exibir o SnackBar
  static void _showSnackBar(
    BuildContext context,
    String message, {
    IconData? icon,
    required Color backgroundColor,
    required Duration duration,
    bool showProgress = false,
  }) {
    // Remove qualquer SnackBar anterior
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (showProgress) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ] else if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
          ],
          if (icon != null || showProgress) const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Remove qualquer SnackBar atual
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Mostra uma mensagem personalizada com ação
  static void showActionMessage(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onActionPressed,
    IconData? icon,
    Color? backgroundColor,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
      behavior: SnackBarBehavior.floating,
      duration: duration ?? _longDuration,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      action: SnackBarAction(
        label: actionLabel,
        textColor: Colors.white,
        onPressed: onActionPressed,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Mostra uma mensagem de cálculo iniciado
  static void showCalculationStarted(
    BuildContext context,
    String calculationType,
    String expression,
  ) {
    showLoading(context, 'Calculando $calculationType: $expression...');
  }

  /// Mostra uma mensagem de cálculo concluído
  static void showCalculationCompleted(
    BuildContext context,
    String calculationType,
  ) {
    showSuccess(context, '$calculationType calculado com sucesso!');
  }

  /// Mostra uma mensagem de validação de função
  static void showValidationError(BuildContext context, String fieldName) {
    showError(context, '$fieldName não pode estar vazio ou é inválido');
  }

  /// Mostra uma mensagem de conectividade
  static void showConnectivityInfo(BuildContext context, bool isOnline) {
    if (isOnline) {
      showSuccess(context, 'Conectado ao servidor! Usando cálculos precisos.');
    } else {
      showWarning(
        context,
        'Offline. Usando cálculos locais aproximados.',
        duration: _longDuration,
      );
    }
  }
}
