import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/app_state.dart';
import '../../data/services/storage_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_transitions.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final StorageService _storageService = Get.find<StorageService>();

  // Configurações observáveis
  bool _animacoesHabilitadas = true;
  bool _notificacoesHabilitadas = true;
  String _tema = 'escuro';
  String _formatoNumero = 'decimal';
  double _intervaloDefaultA = 0.0;
  double _intervaloDefaultB = 1.0;
  int _resolucaoGrafico = 1000;
  String _linguagem = 'pt_BR';

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguracoes();
  }

  Future<void> _loadConfiguracoes() async {
    try {
      final config = await _storageService.getConfiguracoes();
      setState(() {
        _animacoesHabilitadas = config['animacoes'] ?? true;
        _notificacoesHabilitadas = config['notificacoes'] ?? true;
        _tema = config['tema'] ?? 'escuro';
        _formatoNumero = config['formatoNumero'] ?? 'decimal';
        _intervaloDefaultA = config['intervaloDefaultA'] ?? 0.0;
        _intervaloDefaultB = config['intervaloDefaultB'] ?? 1.0;
        _resolucaoGrafico = config['resolucaoGrafico'] ?? 1000;
        _linguagem = config['linguagem'] ?? 'pt_BR';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erro ao carregar configurações: ${e.toString()}');
    }
  }

  Future<void> _salvarConfiguracoes() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final config = {
        'tema': _tema,
        'animacoes': _animacoesHabilitadas,
        'notificacoes': _notificacoesHabilitadas,
        'intervaloDefaultA': _intervaloDefaultA,
        'intervaloDefaultB': _intervaloDefaultB,
        'resolucaoGrafico': _resolucaoGrafico,
        'formatoNumero': _formatoNumero,
        'linguagem': _linguagem,
      };

      await _storageService.salvarConfiguracoes(config);

      _showSuccess('Configurações salvas com sucesso!');
    } catch (e) {
      _showError('Erro ao salvar configurações: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.backgroundCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.backgroundCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetarConfiguracoes() {
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
                  'Confirmar Reset',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: const Text(
              'Tem certeza que deseja restaurar todas as configurações para os valores padrão?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetarParaPadrao();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Resetar'),
              ),
            ],
          ),
    );
  }

  void _resetarParaPadrao() {
    setState(() {
      _animacoesHabilitadas = true;
      _notificacoesHabilitadas = true;
      _tema = 'escuro';
      _formatoNumero = 'decimal';
      _intervaloDefaultA = 0.0;
      _intervaloDefaultB = 1.0;
      _resolucaoGrafico = 1000;
      _linguagem = 'pt_BR';
    });
    _salvarConfiguracoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer:
          ResponsiveHelper.shouldUseDrawer(context)
              ? const SideMenu(currentRoute: '/configuracoes')
              : null,
      appBar:
          ResponsiveHelper.shouldUseDrawer(context)
              ? AppBar(
                backgroundColor: AppColors.backgroundCard,
                title: const Text(
                  'Configurações',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
              )
              : null,
      body: AdaptiveLayout(
        sideMenu: const SideMenu(currentRoute: '/configuracoes'),
        currentRoute: '/configuracoes',
        body: AnimatedPageEntry(
          animationType: AnimationType.slideUp,
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                  : CustomScrollView(
                    slivers: [
                      if (!ResponsiveHelper.shouldUseDrawer(context))
                        _buildAppBar(),
                      SliverPadding(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.getHorizontalPadding(context),
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildInterfaceSection(),
                            SizedBox(
                              height: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                AppConstants.paddingMedium,
                              ),
                            ),
                            _buildCalculoSection(),
                            SizedBox(
                              height: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                AppConstants.paddingMedium,
                              ),
                            ),
                            _buildGraficoSection(),
                            SizedBox(
                              height: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                AppConstants.paddingMedium,
                              ),
                            ),
                            _buildAcoesSection(),
                            // Seção de debug (apenas em desenvolvimento)
                            if (const bool.fromEnvironment('dart.vm.product') ==
                                false)
                              _buildDebugSection(),
                            SizedBox(
                              height: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                AppConstants.paddingLarge,
                              ),
                            ),
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
      expandedHeight: 120,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundCard.withValues(alpha: 0.8),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.warning],
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Configurações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Personalize sua experiência',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _resetarConfiguracoes,
          icon: const Icon(Icons.restart_alt, color: Colors.white),
          tooltip: 'Resetar configurações',
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

  Widget _buildInterfaceSection() {
    return SectionCard(
      titulo: 'Interface',
      icon: Icons.palette,
      child: Column(
        children: [
          _buildSwitchTile(
            'Animações',
            'Habilitar efeitos visuais e transições',
            Icons.animation,
            _animacoesHabilitadas,
            (value) => setState(() => _animacoesHabilitadas = value),
          ),
          const Divider(color: AppColors.glassBorder),
          _buildSwitchTile(
            'Notificações',
            'Receber alertas e lembretes',
            Icons.notifications,
            _notificacoesHabilitadas,
            (value) => setState(() => _notificacoesHabilitadas = value),
          ),
          const Divider(color: AppColors.glassBorder),
          _buildDropdownTile(
            'Formato dos Números',
            'Como exibir resultados numéricos',
            Icons.format_list_numbered,
            _formatoNumero,
            [
              {'value': 'decimal', 'label': 'Decimal (0.123)'},
              {'value': 'fracao', 'label': 'Fração (1/8)'},
              {'value': 'cientifico', 'label': 'Científico (1.23e-1)'},
              {'value': 'percentual', 'label': 'Percentual quando aplicável'},
            ],
            (value) => setState(() => _formatoNumero = value),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculoSection() {
    return SectionCard(
      titulo: 'Cálculo Padrão',
      icon: Icons.calculate,
      child: Column(
        children: [
          _buildSliderTile(
            'Intervalo Inferior (a)',
            'Valor padrão para limite inferior',
            Icons.trending_down,
            _intervaloDefaultA,
            -10.0,
            10.0,
            (value) => setState(() => _intervaloDefaultA = value),
          ),
          const SizedBox(height: 16),
          _buildSliderTile(
            'Intervalo Superior (b)',
            'Valor padrão para limite superior',
            Icons.trending_up,
            _intervaloDefaultB,
            -10.0,
            10.0,
            (value) => setState(() => _intervaloDefaultB = value),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoSection() {
    return SectionCard(
      titulo: 'Gráficos',
      icon: Icons.show_chart,
      child: Column(
        children: [
          _buildDropdownTile(
            'Resolução do Gráfico',
            'Qualidade de renderização dos gráficos',
            Icons.high_quality,
            _resolucaoGrafico.toString(),
            [
              {'value': '500', 'label': 'Baixa (500 pontos)'},
              {'value': '1000', 'label': 'Média (1000 pontos)'},
              {'value': '2000', 'label': 'Alta (2000 pontos)'},
              {'value': '5000', 'label': 'Muito Alta (5000 pontos)'},
            ],
            (value) => setState(() => _resolucaoGrafico = int.parse(value)),
          ),
        ],
      ),
    );
  }

  Widget _buildAcoesSection() {
    return SectionCard(
      titulo: 'Ações',
      icon: Icons.settings_applications,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _salvarConfiguracoes,
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.save),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar Configurações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao Dashboard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.glassBorder),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String titulo,
    String subtitulo,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(
    String titulo,
    String subtitulo,
    IconData icon,
    String value,
    List<Map<String, String>> opcoes,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.backgroundCard,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              items:
                  opcoes.map<DropdownMenuItem<String>>((opcao) {
                    return DropdownMenuItem<String>(
                      value: opcao['value']!,
                      child: Text(opcao['label']!),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile(
    String titulo,
    String subtitulo,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.glassBorder,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDebugSection() {
    return SectionCard(
      titulo: 'Debug (Desenvolvimento)',
      icon: Icons.bug_report,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final appState = Get.find<AppState>();
                appState.resetForTesting();
                context.go('/');
                _showSuccess('Splash resetado! Reinicie o app para testar.');
              },
              icon: const Icon(Icons.refresh, color: AppColors.warning),
              label: const Text(
                'Resetar Splash',
                style: TextStyle(color: AppColors.warning),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
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
                  'Ajuda - Configurações',
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
                    'Interface:\n'
                    '• Animações: Controla efeitos visuais do app\n'
                    '• Notificações: Habilita alertas do sistema\n'
                    '• Formato dos Números: Como exibir resultados\n\n'
                    'Cálculo Padrão:\n'
                    '• Define os intervalos padrão para integrais\n'
                    '• Valores aplicados automaticamente em novos cálculos\n\n'
                    'Gráficos:\n'
                    '• Resolução: Afeta qualidade e performance\n'
                    '• Maior resolução = mais detalhes, mas mais lento\n\n'
                    'Dica: Use "Resetar" para voltar às configurações originais.',
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
