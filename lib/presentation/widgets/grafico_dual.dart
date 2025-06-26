import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/calculo_response.dart';
import '../../data/models/funcao_matematica.dart';
import 'grafico_backend.dart';
import 'grafico_interativo.dart';

enum TipoGrafico { api, interativo }

class GraficoDual extends StatefulWidget {
  final CalculoAreaResponse? resultadoCalculo;
  final FuncaoMatematica? funcao;
  final double? intervaloA;
  final double? intervaloB;
  final double? areaCalculada;

  const GraficoDual({
    super.key,
    this.resultadoCalculo,
    this.funcao,
    this.intervaloA,
    this.intervaloB,
    this.areaCalculada,
  });

  @override
  State<GraficoDual> createState() => _GraficoDualState();
}

class _GraficoDualState extends State<GraficoDual> {
  TipoGrafico _tipoSelecionado = TipoGrafico.api;

  @override
  void initState() {
    super.initState();
    // Se não há gráfico da API, inicia com o interativo
    if (widget.resultadoCalculo?.graficoBase64 == null) {
      _tipoSelecionado = TipoGrafico.interativo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final temGraficoAPI = widget.resultadoCalculo?.graficoBase64 != null;
    final temFuncao = widget.funcao != null;

    // Se não tem nenhum gráfico disponível
    if (!temGraficoAPI && !temFuncao) {
      return _buildPlaceholder();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Seletor de tipo de gráfico
          if (temGraficoAPI && temFuncao) _buildSelector(),

          // Gráfico selecionado
          _buildGraficoAtual(),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Visualização do Gráfico',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),

          // Toggle buttons
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(
                  'Servidor',
                  TipoGrafico.api,
                  Icons.cloud,
                  'Gráfico gerado pelo backend com área sombreada',
                ),
                _buildToggleButton(
                  'Interativo',
                  TipoGrafico.interativo,
                  Icons.touch_app,
                  'Gráfico local interativo com zoom',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    TipoGrafico tipo,
    IconData icon,
    String tooltip,
  ) {
    final isSelected = _tipoSelecionado == tipo;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _tipoSelecionado = tipo),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoAtual() {
    switch (_tipoSelecionado) {
      case TipoGrafico.api:
        if (widget.resultadoCalculo?.graficoBase64 != null) {
          return GraficoBackend(
            resultadoCalculo: widget.resultadoCalculo!,
            titulo: null, // Não mostra título pois já está no selector
            mostrarDetalhes: true,
          );
        }
        return _buildFallbackToInterativo();

      case TipoGrafico.interativo:
        if (widget.funcao != null) {
          return GraficoInterativo(
            funcao: widget.funcao!,
            intervaloA: widget.intervaloA,
            intervaloB: widget.intervaloB,
            mostrarArea: widget.areaCalculada != null,
            areaCalculada: widget.areaCalculada,
          );
        }
        return _buildFallbackToAPI();
    }
  }

  Widget _buildFallbackToInterativo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Gráfico do servidor não disponível. Alternando para modo interativo.',
                    style: TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.funcao != null)
            GraficoInterativo(
              funcao: widget.funcao!,
              intervaloA: widget.intervaloA,
              intervaloB: widget.intervaloB,
              mostrarArea: widget.areaCalculada != null,
              areaCalculada: widget.areaCalculada,
            )
          else
            _buildPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildFallbackToAPI() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Função não disponível para gráfico interativo. Alternando para gráfico do servidor.',
                    style: TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.resultadoCalculo?.graficoBase64 != null)
            GraficoBackend(
              resultadoCalculo: widget.resultadoCalculo!,
              titulo: null,
              mostrarDetalhes: true,
            )
          else
            _buildPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_chart,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum gráfico disponível',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Execute um cálculo para ver o gráfico',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
