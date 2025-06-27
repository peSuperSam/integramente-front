import 'package:equatable/equatable.dart';
import 'funcao_matematica.dart';
import 'calculo_response.dart';

enum TipoCalculo { area, simbolico, derivada, limite }

class HistoricoItem extends Equatable {
  final String id;
  final FuncaoMatematica funcao;
  final TipoCalculo tipo;
  final DateTime criadoEm;
  final bool isFavorito;
  final double? intervaloA;
  final double? intervaloB;
  final double? pontoLimite; // Para cálculo de limite
  final CalculoAreaResponse? resultadoArea;
  final CalculoSimbolicoResponse? resultadoSimbolico;
  final CalculoDerivadaResponse? resultadoDerivada;
  final CalculoLimiteResponse? resultadoLimite;
  final String? miniaturalGrafico; // Base64 da miniatura

  const HistoricoItem({
    required this.id,
    required this.funcao,
    required this.tipo,
    required this.criadoEm,
    this.isFavorito = false,
    this.intervaloA,
    this.intervaloB,
    this.pontoLimite,
    this.resultadoArea,
    this.resultadoSimbolico,
    this.resultadoDerivada,
    this.resultadoLimite,
    this.miniaturalGrafico,
  });

  factory HistoricoItem.area({
    required FuncaoMatematica funcao,
    required double intervaloA,
    required double intervaloB,
    CalculoAreaResponse? resultado,
  }) {
    return HistoricoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      funcao: funcao,
      tipo: TipoCalculo.area,
      criadoEm: DateTime.now(),
      intervaloA: intervaloA,
      intervaloB: intervaloB,
      resultadoArea: resultado,
    );
  }

  factory HistoricoItem.simbolico({
    required FuncaoMatematica funcao,
    CalculoSimbolicoResponse? resultado,
  }) {
    return HistoricoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      funcao: funcao,
      tipo: TipoCalculo.simbolico,
      criadoEm: DateTime.now(),
      resultadoSimbolico: resultado,
    );
  }

  factory HistoricoItem.derivada({
    required FuncaoMatematica funcao,
    CalculoDerivadaResponse? resultado,
  }) {
    return HistoricoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      funcao: funcao,
      tipo: TipoCalculo.derivada,
      criadoEm: DateTime.now(),
      resultadoDerivada: resultado,
    );
  }

  factory HistoricoItem.limite({
    required FuncaoMatematica funcao,
    required double pontoLimite,
    CalculoLimiteResponse? resultado,
  }) {
    return HistoricoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      funcao: funcao,
      tipo: TipoCalculo.limite,
      criadoEm: DateTime.now(),
      pontoLimite: pontoLimite,
      resultadoLimite: resultado,
    );
  }

  HistoricoItem copyWith({
    String? id,
    FuncaoMatematica? funcao,
    TipoCalculo? tipo,
    DateTime? criadoEm,
    bool? isFavorito,
    double? intervaloA,
    double? intervaloB,
    double? pontoLimite,
    CalculoAreaResponse? resultadoArea,
    CalculoSimbolicoResponse? resultadoSimbolico,
    CalculoDerivadaResponse? resultadoDerivada,
    CalculoLimiteResponse? resultadoLimite,
    String? miniaturalGrafico,
  }) {
    return HistoricoItem(
      id: id ?? this.id,
      funcao: funcao ?? this.funcao,
      tipo: tipo ?? this.tipo,
      criadoEm: criadoEm ?? this.criadoEm,
      isFavorito: isFavorito ?? this.isFavorito,
      intervaloA: intervaloA ?? this.intervaloA,
      intervaloB: intervaloB ?? this.intervaloB,
      pontoLimite: pontoLimite ?? this.pontoLimite,
      resultadoArea: resultadoArea ?? this.resultadoArea,
      resultadoSimbolico: resultadoSimbolico ?? this.resultadoSimbolico,
      resultadoDerivada: resultadoDerivada ?? this.resultadoDerivada,
      resultadoLimite: resultadoLimite ?? this.resultadoLimite,
      miniaturalGrafico: miniaturalGrafico ?? this.miniaturalGrafico,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'funcao': funcao.toJson(),
      'tipo': tipo.toString(),
      'criadoEm': criadoEm.toIso8601String(),
      'isFavorito': isFavorito,
      'intervaloA': intervaloA,
      'intervaloB': intervaloB,
      'pontoLimite': pontoLimite,
      'resultadoArea': resultadoArea?.toJson(),
      'resultadoSimbolico': resultadoSimbolico?.toJson(),
      'resultadoDerivada': resultadoDerivada?.toJson(),
      'resultadoLimite': resultadoLimite?.toJson(),
      'miniaturalGrafico': miniaturalGrafico,
    };
  }

  factory HistoricoItem.fromJson(Map<String, dynamic> json) {
    return HistoricoItem(
      id: json['id'],
      funcao: FuncaoMatematica.fromJson(json['funcao']),
      tipo: TipoCalculo.values.firstWhere((e) => e.toString() == json['tipo']),
      criadoEm: DateTime.parse(json['criadoEm']),
      isFavorito: json['isFavorito'] ?? false,
      intervaloA: json['intervaloA']?.toDouble(),
      intervaloB: json['intervaloB']?.toDouble(),
      pontoLimite: json['pontoLimite']?.toDouble(),
      resultadoArea:
          json['resultadoArea'] != null
              ? CalculoAreaResponse.fromJson(json['resultadoArea'])
              : null,
      resultadoSimbolico:
          json['resultadoSimbolico'] != null
              ? CalculoSimbolicoResponse.fromJson(json['resultadoSimbolico'])
              : null,
      resultadoDerivada:
          json['resultadoDerivada'] != null
              ? CalculoDerivadaResponse.fromJson(json['resultadoDerivada'])
              : null,
      resultadoLimite:
          json['resultadoLimite'] != null
              ? CalculoLimiteResponse.fromJson(json['resultadoLimite'])
              : null,
      miniaturalGrafico: json['miniaturalGrafico'],
    );
  }

  // Getters de conveniência
  bool get temResultado =>
      (tipo == TipoCalculo.area && resultadoArea != null) ||
      (tipo == TipoCalculo.simbolico && resultadoSimbolico != null) ||
      (tipo == TipoCalculo.derivada && resultadoDerivada != null) ||
      (tipo == TipoCalculo.limite && resultadoLimite != null);

  bool get calculoComSucesso =>
      (resultadoArea?.sucesso ?? false) ||
      (resultadoSimbolico?.sucesso ?? false) ||
      (resultadoDerivada?.sucesso ?? false) ||
      (resultadoLimite?.sucesso ?? false);

  String get descricaoResultado {
    if (tipo == TipoCalculo.area && resultadoArea != null) {
      return 'Área: ${resultadoArea!.areaTotal?.toStringAsFixed(4) ?? "N/A"}';
    } else if (tipo == TipoCalculo.simbolico && resultadoSimbolico != null) {
      return 'Antiderivada: ${resultadoSimbolico!.antiderivada ?? "N/A"}';
    } else if (tipo == TipoCalculo.derivada && resultadoDerivada != null) {
      return 'Derivada: ${resultadoDerivada!.derivada ?? "N/A"}';
    } else if (tipo == TipoCalculo.limite && resultadoLimite != null) {
      return 'Limite: ${resultadoLimite!.valorLimite?.toStringAsFixed(4) ?? "N/A"}';
    }
    return 'Sem resultado';
  }

  String get descricaoCompleta {
    if (tipo == TipoCalculo.area) {
      final intervalo =
          intervaloA != null && intervaloB != null
              ? ' em [$intervaloA, $intervaloB]'
              : '';
      return '${funcao.expressaoFormatada}$intervalo';
    } else if (tipo == TipoCalculo.limite) {
      final ponto = pontoLimite != null ? ' quando x → $pontoLimite' : '';
      return '${funcao.expressaoFormatada}$ponto';
    } else {
      return funcao.expressaoFormatada;
    }
  }

  @override
  List<Object?> get props => [
    id,
    funcao,
    tipo,
    criadoEm,
    isFavorito,
    intervaloA,
    intervaloB,
    pontoLimite,
    resultadoArea,
    resultadoSimbolico,
    resultadoDerivada,
    resultadoLimite,
    miniaturalGrafico,
  ];

  @override
  String toString() {
    return 'HistoricoItem(id: $id, funcao: ${funcao.expressao}, tipo: $tipo)';
  }
}
