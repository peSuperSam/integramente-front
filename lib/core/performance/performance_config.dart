import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class PerformanceConfig {
  static bool _isInitialized = false;
  static bool _performanceMonitoringEnabled = false;

  // Configurações de animação baseadas na performance do dispositivo
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 400);

  // Configurações de debounce para inputs
  static const Duration inputDebounce = Duration(milliseconds: 300);
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Configurações de cache
  static const int maxHistoricoItems = 100;
  static const int maxCacheSize = 50;

  // Otimizações de renderização
  static const double maxScrollPhysics = 4000.0;
  static const int maxListViewItems = 50;

  // Configurações de rede
  static const Duration networkTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;

  // Configurações de performance avançadas
  static const int gcThreshold = 64 * 1024 * 1024; // 64MB
  static const Duration memoryCheckInterval = Duration(minutes: 5);
  static const int maxObjectPoolSize = 100;

  /// Inicializa as configurações de performance
  static void initialize() {
    if (_isInitialized) return;

    _performanceMonitoringEnabled = kDebugMode;
    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('🔧 PerformanceConfig inicializado');
      debugPrint('📊 Monitoramento: $_performanceMonitoringEnabled');
      debugPrint('🎨 Animações reduzidas: $reduceAnimations');
    }
  }

  /// Se o monitoramento de performance está habilitado
  static bool get enablePerformanceMonitoring => _performanceMonitoringEnabled;

  /// Se foi inicializado
  static bool get isInitialized => _isInitialized;

  // Detectar se deve usar animações reduzidas
  static bool get reduceAnimations =>
      WidgetsBinding.instance.accessibilityFeatures.reduceMotion;

  // Duração de animação adaptativa
  static Duration get adaptiveAnimationDuration {
    if (reduceAnimations) return Duration.zero;
    if (kDebugMode) return fastAnimationDuration;
    return mediumAnimationDuration;
  }

  /// Configurações de animação baseadas no dispositivo
  static Duration getAnimationDuration({
    required bool isHeavyOperation,
    Duration? customDuration,
  }) {
    if (customDuration != null) return customDuration;
    if (reduceAnimations) return Duration.zero;

    if (isHeavyOperation) {
      return slowAnimationDuration;
    }

    return adaptiveAnimationDuration;
  }

  /// Configurações de debounce adaptativo
  static Duration getDebounceTime({
    bool isSearchField = false,
    bool isHeavyOperation = false,
  }) {
    if (isSearchField) return searchDebounce;
    if (isHeavyOperation) return const Duration(milliseconds: 800);
    return inputDebounce;
  }

  /// Limita o número de itens em listas baseado na performance
  static int getOptimalListSize({
    int requestedSize = 50,
    bool isComplexItem = false,
  }) {
    if (isComplexItem) {
      return requestedSize > 20 ? 20 : requestedSize;
    }
    return requestedSize > maxListViewItems ? maxListViewItems : requestedSize;
  }

  /// Configurações de cache adaptativo
  static Map<String, dynamic> getCacheConfig({required String cacheType}) {
    switch (cacheType) {
      case 'images':
        return {'maxSize': 20, 'ttl': const Duration(hours: 2)};
      case 'api_responses':
        return {'maxSize': 15, 'ttl': const Duration(minutes: 10)};
      case 'user_preferences':
        return {'maxSize': 5, 'ttl': const Duration(days: 1)};
      default:
        return {'maxSize': 10, 'ttl': const Duration(minutes: 30)};
    }
  }

  // Configurar vibração leve para feedback
  static void lightImpact() {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }
  }

  // Configurar vibração de seleção
  static void selectionClick() {
    if (!kIsWeb) {
      HapticFeedback.selectionClick();
    }
  }

  /// Feedback háptico adaptativo
  static void adaptiveHapticFeedback({required String actionType}) {
    if (kIsWeb) return;

    switch (actionType) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      case 'selection':
        HapticFeedback.selectionClick();
        break;
      default:
        HapticFeedback.lightImpact();
    }
  }

  /// Reset das configurações
  static void reset() {
    _isInitialized = false;
    _performanceMonitoringEnabled = false;
  }

  /// Detecta o nível de performance do dispositivo
  static PerformanceLevel get devicePerformanceLevel {
    // Estimativa simplificada baseada em configurações
    if (reduceAnimations) return PerformanceLevel.low;
    if (kDebugMode) return PerformanceLevel.medium;
    return PerformanceLevel.high;
  }

  /// Configurações otimizadas baseadas no nível de performance
  static bool get shouldUseComplexAnimations =>
      devicePerformanceLevel == PerformanceLevel.high;

  static bool get shouldUseShadows =>
      devicePerformanceLevel != PerformanceLevel.low;

  static bool get shouldUseGradients =>
      devicePerformanceLevel != PerformanceLevel.low;

  /// Relatório de configurações
  static Map<String, dynamic> getConfigReport() {
    return {
      'initialized': _isInitialized,
      'performance_monitoring': _performanceMonitoringEnabled,
      'reduce_animations': reduceAnimations,
      'animation_duration_ms': adaptiveAnimationDuration.inMilliseconds,
      'input_debounce_ms': inputDebounce.inMilliseconds,
      'max_list_items': maxListViewItems,
      'max_cache_size': maxCacheSize,
      'debug_mode': kDebugMode,
      'performance_level': devicePerformanceLevel.toString(),
      'complex_animations': shouldUseComplexAnimations,
      'shadows_enabled': shouldUseShadows,
      'gradients_enabled': shouldUseGradients,
    };
  }
}

enum PerformanceLevel { low, medium, high }
