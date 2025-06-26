import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_transitions.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _passosTutorial = [
    {
      'titulo': 'Bem-vindo ao IntegraMente',
      'descricao': 'Seu assistente pessoal para Cálculo II',
      'icon': Icons.waving_hand,
      'conteudo':
          'O IntegraMente foi desenvolvido para ajudar você a '
          'compreender e calcular integrais, derivadas e conceitos de Cálculo II '
          'de forma visual e interativa.',
    },
    {
      'titulo': 'Navegação',
      'descricao': 'Como navegar pelo aplicativo',
      'icon': Icons.explore,
      'conteudo':
          'Use o menu lateral para acessar as diferentes funcionalidades. '
          'O Dashboard é seu ponto de partida, onde você encontra ações rápidas '
          'e seu histórico recente.',
    },
    {
      'titulo': 'Área sob a Curva',
      'descricao': 'Calculando integrais definidas',
      'icon': Icons.area_chart,
      'conteudo':
          'Na seção de Área sob a Curva, você pode calcular integrais '
          'definidas de funções matemáticas. Digite a função, defina o intervalo '
          'e veja o resultado com visualização gráfica.',
    },
    {
      'titulo': 'Cálculo Simbólico',
      'descricao': 'Derivadas e integrais indefinidas',
      'icon': Icons.functions,
      'conteudo':
          'Use a Calculadora Simbólica para calcular derivadas, '
          'integrais indefinidas e limites. Ideal para resolver exercícios '
          'e verificar resultados.',
    },
    {
      'titulo': 'Histórico',
      'descricao': 'Acompanhe seus cálculos',
      'icon': Icons.history,
      'conteudo':
          'Todos os seus cálculos são salvos automaticamente no '
          'histórico. Você pode favoritar cálculos importantes e organizá-los '
          'por tipo.',
    },
    {
      'titulo': 'Pronto para começar!',
      'descricao': 'Explore e pratique',
      'icon': Icons.rocket_launch,
      'conteudo':
          'Agora você está pronto para usar o IntegraMente! '
          'Comece explorando as funções básicas e use as sugestões '
          'para aprender novos conceitos.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer:
          ResponsiveHelper.shouldUseDrawer(context)
              ? const SideMenu(currentRoute: '/tutorial')
              : null,
      appBar:
          ResponsiveHelper.shouldUseDrawer(context)
              ? AppBar(
                backgroundColor: AppColors.backgroundCard,
                title: const Text(
                  'Tutorial',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
              )
              : null,
      body: AdaptiveLayout(
        sideMenu: const SideMenu(currentRoute: '/tutorial'),
        currentRoute: '/tutorial',
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
                    _buildTutorialInterativo(),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    _buildGuiasDetalhados(),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    _buildRecursosAdicionais(),
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
              colors: [AppColors.primary, AppColors.integralColor],
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
                    'Tutorial e Ajuda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Aprenda a usar o IntegraMente',
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
          onPressed: () => _mostrarAjudaRapida(context),
          icon: const Icon(Icons.help_outline, color: Colors.white),
          tooltip: 'Ajuda rápida',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTutorialInterativo() {
    return SectionCard(
      titulo: 'Tutorial Interativo',
      icon: Icons.play_circle,
      child: Column(
        children: [
          // Indicador de progresso
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Passo ${_currentStep + 1} de ${_passosTutorial.length}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${((_currentStep + 1) / _passosTutorial.length * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _passosTutorial.length,
                  backgroundColor: AppColors.glassBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Conteúdo do passo atual
          _buildPassoAtual(),

          const SizedBox(height: 16),

          // Controles de navegação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentStep > 0 ? _passoPrevio : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundSurface,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    _currentStep < _passosTutorial.length - 1
                        ? _proximoPasso
                        : _finalizarTutorial,
                icon: Icon(
                  _currentStep < _passosTutorial.length - 1
                      ? Icons.arrow_forward
                      : Icons.check,
                ),
                label: Text(
                  _currentStep < _passosTutorial.length - 1
                      ? 'Próximo'
                      : 'Finalizar',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassoAtual() {
    final passo = _passosTutorial[_currentStep];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(passo['icon'], size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            passo['titulo'],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            passo['descricao'],
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            passo['conteudo'],
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGuiasDetalhados() {
    return SectionCard(
      titulo: 'Guias Detalhados',
      icon: Icons.menu_book,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Funções', icon: Icon(Icons.functions, size: 16)),
              Tab(text: 'Integrais', icon: Icon(Icons.area_chart, size: 16)),
              Tab(text: 'Gráficos', icon: Icon(Icons.show_chart, size: 16)),
              Tab(text: 'Dicas', icon: Icon(Icons.lightbulb, size: 16)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGuiaFuncoes(),
                _buildGuiaIntegrais(),
                _buildGuiaGraficos(),
                _buildGuiaDicas(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuiaFuncoes() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopicCard('Funções Básicas', [
            'x, x^2, x^3 - Polinômios',
            '2*x + 1 - Função linear',
            'sqrt(x) - Raiz quadrada',
          ], Icons.calculate),
          const SizedBox(height: 12),
          _buildTopicCard('Funções Trigonométricas', [
            'sin(x), cos(x), tan(x)',
            'asin(x), acos(x), atan(x)',
            'Lembre-se: use radianos!',
          ], Icons.graphic_eq),
          const SizedBox(height: 12),
          _buildTopicCard('Funções Especiais', [
            'e^x - Exponencial natural',
            'ln(x) - Logaritmo natural',
            'log(x) - Logaritmo base 10',
          ], Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildGuiaIntegrais() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopicCard('Integral Definida', [
            'Representa área sob a curva',
            'Define intervalo [a, b]',
            'Resultado pode ser negativo',
          ], Icons.area_chart),
          const SizedBox(height: 12),
          _buildTopicCard('Exemplos Práticos', [
            'x^2 em [0,1] = 1/3',
            'sin(x) em [0,π] = 2',
            'e^x em [0,1] = e - 1',
          ], Icons.calculate),
          const SizedBox(height: 12),
          _buildTopicCard('Dicas Importantes', [
            'Verifique domínio da função',
            'Cuidado com descontinuidades',
            'Use gráfico para visualizar',
          ], Icons.warning),
        ],
      ),
    );
  }

  Widget _buildGuiaGraficos() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopicCard('Interpretação Visual', [
            'Área azul = integral positiva',
            'Área vermelha = integral negativa',
            'Grid ajuda na leitura',
          ], Icons.visibility),
          const SizedBox(height: 12),
          _buildTopicCard('Controles do Gráfico', [
            'Zoom com scroll do mouse',
            'Pan arrastando o gráfico',
            'Reset com duplo clique',
          ], Icons.control_camera),
          const SizedBox(height: 12),
          _buildTopicCard('Configurações', [
            'Ajuste resolução nas configurações',
            'Maior resolução = mais detalhes',
            'Performance vs qualidade',
          ], Icons.settings),
        ],
      ),
    );
  }

  Widget _buildGuiaDicas() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopicCard('Produtividade', [
            'Use sugestões de funções',
            'Favorite cálculos importantes',
            'Explore o histórico',
          ], Icons.tips_and_updates),
          const SizedBox(height: 12),
          _buildTopicCard('Resolução de Problemas', [
            'Comece com funções simples',
            'Verifique sintaxe das funções',
            'Use exemplos como referência',
          ], Icons.psychology),
          const SizedBox(height: 12),
          _buildTopicCard('Aprendizado', [
            'Compare resultados analíticos',
            'Observe comportamento gráfico',
            'Pratique com diferentes funções',
          ], Icons.school),
        ],
      ),
    );
  }

  Widget _buildTopicCard(String titulo, List<String> itens, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...itens.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursosAdicionais() {
    return SectionCard(
      titulo: 'Recursos Adicionais',
      icon: Icons.extension,
      child: Column(
        children: [
          _buildRecursoCard(
            'Exemplos Interativos',
            'Explore funções pré-definidas com explicações',
            Icons.play_arrow,
            () => context.go('/area'),
          ),
          const SizedBox(height: 12),
          _buildRecursoCard(
            'Configurações',
            'Personalize sua experiência de uso',
            Icons.settings,
            () => context.go('/configuracoes'),
          ),
          const SizedBox(height: 12),
          _buildRecursoCard(
            'Dashboard',
            'Volte ao painel principal',
            Icons.dashboard,
            () => context.go('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursoCard(
    String titulo,
    String descricao,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    descricao,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _passoPrevio() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _proximoPasso() {
    if (_currentStep < _passosTutorial.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _finalizarTutorial() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: const Row(
              children: [
                Icon(Icons.celebration, color: AppColors.success),
                SizedBox(width: 8),
                Text(
                  'Tutorial Concluído!',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: const Text(
              'Parabéns! Você completou o tutorial do IntegraMente. '
              'Agora você está pronto para explorar todas as funcionalidades. '
              'Deseja ir para o Dashboard?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuar aqui'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ir para Dashboard'),
              ),
            ],
          ),
    );
  }

  void _mostrarAjudaRapida(BuildContext context) {
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
                  'Ajuda Rápida',
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
                    'Navegação:\n'
                    '• Use as abas para explorar diferentes tópicos\n'
                    '• Tutorial Interativo: guia passo-a-passo\n'
                    '• Guias Detalhados: referência completa\n\n'
                    'Dicas:\n'
                    '• Comece pelo Tutorial Interativo\n'
                    '• Use os Guias Detalhados como referência\n'
                    '• Explore os Recursos Adicionais\n\n'
                    'Precisa de mais ajuda?\n'
                    '• Vá para Área sob Curva e clique em Ajuda\n'
                    '• Explore as sugestões de funções\n'
                    '• Confira o histórico de cálculos',
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
