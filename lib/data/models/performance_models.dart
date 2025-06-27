class PerformanceSummary {
  final int totalCalculations;
  final double averageTime;
  final double medianTime;
  final double maxTime;
  final double minTime;
  final int slowCalculations;
  final int fastCalculations;
  final double cacheHitRate;
  final double successRate;

  PerformanceSummary({
    required this.totalCalculations,
    required this.averageTime,
    required this.medianTime,
    required this.maxTime,
    required this.minTime,
    required this.slowCalculations,
    required this.fastCalculations,
    required this.cacheHitRate,
    required this.successRate,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      totalCalculations: json['total_calculations'] ?? 0,
      averageTime: (json['average_time_seconds'] ?? 0).toDouble(),
      medianTime: (json['median_time_seconds'] ?? 0).toDouble(),
      maxTime: (json['max_time_seconds'] ?? 0).toDouble(),
      minTime: (json['min_time_seconds'] ?? 0).toDouble(),
      slowCalculations: json['slow_calculations'] ?? 0,
      fastCalculations: json['fast_calculations'] ?? 0,
      cacheHitRate: (json['cache_hit_rate'] ?? 0).toDouble(),
      successRate: (json['success_rate'] ?? 0).toDouble(),
    );
  }

  String get averageTimeFormatted {
    if (averageTime < 1) return '${(averageTime * 1000).toStringAsFixed(0)}ms';
    return '${averageTime.toStringAsFixed(2)}s';
  }

  String get cacheHitRateFormatted =>
      '${(cacheHitRate * 100).toStringAsFixed(1)}%';
  String get successRateFormatted =>
      '${(successRate * 100).toStringAsFixed(1)}%';
}

class CacheStats {
  final int hits;
  final int misses;
  final int totalRequests;
  final double hitRate;
  final int currentSize;
  final int maxSize;
  final Map<String, int>? topFunctions;

  CacheStats({
    required this.hits,
    required this.misses,
    required this.totalRequests,
    required this.hitRate,
    required this.currentSize,
    required this.maxSize,
    this.topFunctions,
  });

  factory CacheStats.fromJson(Map<String, dynamic> json) {
    return CacheStats(
      hits: json['hits'] ?? 0,
      misses: json['misses'] ?? 0,
      totalRequests: json['total_requests'] ?? 0,
      hitRate: (json['hit_rate'] ?? 0).toDouble(),
      currentSize: json['current_size'] ?? 0,
      maxSize: json['max_size'] ?? 0,
      topFunctions:
          json['top_functions'] != null
              ? Map<String, int>.from(json['top_functions'])
              : null,
    );
  }

  String get hitRateFormatted => '${(hitRate * 100).toStringAsFixed(1)}%';
  String get usageFormatted => '$currentSize/$maxSize';
  double get usagePercentage => maxSize > 0 ? currentSize / maxSize : 0.0;
}

class PrecisionAnalysis {
  final double averageError;
  final double maxError;
  final double minError;
  final int highPrecisionCalculations;
  final int lowPrecisionCalculations;
  final List<String>? problematicFunctions;

  PrecisionAnalysis({
    required this.averageError,
    required this.maxError,
    required this.minError,
    required this.highPrecisionCalculations,
    required this.lowPrecisionCalculations,
    this.problematicFunctions,
  });

  factory PrecisionAnalysis.fromJson(Map<String, dynamic> json) {
    return PrecisionAnalysis(
      averageError: (json['average_error'] ?? 0).toDouble(),
      maxError: (json['max_error'] ?? 0).toDouble(),
      minError: (json['min_error'] ?? 0).toDouble(),
      highPrecisionCalculations: json['high_precision_calculations'] ?? 0,
      lowPrecisionCalculations: json['low_precision_calculations'] ?? 0,
      problematicFunctions:
          json['problematic_functions'] != null
              ? List<String>.from(json['problematic_functions'])
              : null,
    );
  }

  String get averageErrorFormatted {
    if (averageError < 1e-10) return '< 1e-10';
    return averageError.toStringAsExponential(2);
  }

  String get qualityLevel {
    if (averageError < 1e-12) return 'Excelente';
    if (averageError < 1e-9) return 'Muito Boa';
    if (averageError < 1e-6) return 'Boa';
    if (averageError < 1e-3) return 'Regular';
    return 'Baixa';
  }
}

class SecurityStats {
  final int totalRequests;
  final int blockedRequests;
  final int suspiciousRequests;
  final Map<String, int>? topBlockedIps;
  final Map<String, int>? attackTypes;
  final double threatLevel;

  SecurityStats({
    required this.totalRequests,
    required this.blockedRequests,
    required this.suspiciousRequests,
    this.topBlockedIps,
    this.attackTypes,
    required this.threatLevel,
  });

  factory SecurityStats.fromJson(Map<String, dynamic> json) {
    return SecurityStats(
      totalRequests: json['total_requests'] ?? 0,
      blockedRequests: json['blocked_requests'] ?? 0,
      suspiciousRequests: json['suspicious_requests'] ?? 0,
      topBlockedIps:
          json['top_blocked_ips'] != null
              ? Map<String, int>.from(json['top_blocked_ips'])
              : null,
      attackTypes:
          json['attack_types'] != null
              ? Map<String, int>.from(json['attack_types'])
              : null,
      threatLevel: (json['threat_level'] ?? 0).toDouble(),
    );
  }

