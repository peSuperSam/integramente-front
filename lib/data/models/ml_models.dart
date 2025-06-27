class MLAnalysisRequest {
  final String funcao;
  final Map<String, dynamic>? opcoes;

  MLAnalysisRequest({required this.funcao, this.opcoes});

  Map<String, dynamic> toJson() {
    return {
      'funcao': funcao,
      if (opcoes != null) ...opcoes!,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class MLIntegrationDifficultyRequest {
  final String funcao;
  final List<double>? interval;

  MLIntegrationDifficultyRequest({required this.funcao, this.interval});

  Map<String, dynamic> toJson() {
    return {
      'funcao': funcao,
      if (interval != null) 'interval': interval,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class MLComputationTimeRequest {
  final String funcao;
  final int? resolution;
  final List<double>? interval;

  MLComputationTimeRequest({
    required this.funcao,
    this.resolution,
    this.interval,
  });

  Map<String, dynamic> toJson() {
    return {
      'funcao': funcao,
      if (resolution != null) 'resolution': resolution,
      if (interval != null) 'interval': interval,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class MLOptimalResolutionRequest {
  final String funcao;
  final List<double>? interval;
  final double? tolerancia;

  MLOptimalResolutionRequest({
    required this.funcao,
    this.interval,
    this.tolerancia,
  });

  Map<String, dynamic> toJson() {
    return {
      'funcao': funcao,
      if (interval != null) 'interval': interval,
      if (tolerancia != null) 'tolerancia': tolerancia,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class FunctionCharacteristics {
  final bool hasRootsSingularities;
  final bool isOscillatory;
  final bool isMonotonic;
  final bool isEven;
  final bool isOdd;
  final bool isPeriodic;
  final double complexityScore;
  final double maxGradient;
  final double curvatureIndex;

  FunctionCharacteristics({
    required this.hasRootsSingularities,
    required this.isOscillatory,
    required this.isMonotonic,
    required this.isEven,
    required this.isOdd,
    required this.isPeriodic,
    required this.complexityScore,
    required this.maxGradient,
    required this.curvatureIndex,
  });

  factory FunctionCharacteristics.fromJson(Map<String, dynamic> json) {
    return FunctionCharacteristics(
      hasRootsSingularities: json['has_roots_singularities'] ?? false,
      isOscillatory: json['is_oscillatory'] ?? false,
      isMonotonic: json['is_monotonic'] ?? false,
      isEven: json['is_even'] ?? false,
      isOdd: json['is_odd'] ?? false,
      isPeriodic: json['is_periodic'] ?? false,
      complexityScore: (json['complexity_score'] ?? 0).toDouble(),
      maxGradient: (json['max_gradient'] ?? 0).toDouble(),
      curvatureIndex: (json['curvature_index'] ?? 0).toDouble(),
    );
  }
}

class MLAnalysisResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final FunctionCharacteristics? characteristics;
  final String? functionType;
  final double? difficultyScore;
  final double? estimatedTime;
  final int? optimalResolution;
  final List<String>? recommendations;
  final Map<String, dynamic>? additionalInfo;

  MLAnalysisResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.characteristics,
    this.functionType,
    this.difficultyScore,
    this.estimatedTime,
    this.optimalResolution,
    this.recommendations,
    this.additionalInfo,
  });

  factory MLAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return MLAnalysisResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      characteristics:
          json['characteristics'] != null
              ? FunctionCharacteristics.fromJson(json['characteristics'])
              : null,
      functionType: json['function_type'],
      difficultyScore: (json['difficulty_score'] ?? 0).toDouble(),
      estimatedTime: json['estimated_time_seconds']?.toDouble(),
      optimalResolution: json['optimal_resolution'],
      recommendations:
          json['recommendations'] != null
              ? List<String>.from(json['recommendations'])
              : null,
      additionalInfo: json['additional_info'],
    );
  }

  String get difficultyLevel {
    if (difficultyScore == null) return 'Desconhecido';
    if (difficultyScore! < 0.3) return 'Fácil';
    if (difficultyScore! < 0.6) return 'Médio';
    if (difficultyScore! < 0.8) return 'Difícil';
    return 'Muito Difícil';
  }

  String get estimatedTimeFormatted {
    if (estimatedTime == null) return 'Desconhecido';
    if (estimatedTime! < 1) return '< 1 segundo';
    if (estimatedTime! < 60)
      return '${estimatedTime!.toStringAsFixed(1)} segundos';
    return '${(estimatedTime! / 60).toStringAsFixed(1)} minutos';
  }
}

class MLIntegrationDifficultyResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final double? difficultyScore;
  final String? difficultyLevel;
  final List<String>? factors;

  MLIntegrationDifficultyResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.difficultyScore,
    this.difficultyLevel,
    this.factors,
  });

  factory MLIntegrationDifficultyResponse.fromJson(Map<String, dynamic> json) {
    return MLIntegrationDifficultyResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      difficultyScore: json['difficulty_score']?.toDouble(),
      difficultyLevel: json['difficulty_level'],
      factors:
          json['factors'] != null ? List<String>.from(json['factors']) : null,
    );
  }
}

class MLComputationTimeResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final double? estimatedTimeSeconds;
  final String? confidence;

  MLComputationTimeResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.estimatedTimeSeconds,
    this.confidence,
  });

  factory MLComputationTimeResponse.fromJson(Map<String, dynamic> json) {
    return MLComputationTimeResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      estimatedTimeSeconds: json['estimated_time_seconds']?.toDouble(),
      confidence: json['confidence'],
    );
  }

  String get estimatedTimeFormatted {
    if (estimatedTimeSeconds == null) return 'Desconhecido';
    if (estimatedTimeSeconds! < 1) return '< 1 segundo';
    if (estimatedTimeSeconds! < 60)
      return '${estimatedTimeSeconds!.toStringAsFixed(1)} segundos';
    return '${(estimatedTimeSeconds! / 60).toStringAsFixed(1)} minutos';
  }
}

class MLOptimalResolutionResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final int? optimalResolution;
  final String? reasoning;

  MLOptimalResolutionResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.optimalResolution,
    this.reasoning,
  });

  factory MLOptimalResolutionResponse.fromJson(Map<String, dynamic> json) {
    return MLOptimalResolutionResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      optimalResolution: json['optimal_resolution'],
      reasoning: json['reasoning'],
    );
  }
}

class MLModelInfo {
  final String name;
  final String version;
  final double accuracy;
  final String trainedOn;
  final Map<String, dynamic>? metadata;

  MLModelInfo({
    required this.name,
    required this.version,
    required this.accuracy,
    required this.trainedOn,
    this.metadata,
  });

  factory MLModelInfo.fromJson(Map<String, dynamic> json) {
    return MLModelInfo(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      trainedOn: json['trained_on'] ?? '',
      metadata: json['metadata'],
    );
  }
}

class MLModelInfoResponse {
  final bool sucesso;
  final String? erro;
  final DateTime calculadoEm;
  final List<MLModelInfo>? models;

  MLModelInfoResponse({
    required this.sucesso,
    this.erro,
    required this.calculadoEm,
    this.models,
  });

  factory MLModelInfoResponse.fromJson(Map<String, dynamic> json) {
    return MLModelInfoResponse(
      sucesso: json['sucesso'] ?? false,
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      models:
          json['models'] != null
              ? List<MLModelInfo>.from(
                json['models'].map((model) => MLModelInfo.fromJson(model)),
              )
              : null,
    );
  }
}
