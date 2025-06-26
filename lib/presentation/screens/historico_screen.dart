import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../widgets/smart_cache_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_transitions.dart';
import '../widgets/historico_card.dart';
import '../../core/performance/performance_monitor.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive_helper.dart';
import '../../data/models/historico_item.dart';
import '../../data/services/storage_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen>
    with SmartCacheMixin {
  final StorageService _storageService = Get.find<StorageService>();
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();
  final TextEditingController _searchController = TextEditingController();

  List<HistoricoItem> _historico = [];
  bool _isLoading = true;
  String _filtro = '';
  String _tipoFiltro = 'Todos';
  String _ordenacao = 'Mais Recente';
  bool _mostrarGraficos = false;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarHistorico() async {
    await _performanceMonitor.measureAsync('carregar_historico', () async {
      final historico = await _storageService.getHistorico();
      if (mounted) {
        setState(() {
          _historico = historico;
          _isLoading = false;
        });
      }
    });
  }

  List<HistoricoItem> get _historicoFiltrado {
    return _performanceMonitor.measure('filtrar_historico', () {
      var resultado = _historico;

      if (_filtro.isNotEmpty) {
        resultado =
            resultado
                .where(
                  (item) =>
                      item.funcao.expressao.toLowerCase().contains(
                        _filtro.toLowerCase(),
                      ) ||
                      item.descricaoResultado.toLowerCase().contains(
                        _filtro.toLowerCase(),
                      ),
                )
                .toList();
      }

      if (_tipoFiltro != 'Todos') {
        final tipoEnum =
            _tipoFiltro == 'Área' ? TipoCalculo.area : TipoCalculo.simbolico;
        resultado = resultado.where((item) => item.tipo == tipoEnum).toList();
      }

      switch (_ordenacao) {
        case 'Mais Recente':
          resultado.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
          break;
        case 'Mais Antigo':
          resultado.sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
          break;
        case 'Função A-Z':
          resultado.sort(
            (a, b) => a.funcao.expressao.compareTo(b.funcao.expressao),
          );
          break;
        case 'Favoritos':
          resultado = resultado.where((item) => item.isFavorito).toList();
          resultado.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
          break;
      }

      return resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer:
          ResponsiveHelper.shouldUseDrawer(context)
              ? const SideMenu(currentRoute: '/historico')
              : null,
      appBar:
          ResponsiveHelper.shouldUseDrawer(context)
              ? AppBar(
                backgroundColor: AppColors.backgroundCard,
                title: const Text(
                  'Histórico',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
              )
              : null,
      body: AdaptiveLayout(
        sideMenu: const SideMenu(currentRoute: '/historico'),
        currentRoute: '/historico',
        body: AnimatedPageEntry(
          animationType: AnimationType.slideUp,
          child: CustomScrollView(
            slivers: [
              if (!ResponsiveHelper.shouldUseDrawer(context)) _buildAppBar(),
              SliverPadding(
                padding: EdgeInsets.all(
                  ResponsiveHelper.getHorizontalPadding(context),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatusCards(),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    _buildFiltersAndSearch(),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    _buildHistoricoContent(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundCard.withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.success,
                AppColors.integralColor,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Histórico de Cálculos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Seus cálculos anteriores organizados',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _limparHistorico,
          icon: const Icon(Icons.delete_sweep, color: Colors.white),
          tooltip: 'Limpar histórico',
        ),
        IconButton(
          onPressed: () => _mostrarAjuda(context),
          icon: const Icon(Icons.help_outline, color: Colors.white),
          tooltip: 'Ajuda',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatusCards() {
    final total = _historico.length;
    final sucesso = _historico.where((item) => item.calculoComSucesso).length;
    final favoritos = _historico.where((item) => item.isFavorito).length;
    final area =
        _historico.where((item) => item.tipo == TipoCalculo.area).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Total',
            total.toString(),
            Icons.calculate,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            'Sucesso',
            sucesso.toString(),
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            'Favoritos',
            favoritos.toString(),
            Icons.favorite,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            'Área',
            area.toString(),
            Icons.area_chart,
            AppColors.integralColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return SectionCard(
      titulo: 'Filtros e Busca',
      icon: Icons.tune,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por função ou resultado...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon:
                    _filtro.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filtro = '';
                            });
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted && value == _searchController.text) {
                    setState(() {
                      _filtro = value;
                    });
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFilterChips()),
              const SizedBox(width: 16),
              _buildGraficoToggle(),
              const SizedBox(width: 8),
              _buildSortButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children:
          ['Todos', 'Área', 'Simbólico'].map((tipo) {
            final isSelected = _tipoFiltro == tipo;
            return FilterChip(
              label: Text(tipo),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tipoFiltro = tipo;
                });
              },
              backgroundColor: AppColors.backgroundSurface,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildGraficoToggle() {
    return Tooltip(
      message: 'Mostrar gráficos nos cards de área',
      child: Container(
        decoration: BoxDecoration(
          color:
              _mostrarGraficos
                  ? AppColors.integralColor.withValues(alpha: 0.1)
                  : AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                _mostrarGraficos
                    ? AppColors.integralColor
                    : AppColors.glassBorder,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _mostrarGraficos = !_mostrarGraficos;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.show_chart,
                  color:
                      _mostrarGraficos
                          ? AppColors.integralColor
                          : AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Gráficos',
                  style: TextStyle(
                    color:
                        _mostrarGraficos
                            ? AppColors.integralColor
                            : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        _mostrarGraficos ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      initialValue: _ordenacao,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, color: AppColors.primary, size: 18),
            SizedBox(width: 4),
            Text(
              'Ordenar',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ],
        ),
      ),
      color: AppColors.backgroundCard,
      onSelected: (value) {
        setState(() {
          _ordenacao = value;
        });
      },
      itemBuilder:
          (context) =>
              ['Mais Recente', 'Mais Antigo', 'Função A-Z', 'Favoritos']
                  .map(
                    (option) => PopupMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            _getOrderIcon(option),
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
    );
  }

  IconData _getOrderIcon(String option) {
    switch (option) {
      case 'Mais Recente':
        return Icons.access_time;
      case 'Mais Antigo':
        return Icons.history;
      case 'Função A-Z':
        return Icons.sort_by_alpha;
      case 'Favoritos':
        return Icons.favorite;
      default:
        return Icons.sort;
    }
  }

  Widget _buildHistoricoContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    final historicoFiltrado = _historicoFiltrado;

    if (historicoFiltrado.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${historicoFiltrado.length} ${historicoFiltrado.length == 1 ? 'cálculo encontrado' : 'cálculos encontrados'}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historicoFiltrado.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = historicoFiltrado[index];
            return HistoricoCard(
              item: item,
              mostrarGrafico: _mostrarGraficos,
              onTap: () => _abrirDetalhes(item),
              onFavorite: () => _toggleFavorito(item),
              onDelete: () async {
                setState(() {
                  _historico.removeWhere((h) => h.id == item.id);
                });
                await _storageService.salvarHistorico(_historico);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SectionCard(
      titulo: 'Carregando Histórico',
      icon: Icons.hourglass_empty,
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Carregando seus cálculos...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SectionCard(
      titulo: 'Histórico Vazio',
      icon: Icons.history_toggle_off,
      child: Column(
        children: [
          Icon(
            _filtro.isNotEmpty || _tipoFiltro != 'Todos'
                ? Icons.search_off
                : Icons.calculate,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            _filtro.isNotEmpty || _tipoFiltro != 'Todos'
                ? 'Nenhum cálculo encontrado'
                : 'Nenhum item no histórico',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filtro.isNotEmpty || _tipoFiltro != 'Todos'
                ? 'Tente ajustar os filtros de busca'
                : 'Seus cálculos aparecerão aqui automaticamente',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_filtro.isNotEmpty || _tipoFiltro != 'Todos')
                ElevatedButton.icon(
                  onPressed: _limparFiltros,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Filtros'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (_filtro.isEmpty && _tipoFiltro == 'Todos') ...[
                ElevatedButton.icon(
                  onPressed: () => context.go('/area'),
                  icon: const Icon(Icons.area_chart),
                  label: const Text('Calcular Área'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.integralColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/calculadora'),
                  icon: const Icon(Icons.functions),
                  label: const Text('Cálculo Simbólico'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(TipoCalculo tipo) {
    switch (tipo) {
      case TipoCalculo.area:
        return AppColors.integralColor;
      case TipoCalculo.simbolico:
        return AppColors.derivativeColor;
    }
  }

  IconData _getTipoIcon(TipoCalculo tipo) {
    switch (tipo) {
      case TipoCalculo.area:
        return Icons.area_chart;
      case TipoCalculo.simbolico:
        return Icons.functions;
    }
  }

  void _limparFiltros() {
    setState(() {
      _filtro = '';
      _tipoFiltro = 'Todos';
      _ordenacao = 'Mais Recente';
      _mostrarGraficos = false;
    });
    _searchController.clear();
  }

  void _toggleFavorito(HistoricoItem item) async {
    setState(() {
      final index = _historico.indexWhere((h) => h.id == item.id);
      if (index != -1) {
        _historico[index] = item.copyWith(isFavorito: !item.isFavorito);
      }
    });
  }

  void _reutilizarCalculo(HistoricoItem item) {
    if (item.tipo == TipoCalculo.area) {
      context.go('/area');
    } else {
      context.go('/calculadora');
    }
  }

  void _abrirDetalhes(HistoricoItem item) {
    showDialog(
      context: context,
      builder: (context) => _buildDetalhesDialog(item),
    );
  }

  Widget _buildDetalhesDialog(HistoricoItem item) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: Row(
        children: [
          Icon(_getTipoIcon(item.tipo), color: _getTipoColor(item.tipo)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Detalhes do Cálculo',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            icon: Icon(
              item.isFavorito ? Icons.favorite : Icons.favorite_border,
              color:
                  item.isFavorito ? AppColors.warning : AppColors.textSecondary,
            ),
            onPressed: () => _toggleFavorito(item),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetalheItem(
              'Função',
              Formatters.formatMathFunction(item.funcao.expressao),
            ),
            if (item.tipo == TipoCalculo.area) ...[
              _buildDetalheItem(
                'Intervalo A',
                item.intervaloA?.toString() ?? '',
              ),
              _buildDetalheItem(
                'Intervalo B',
                item.intervaloB?.toString() ?? '',
              ),
            ],
            _buildDetalheItem('Resultado', item.descricaoResultado),
            _buildDetalheItem('Data', Formatters.formatDateTime(item.criadoEm)),
            _buildDetalheItem(
              'Status',
              item.calculoComSucesso ? 'Sucesso' : 'Erro',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _reutilizarCalculo(item);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reutilizar'),
        ),
      ],
    );
  }

  Widget _buildDetalheItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _limparHistorico() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: const Row(
              children: [
                Icon(Icons.warning, color: AppColors.warning),
                SizedBox(width: 8),
                Text(
                  'Confirmar Limpeza',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: const Text(
              'Tem certeza que deseja limpar todo o histórico? Esta ação não pode ser desfeita.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _storageService.limparHistorico();
                  setState(() {
                    _historico.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Limpar'),
              ),
            ],
          ),
    );
  }

  void _mostrarAjuda(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: const Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Ajuda - Histórico',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Como usar o Histórico:\n\n'
                    '🔍 Busca: Digite função ou resultado para filtrar\n'
                    '🏷️ Filtros: Use os chips para filtrar por tipo\n'
                    '📊 Ordenação: Clique no botão "Ordenar" para organizar\n'
                    '⭐ Favoritos: Clique no coração para favoritar\n'
                    '🔄 Reutilizar: Use "Reutilizar" para refazer cálculo\n'
                    '👁️ Detalhes: Clique no card para ver mais informações\n\n'
                    'Dica: Use favoritos para marcar cálculos importantes!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendi'),
              ),
            ],
          ),
    );
  }
}