  double get blockRate =>
      totalRequests > 0 ? blockedRequests / totalRequests : 0.0;
  String get blockRateFormatted => '${(blockRate * 100).toStringAsFixed(2)}%';

  String get threatLevelDescription {
    if (threatLevel < 0.2) return 'Baixo';
    if (threatLevel < 0.5) return 'Moderado';
    if (threatLevel < 0.8) return 'Alto';
    return 'Crítico';
  }
}

class PerformanceSummaryResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final PerformanceSummary? summary;

  PerformanceSummaryResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.summary,
  });

  factory PerformanceSummaryResponse.fromJson(Map<String, dynamic> json) {
    return PerformanceSummaryResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      summary:
          json['summary'] != null
              ? PerformanceSummary.fromJson(json['summary'])
              : null,
    );
  }
}

class CacheStatsResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final CacheStats? stats;

  CacheStatsResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.stats,
  });

  factory CacheStatsResponse.fromJson(Map<String, dynamic> json) {
    return CacheStatsResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      stats: json['stats'] != null ? CacheStats.fromJson(json['stats']) : null,
    );
  }
}

class PrecisionAnalysisResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final PrecisionAnalysis? analysis;

  PrecisionAnalysisResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.analysis,
  });

  factory PrecisionAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return PrecisionAnalysisResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      analysis:
          json['analysis'] != null
              ? PrecisionAnalysis.fromJson(json['analysis'])
              : null,
    );
  }
}

class SecurityStatsResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final SecurityStats? stats;

  SecurityStatsResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.stats,
  });

  factory SecurityStatsResponse.fromJson(Map<String, dynamic> json) {
    return SecurityStatsResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      stats:
          json['stats'] != null ? SecurityStats.fromJson(json['stats']) : null,
    );
  }
}

// Novos modelos para endpoints adicionais

class SlowCalculation {
  final String functionExpression;
  final double executionTime;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  SlowCalculation({
    required this.functionExpression,
    required this.executionTime,
    required this.timestamp,
    this.details,
  });

  factory SlowCalculation.fromJson(Map<String, dynamic> json) {
    return SlowCalculation(
      functionExpression: json['function_expression'] ?? '',
      executionTime: (json['execution_time'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      details: json['details'],
    );
  }

  String get executionTimeFormatted {
    if (executionTime < 1) {
      return '${(executionTime * 1000).toStringAsFixed(0)}ms';
    }
    return '${executionTime.toStringAsFixed(2)}s';
  }
}

class PerformanceIssue {
  final String type;
  final String description;
  final String severity;
  final List<String> recommendations;
  final Map<String, dynamic>? details;

  PerformanceIssue({
    required this.type,
    required this.description,
    required this.severity,
    required this.recommendations,
    this.details,
  });

  factory PerformanceIssue.fromJson(Map<String, dynamic> json) {
    return PerformanceIssue(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'low',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      details: json['details'],
    );
  }

  bool get isHighSeverity => severity.toLowerCase() == 'high';
  bool get isMediumSeverity => severity.toLowerCase() == 'medium';
}

class SlowestCalculationsResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final List<SlowCalculation>? slowestCalculations;

  SlowestCalculationsResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.slowestCalculations,
  });

  factory SlowestCalculationsResponse.fromJson(Map<String, dynamic> json) {
    return SlowestCalculationsResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      slowestCalculations:
          json['slowest_calculations'] != null
              ? (json['slowest_calculations'] as List)
                  .map((item) => SlowCalculation.fromJson(item))
                  .toList()
              : null,
    );
  }
}

class PerformanceIssuesResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final List<PerformanceIssue>? issues;
  final List<String>? recommendations;

  PerformanceIssuesResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.issues,
    this.recommendations,
  });

  factory PerformanceIssuesResponse.fromJson(Map<String, dynamic> json) {
    return PerformanceIssuesResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      issues:
          json['issues'] != null
              ? (json['issues'] as List)
                  .map((item) => PerformanceIssue.fromJson(item))
                  .toList()
              : null,
      recommendations:
          json['recommendations'] != null
              ? List<String>.from(json['recommendations'])
              : null,
    );
  }
}

class PerformanceExportResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final Map<String, dynamic>? metrics;
  final String? exportFormat;

  PerformanceExportResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.metrics,
    this.exportFormat,
  });

  factory PerformanceExportResponse.fromJson(Map<String, dynamic> json) {
    return PerformanceExportResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      metrics: json['metrics'],
      exportFormat: json['export_format'],
    );
  }
}

class PerformanceResetResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final String? message;
  final DateTime? timestamp;

  PerformanceResetResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.message,
    this.timestamp,
  });

  factory PerformanceResetResponse.fromJson(Map<String, dynamic> json) {
    return PerformanceResetResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      message: json['message'],
      timestamp:
          json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'])
              : null,
    );
  }
}
