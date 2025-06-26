class UserPreferences {
  final bool animacoesHabilitadas;
  final bool notificacoesHabilitadas;
  final String tema;
  final String formatoNumero;
  final double intervaloDefaultA;
  final double intervaloDefaultB;
  final int resolucaoGrafico;
  final String linguagem;

  const UserPreferences({
    this.animacoesHabilitadas = true,
    this.notificacoesHabilitadas = true,
    this.tema = 'escuro',
    this.formatoNumero = 'decimal',
    this.intervaloDefaultA = 0.0,
    this.intervaloDefaultB = 1.0,
    this.resolucaoGrafico = 1000,
    this.linguagem = 'pt_BR',
  });

  // Factory constructor para criar instância padrão
  factory UserPreferences.padrao() {
    return const UserPreferences();
  }

  // Factory constructor para criar a partir de JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      animacoesHabilitadas: json['animacoes'] ?? true,
      notificacoesHabilitadas: json['notificacoes'] ?? true,
      tema: json['tema'] ?? 'escuro',
      formatoNumero: json['formatoNumero'] ?? 'decimal',
      intervaloDefaultA: (json['intervaloDefaultA'] ?? 0.0).toDouble(),
      intervaloDefaultB: (json['intervaloDefaultB'] ?? 1.0).toDouble(),
      resolucaoGrafico: json['resolucaoGrafico'] ?? 1000,
      linguagem: json['linguagem'] ?? 'pt_BR',
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'animacoes': animacoesHabilitadas,
      'notificacoes': notificacoesHabilitadas,
      'tema': tema,
      'formatoNumero': formatoNumero,
      'intervaloDefaultA': intervaloDefaultA,
      'intervaloDefaultB': intervaloDefaultB,
      'resolucaoGrafico': resolucaoGrafico,
      'linguagem': linguagem,
    };
  }

  // Método copyWith para criar cópias modificadas
  UserPreferences copyWith({
    bool? animacoesHabilitadas,
    bool? notificacoesHabilitadas,
    String? tema,
    String? formatoNumero,
    double? intervaloDefaultA,
    double? intervaloDefaultB,
    int? resolucaoGrafico,
    String? linguagem,
  }) {
    return UserPreferences(
      animacoesHabilitadas: animacoesHabilitadas ?? this.animacoesHabilitadas,
      notificacoesHabilitadas:
          notificacoesHabilitadas ?? this.notificacoesHabilitadas,
      tema: tema ?? this.tema,
      formatoNumero: formatoNumero ?? this.formatoNumero,
      intervaloDefaultA: intervaloDefaultA ?? this.intervaloDefaultA,
      intervaloDefaultB: intervaloDefaultB ?? this.intervaloDefaultB,
      resolucaoGrafico: resolucaoGrafico ?? this.resolucaoGrafico,
      linguagem: linguagem ?? this.linguagem,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPreferences &&
        other.animacoesHabilitadas == animacoesHabilitadas &&
        other.notificacoesHabilitadas == notificacoesHabilitadas &&
        other.tema == tema &&
        other.formatoNumero == formatoNumero &&
        other.intervaloDefaultA == intervaloDefaultA &&
        other.intervaloDefaultB == intervaloDefaultB &&
        other.resolucaoGrafico == resolucaoGrafico &&
        other.linguagem == linguagem;
  }

  @override
  int get hashCode {
    return Object.hash(
      animacoesHabilitadas,
      notificacoesHabilitadas,
      tema,
      formatoNumero,
      intervaloDefaultA,
      intervaloDefaultB,
      resolucaoGrafico,
      linguagem,
    );
  }

  @override
  String toString() {
    return 'UserPreferences('
        'animacoesHabilitadas: $animacoesHabilitadas, '
        'notificacoesHabilitadas: $notificacoesHabilitadas, '
        'tema: $tema, '
        'formatoNumero: $formatoNumero, '
        'intervaloDefaultA: $intervaloDefaultA, '
        'intervaloDefaultB: $intervaloDefaultB, '
        'resolucaoGrafico: $resolucaoGrafico, '
        'linguagem: $linguagem'
        ')';
  }

  // Métodos de validação
  bool get isValid {
    return _isValidInterval() &&
        _isValidResolucao() &&
        _isValidFormato() &&
        _isValidIdioma();
  }

  bool _isValidInterval() {
    return intervaloDefaultA < intervaloDefaultB &&
        intervaloDefaultA >= -100.0 &&
        intervaloDefaultB <= 100.0;
  }

  bool _isValidResolucao() {
    return resolucaoGrafico >= 100 && resolucaoGrafico <= 10000;
  }

  bool _isValidFormato() {
    const formatosValidos = ['decimal', 'fracao', 'cientifico', 'percentual'];
    return formatosValidos.contains(formatoNumero);
  }

  bool _isValidIdioma() {
    const idiomasValidos = ['pt_BR', 'en_US', 'es_ES'];
    return idiomasValidos.contains(linguagem);
  }

  // Métodos utilitários para configurações específicas
  String get formatoDisplay {
    switch (formatoNumero) {
      case 'decimal':
        return 'Decimal (0.123)';
      case 'fracao':
        return 'Fração (1/8)';
      case 'cientifico':
        return 'Científico (1.23e-1)';
      case 'percentual':
        return 'Percentual quando aplicável';
      default:
        return 'Decimal (0.123)';
    }
  }

  String get resolucaoDisplay {
    if (resolucaoGrafico <= 500) return 'Baixa';
    if (resolucaoGrafico <= 1000) return 'Média';
    if (resolucaoGrafico <= 2000) return 'Alta';
    return 'Muito Alta';
  }

  String get temaDisplay {
    switch (tema) {
      case 'escuro':
        return 'Escuro';
      case 'claro':
        return 'Claro';
      case 'automatico':
        return 'Automático';
      default:
        return 'Escuro';
    }
  }
}
