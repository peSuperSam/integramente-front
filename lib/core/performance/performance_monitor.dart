import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Dados de frame
class FrameData {
  final DateTime timestamp;
  final Duration frameDuration;
  final bool isJank;

  FrameData({
    required this.timestamp,
    required this.frameDuration,
    required this.isJank,
  });

  double get fps => 1000 / frameDuration.inMilliseconds;
}

/// Dados de memória
class MemoryData {
  final DateTime timestamp;
  final int usedMemoryMB;
  final int totalMemoryMB;

  MemoryData({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.totalMemoryMB,
  });

  double get memoryUsagePercentage => usedMemoryMB / totalMemoryMB * 100;
}

/// Dados de operação
class OperationData {
  final String name;
  int callCount = 0;
  Duration totalDuration = Duration.zero;
  Duration maxDuration = Duration.zero;
  Duration minDuration = const Duration(days: 1);

  OperationData(this.name);

  double get averageDurationMs =>
      callCount > 0 ? totalDuration.inMilliseconds / callCount : 0;
}

/// Monitor de performance em tempo real
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal() {
    _startMonitoring();
  }

  final Queue<FrameData> _frameHistory = Queue<FrameData>();
  final Queue<MemoryData> _memoryHistory = Queue<MemoryData>();
  final Map<String, OperationData> _operationStats = {};

  Timer? _memoryTimer;
  static const int _maxHistoryLength = 100;
  static const int _targetFPS = 60;
  static const Duration _memoryCheckInterval = Duration(seconds: 5);

  void _startMonitoring() {
    if (!kDebugMode) return;

    // Monitor de frames
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);

    // Monitor de memória
    _memoryTimer = Timer.periodic(_memoryCheckInterval, _checkMemoryUsage);
  }

  void _onFrame(Duration timestamp) {
    final now = DateTime.now();
    final frameDuration = timestamp;
    final isJank = frameDuration.inMilliseconds > (1000 / _targetFPS * 1.5);

    _frameHistory.add(
      FrameData(timestamp: now, frameDuration: frameDuration, isJank: isJank),
    );

    if (_frameHistory.length > _maxHistoryLength) {
      _frameHistory.removeFirst();
    }

    // Agenda próximo frame
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _checkMemoryUsage(Timer timer) {
    // Simulação de dados de memória (em produção, usar dart:developer)
    final usedMemory = _estimateMemoryUsage();
    _memoryHistory.add(
      MemoryData(
        timestamp: DateTime.now(),
        usedMemoryMB: usedMemory,
        totalMemoryMB: 512, // Estimativa
      ),
    );

    if (_memoryHistory.length > _maxHistoryLength) {
      _memoryHistory.removeFirst();
    }
  }

  int _estimateMemoryUsage() {
    // Estimativa básica de uso de memória
    return (50 + (_frameHistory.length * 0.1) + (_operationStats.length * 0.5))
        .round();
  }

  /// Marca início de operação para medir performance
  Stopwatch startOperation(String operationName) {
    final stopwatch = Stopwatch()..start();
    return stopwatch;
  }

  /// Marca fim de operação e registra estatísticas
  void endOperation(String operationName, Stopwatch stopwatch) {
    stopwatch.stop();
    final duration = stopwatch.elapsed;

    final operation = _operationStats.putIfAbsent(
      operationName,
      () => OperationData(operationName),
    );

    operation.callCount++;
    operation.totalDuration += duration;

    if (duration > operation.maxDuration) {
      operation.maxDuration = duration;
    }
    if (duration < operation.minDuration) {
      operation.minDuration = duration;
    }
  }

  /// Wrapper para medir performance de função
  Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = startOperation(operationName);
    try {
      final result = await operation();
      endOperation(operationName, stopwatch);
      return result;
    } catch (e) {
      endOperation(operationName, stopwatch);
      rethrow;
    }
  }

  /// Wrapper síncrono para medir performance
  T measure<T>(String operationName, T Function() operation) {
    final stopwatch = startOperation(operationName);
    try {
      final result = operation();
      endOperation(operationName, stopwatch);
      return result;
    } catch (e) {
      endOperation(operationName, stopwatch);
      rethrow;
    }
  }

  /// Relatório de performance
  Map<String, dynamic> getPerformanceReport() {
    final recentFrames = _frameHistory.take(30).toList();
    final recentMemory = _memoryHistory.take(10).toList();

    final averageFPS =
        recentFrames.isNotEmpty
            ? recentFrames.map((f) => f.fps).reduce((a, b) => a + b) /
                recentFrames.length
            : 0.0;

    final jankPercentage =
        recentFrames.isNotEmpty
            ? recentFrames.where((f) => f.isJank).length /
                recentFrames.length *
                100
            : 0.0;

    final currentMemory =
        recentMemory.isNotEmpty ? recentMemory.last.usedMemoryMB : 0;

    return {
      'fps': {
        'average': averageFPS.toStringAsFixed(1),
        'target': _targetFPS,
        'jank_percentage': jankPercentage.toStringAsFixed(1),
      },
      'memory': {'current_mb': currentMemory, 'usage_trend': _getMemoryTrend()},
      'operations':
          _operationStats.values
              .map(
                (op) => {
                  'name': op.name,
                  'calls': op.callCount,
                  'avg_duration_ms': op.averageDurationMs.toStringAsFixed(2),
                  'max_duration_ms': op.maxDuration.inMilliseconds,
                },
              )
              .toList(),
      'recommendations': _generateRecommendations(),
    };
  }

  String _getMemoryTrend() {
    if (_memoryHistory.length < 2) return 'stable';

    final historyList = _memoryHistory.toList();
    final recent =
        historyList.length >= 5
            ? historyList.sublist(historyList.length - 5)
            : historyList;
    final older =
        historyList.length >= 10
            ? historyList.sublist(
              historyList.length - 10,
              historyList.length - 5,
            )
            : <MemoryData>[];

    if (recent.isEmpty || older.isEmpty) return 'stable';

    final recentAvg =
        recent.map((m) => m.usedMemoryMB).reduce((a, b) => a + b) /
        recent.length;
    final olderAvg =
        older.map((m) => m.usedMemoryMB).reduce((a, b) => a + b) / older.length;

    if (recentAvg > olderAvg * 1.1) return 'increasing';
    if (recentAvg < olderAvg * 0.9) return 'decreasing';
    return 'stable';
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];

    final recentFrames = _frameHistory.take(30);
    final jankCount = recentFrames.where((f) => f.isJank).length;

    if (jankCount > 5) {
      recommendations.add(
        'Alto número de frames com jank detectado. Considere otimizar animações.',
      );
    }

    final slowOperations =
        _operationStats.values
            .where((op) => op.averageDurationMs > 100)
            .toList();

    if (slowOperations.isNotEmpty) {
      recommendations.add(
        'Operações lentas detectadas: ${slowOperations.map((op) => op.name).join(', ')}',
      );
    }

    if (_getMemoryTrend() == 'increasing') {
      recommendations.add(
        'Uso de memória crescente detectado. Verificar vazamentos.',
      );
    }

    return recommendations;
  }

  /// Para debug - imprime relatório no console
  void printReport() {
    if (!kDebugMode) return;

    final report = getPerformanceReport();
    debugPrint('📊 === RELATÓRIO DE PERFORMANCE ===');
    debugPrint('🎯 FPS Médio: ${report['fps']['average']}');
    debugPrint('⚡ Jank: ${report['fps']['jank_percentage']}%');
    debugPrint(
      '💾 Memória: ${report['memory']['current_mb']}MB (${report['memory']['usage_trend']})',
    );

    final operations = report['operations'] as List;
    if (operations.isNotEmpty) {
      debugPrint('⏱️ Operações mais lentas:');
      operations.take(3).forEach((op) {
        debugPrint('   ${op['name']}: ${op['avg_duration_ms']}ms');
      });
    }

    final recommendations = report['recommendations'] as List<String>;
    if (recommendations.isNotEmpty) {
      debugPrint('💡 Recomendações:');
      for (final rec in recommendations) {
        debugPrint('   • $rec');
      }
    }
    debugPrint('================================');
  }

  void dispose() {
    _memoryTimer?.cancel();
    _frameHistory.clear();
    _memoryHistory.clear();
    _operationStats.clear();
  }
}
