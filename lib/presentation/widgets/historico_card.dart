import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/historico_item.dart';

class HistoricoCard extends StatelessWidget {
  final HistoricoItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;
  final bool isCompact;
  final bool mostrarGrafico;

  const HistoricoCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavorite,
    this.onDelete,
    this.isCompact = false,
    this.mostrarGrafico = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Container(
            padding: EdgeInsets.all(
              isCompact
                  ? AppConstants.paddingSmall
                  : AppConstants.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              border: Border.all(
                color:
                    item.calculoComSucesso
                        ? AppColors.success
                        : AppColors.glassBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com tipo e data
                Row(
                  children: [
                    _buildTipoIcon(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTipoTexto(),
                            style: TextStyle(
                              color: _getTipoCor(),
                              fontSize: isCompact ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!isCompact)
                            Text(
                              _formatarData(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (item.isFavorito)
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 16,
                      ),
                    if (!isCompact) ...[
                      IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          item.isFavorito ? Icons.star : Icons.star_border,
                          color:
                              item.isFavorito
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                          size: 18,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Função matemática
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'f(x) = ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.funcao.expressaoFormatada,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Intervalo (apenas para cálculo de área)
                if (item.tipo == TipoCalculo.area &&
                    item.intervaloA != null &&
                    item.intervaloB != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.straighten,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Intervalo: [${item.intervaloA}, ${item.intervaloB}]',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],

                if (!isCompact) ...[
                  const SizedBox(height: 12),

                  // Resultado
                  Row(
                    children: [
                      Icon(
                        item.calculoComSucesso
                            ? Icons.check_circle
                            : Icons.error,
                        color:
                            item.calculoComSucesso
                                ? AppColors.success
                                : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.descricaoResultado,
                          style: TextStyle(
                            color:
                                item.calculoComSucesso
                                    ? AppColors.success
                                    : AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Gráfico (se habilitado e disponível)
                  if (mostrarGrafico &&
                      item.calculoComSucesso &&
                      item.tipo == TipoCalculo.area) ...[
                    const SizedBox(height: 12),
                    _buildGraficoCompacto(),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipoIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getTipoCor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        item.tipo == TipoCalculo.area ? Icons.area_chart : Icons.functions,
        color: _getTipoCor(),
        size: 16,
      ),
    );
  }

  String _getTipoTexto() {
    return item.tipo == TipoCalculo.area
        ? 'Cálculo de Área'
        : 'Cálculo Simbólico';
  }

  Color _getTipoCor() {
    return item.tipo == TipoCalculo.area
        ? AppColors.integralColor
        : AppColors.derivativeColor;
  }

  String _formatarData() {
    final agora = DateTime.now();
    final diferenca = agora.difference(item.criadoEm);

    if (diferenca.inMinutes < 1) {
      return 'Agora';
    } else if (diferenca.inHours < 1) {
      return '${diferenca.inMinutes}min atrás';
    } else if (diferenca.inDays < 1) {
      return '${diferenca.inHours}h atrás';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays}d atrás';
    } else {
      return Formatters.formatDateTime(item.criadoEm);
    }
  }

  Widget _buildGraficoCompacto() {
    // Versão simplificada apenas com imagem base64
    if (item.resultadoArea?.graficoBase64 != null) {
      try {
        final imageBytes = base64Decode(item.resultadoArea!.graficoBase64!);
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderSimples();
              },
            ),
          ),
        );
      } catch (e) {
        return _buildPlaceholderSimples();
      }
    }

    return _buildPlaceholderSimples();
  }

  Widget _buildPlaceholderSimples() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Gráfico não disponível',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para lista de histórico
class HistoricoLista extends StatelessWidget {
  final List<HistoricoItem> items;
  final Function(HistoricoItem)? onItemTap;
  final Function(String)? onToggleFavorito;
  final Function(String)? onRemoverItem;
  final bool isCompact;
  final bool mostrarGraficos;
  final String? emptyMessage;

  const HistoricoLista({
    super.key,
    required this.items,
    this.onItemTap,
    this.onToggleFavorito,
    this.onRemoverItem,
    this.isCompact = false,
    this.mostrarGraficos = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Nenhum cálculo encontrado',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return HistoricoCard(
          item: item,
          isCompact: isCompact,
          mostrarGrafico: mostrarGraficos,
          onTap: () => onItemTap?.call(item),
          onFavorite: () => onToggleFavorito?.call(item.id),
          onDelete: () => onRemoverItem?.call(item.id),
        );
      },
    );
  }
}

// Widget para estatísticas rápidas do histórico
class HistoricoEstatisticas extends StatelessWidget {
  final Map<String, dynamic> estatisticas;

  const HistoricoEstatisticas({super.key, required this.estatisticas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  estatisticas['totalCalculos']?.toString() ?? '0',
                  Icons.calculate,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Área',
                  estatisticas['calculosArea']?.toString() ?? '0',
                  Icons.area_chart,
                  AppColors.integralColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Simbólico',
                  estatisticas['calculosSimbolico']?.toString() ?? '0',
                  Icons.functions,
                  AppColors.derivativeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
