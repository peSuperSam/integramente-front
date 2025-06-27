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
  String get usageFormatted => '${currentSize}/${maxSize}';
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
