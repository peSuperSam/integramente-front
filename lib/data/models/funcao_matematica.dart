import 'package:equatable/equatable.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/formatters.dart';

class FuncaoMatematica extends Equatable {
  final String expressao;
  final String expressaoFormatada;
  final String expressaoLatex;
  final bool isValida;
  final DateTime criadaEm;
  final String? erro;

  const FuncaoMatematica({
    required this.expressao,
    required this.expressaoFormatada,
    required this.expressaoLatex,
    required this.isValida,
    required this.criadaEm,
    this.erro,
  });

  factory FuncaoMatematica.criarDaExpressao(String expressao) {
    // Usar validação centralizada
    final isValida = Validators.isValidMathFunction(expressao);
    final expressaoNormalizada = Validators.normalizeMathFunction(expressao);

    return FuncaoMatematica(
      expressao: expressao.trim(),
      expressaoFormatada: Formatters.formatMathFunction(expressaoNormalizada),
      expressaoLatex: Formatters.toLatex(expressaoNormalizada),
      isValida: isValida,
      criadaEm: DateTime.now(),
      erro: isValida ? null : 'Expressão matemática inválida',
    );
  }

  FuncaoMatematica copyWith({
    String? expressao,
    String? expressaoFormatada,
    String? expressaoLatex,
    bool? isValida,
    DateTime? criadaEm,
    String? erro,
  }) {
    return FuncaoMatematica(
      expressao: expressao ?? this.expressao,
      expressaoFormatada: expressaoFormatada ?? this.expressaoFormatada,
      expressaoLatex: expressaoLatex ?? this.expressaoLatex,
      isValida: isValida ?? this.isValida,
      criadaEm: criadaEm ?? this.criadaEm,
      erro: erro ?? this.erro,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expressao': expressao,
      'expressaoFormatada': expressaoFormatada,
      'expressaoLatex': expressaoLatex,
      'isValida': isValida,
      'criadaEm': criadaEm.toIso8601String(),
      'erro': erro,
    };
  }

  factory FuncaoMatematica.fromJson(Map<String, dynamic> json) {
    return FuncaoMatematica(
      expressao: json['expressao'],
      expressaoFormatada: json['expressaoFormatada'],
      expressaoLatex: json['expressaoLatex'],
      isValida: json['isValida'],
      criadaEm: DateTime.parse(json['criadaEm']),
      erro: json['erro'],
    );
  }

  @override
  List<Object?> get props => [
    expressao,
    expressaoFormatada,
    expressaoLatex,
    isValida,
    criadaEm,
    erro,
  ];

  @override
  String toString() {
    return 'FuncaoMatematica(expressao: $expressao, isValida: $isValida)';
  }
}
