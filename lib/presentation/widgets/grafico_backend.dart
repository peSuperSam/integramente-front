import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/calculo_response.dart';

class GraficoBackend extends StatelessWidget {
  final CalculoAreaResponse? resultadoCalculo;
  final String? titulo;
  final bool mostrarDetalhes;

  const GraficoBackend({
    super.key,
    this.resultadoCalculo,
    this.titulo,
    this.mostrarDetalhes = true,
  });

  @override
  Widget build(BuildContext context) {
    if (resultadoCalculo == null || !resultadoCalculo!.sucesso) {
      return _buildPlaceholder('Erro no cálculo');
    }

    if (resultadoCalculo!.graficoBase64 == null) {
      return _buildPlaceholder('Gráfico não disponível');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do gráfico
          if (titulo != null || mostrarDetalhes)
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics,
                    color: AppColors.integralColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo ?? 'Gráfico da Área sob a Curva',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Indicador de fonte do gráfico
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'API',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Gráfico base64
          _buildGraficoBase64(),

          // Detalhes do cálculo
          if (mostrarDetalhes) _buildDetalhesCalculo(),
        ],
      ),
    );
  }

  Widget _buildGraficoBase64() {
    try {
      final imageBytes = base64Decode(resultadoCalculo!.graficoBase64!);

      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppConstants.borderRadiusMedium),
          topRight: const Radius.circular(AppConstants.borderRadiusMedium),
          bottomLeft: Radius.circular(
            mostrarDetalhes ? 0.0 : AppConstants.borderRadiusMedium,
          ),
          bottomRight: Radius.circular(
            mostrarDetalhes ? 0.0 : AppConstants.borderRadiusMedium,
          ),
        ),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 250, maxHeight: 400),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder('Erro ao carregar gráfico');
            },
          ),
        ),
      );
    } catch (e) {
      return _buildPlaceholder('Erro ao decodificar gráfico');
    }
  }

  Widget _buildDetalhesCalculo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resultados principais
          Row(
            children: [
              Expanded(
                child: _buildMetrica(
                  'Área Total',
                  resultadoCalculo!.areaTotal?.toStringAsFixed(6) ?? 'N/A',
                  AppColors.integralColor,
                  Icons.area_chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetrica(
                  'Valor Integral',
                  resultadoCalculo!.valorIntegral?.toStringAsFixed(6) ?? 'N/A',
                  AppColors.primary,
                  Icons.functions,
                ),
              ),
            ],
          ),

          // Erro estimado (se disponível)
          if (resultadoCalculo!.erroEstimado != null) ...[
            const SizedBox(height: 12),
            _buildMetrica(
              'Erro Estimado',
              resultadoCalculo!.erroEstimado!.toStringAsExponential(2),
              AppColors.warning,
              Icons.precision_manufacturing,
            ),
          ],

          // Intervalo e função
          if (resultadoCalculo!.intervalo != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Intervalo: [${resultadoCalculo!.intervalo!['a']}, ${resultadoCalculo!.intervalo!['b']}]',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          if (resultadoCalculo!.funcaoFormatada != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calculate, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'f(x) = ${resultadoCalculo!.funcaoFormatada!}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetrica(String label, String valor, Color cor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: cor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String mensagem) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              mensagem,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
