import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../controllers/app_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/backend_status_widget.dart';
import '../widgets/loading_math.dart';
import '../widgets/page_transitions.dart';

import '../widgets/grafico_dual.dart';

class AreaScreen extends StatefulWidget {
  const AreaScreen({super.key});

  @override
  State<AreaScreen> createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  final TextEditingController _funcaoController = TextEditingController();
  final TextEditingController _intervaloAController = TextEditingController(
    text: '-2',
  );
  final TextEditingController _intervaloBController = TextEditingController(
    text: '2',
  );
  final FocusNode _funcaoFocusNode = FocusNode();

  bool _showSuggestions = false;
  String _selectedCategory = 'Básicas';
  bool _showReadyMessage = false;

  // Sugestões organizadas por categoria
  final Map<String, List<Map<String, String>>> _sugestoesFuncoes = {
    'Básicas': [
      {'funcao': 'x', 'descricao': 'Função linear simples'},
      {'funcao': 'x^2', 'descricao': 'Parábola básica'},
      {'funcao': 'x^3', 'descricao': 'Função cúbica'},
      {'funcao': '2*x + 1', 'descricao': 'Função afim'},
      {'funcao': 'x^2 - 4', 'descricao': 'Parábola deslocada'},
    ],
    'Trigonométricas': [
      {'funcao': 'sin(x)', 'descricao': 'Função seno'},
      {'funcao': 'cos(x)', 'descricao': 'Função cosseno'},
      {'funcao': 'tan(x)', 'descricao': 'Função tangente'},
      {'funcao': '2*sin(x)', 'descricao': 'Seno com amplitude 2'},
      {'funcao': 'sin(2*x)', 'descricao': 'Seno com frequência dobrada'},
    ],
    'Exponenciais': [
      {'funcao': 'e^x', 'descricao': 'Exponencial natural'},
      {'funcao': '2^x', 'descricao': 'Exponencial base 2'},
      {'funcao': 'e^(-x)', 'descricao': 'Exponencial decrescente'},
      {'funcao': 'x*e^x', 'descricao': 'Produto de x e exponencial'},
    ],
    'Logarítmicas': [
      {'funcao': 'ln(x)', 'descricao': 'Logaritmo natural'},
      {'funcao': 'log(x)', 'descricao': 'Logaritmo base 10'},
      {'funcao': 'x*ln(x)', 'descricao': 'Produto de x e ln(x)'},
    ],
    'Radicais': [
      {'funcao': 'sqrt(x)', 'descricao': 'Raiz quadrada'},
      {'funcao': 'sqrt(4-x^2)', 'descricao': 'Semicírculo'},
      {'funcao': 'x*sqrt(x)', 'descricao': 'x vezes raiz de x'},
    ],
    'Compostas': [
      {'funcao': 'x^2 + 2*x + 1', 'descricao': 'Trinômio quadrado perfeito'},
      {'funcao': 'sin(x)*cos(x)', 'descricao': 'Produto de seno e cosseno'},
      {'funcao': 'x*sin(x)', 'descricao': 'Produto de x e seno'},
      {'funcao': 'e^x * sin(x)', 'descricao': 'Produto exponencial e seno'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _funcaoFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _funcaoFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _funcaoController.dispose();
    _intervaloAController.dispose();
    _intervaloBController.dispose();
    _funcaoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer:
          ResponsiveHelper.shouldUseDrawer(context)
              ? const SideMenu(currentRoute: '/area')
              : null,
      appBar:
          ResponsiveHelper.shouldUseDrawer(context)
              ? AppBar(
                backgroundColor: AppColors.backgroundCard,
                title: const Text(
                  'Área sob a Curva',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
                actions: [
                  const BackendStatusIndicator(),
                  const SizedBox(width: 8),
                ],
              )
              : null,
      body: AdaptiveLayout(
        sideMenu: const SideMenu(currentRoute: '/area'),
        currentRoute: '/area',
        body: Row(
          children: [
            // Conteúdo principal com animação
            Expanded(
              flex: 3,
              child: AnimatedPageEntry(
                animationType: AnimationType.slideUp,
                child: CustomScrollView(
                  slivers: [
                    if (!ResponsiveHelper.shouldUseDrawer(context))
                      _buildAppBar(context),
                    SliverPadding(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.getHorizontalPadding(context),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Card de entrada da função com sugestões
                          _buildFuncaoInputCard(controller),

                          SizedBox(
                            height: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              AppConstants.paddingMedium,
                            ),
                          ),

                          // Card de configuração do intervalo
                          _buildIntervaloCard(controller),

                          SizedBox(
                            height: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              AppConstants.paddingMedium,
                            ),
                          ),

                          // Botão de calcular
                          _buildCalcularButton(controller),

                          SizedBox(
                            height: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              AppConstants.paddingMedium,
                            ),
                          ),

                          // Resultado
                          Obx(() => _buildResultado(controller)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Painel lateral de sugestões (quando visível)
            if (_showSuggestions && !ResponsiveHelper.isMobile(context))
              Container(
                width: ResponsiveHelper.getSuggestionsPanelWidth(context),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundCard,
                  border: Border(
                    left: BorderSide(color: AppColors.glassBorder),
                  ),
                ),
                child: _buildSuggestionPanel(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
                    'Área sob a Curva',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Integral definida',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        const BackendStatusIndicator(),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _mostrarAjuda,
          icon: const Icon(Icons.help_outline, color: Colors.white),
          tooltip: 'Ajuda',
        ),
        IconButton(
          onPressed: _mostrarExemplosEducativos,
          icon: const Icon(Icons.school, color: Colors.white),
          tooltip: 'Conceitos',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFuncaoInputCard(AppController controller) {
    return SectionCard(
      titulo: 'Função Matemática',
      icon: Icons.functions,
      trailing: IconButton(
        icon: Icon(
          _showSuggestions ? Icons.close : Icons.lightbulb_outline,
          color: AppColors.primary,
        ),
        onPressed: () {
          setState(() {
            _showSuggestions = !_showSuggestions;
            if (_showSuggestions) {
              _funcaoFocusNode.requestFocus();
            } else {
              _funcaoFocusNode.unfocus();
            }
          });
        },
        tooltip: _showSuggestions ? 'Fechar sugestões' : 'Ver sugestões',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _funcaoController,
            focusNode: _funcaoFocusNode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: x^2, sin(x), e^x, x^3 - 2*x + 1',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.backgroundSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(Icons.functions, color: AppColors.primary),
              suffixIcon:
                  _funcaoController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _funcaoController.clear();
                          controller.clearFuncaoAtual();
                        },
                      )
                      : null,
            ),
            onChanged: (value) {
              controller.setFuncaoAtual(value);

              // Mostrar mensagem "Pronto para calcular" temporariamente
              if (_canCalculate()) {
                setState(() {
                  _showReadyMessage = true;
                });

                // Esconder a mensagem após 2 segundos
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _showReadyMessage = false;
                    });
                  }
                });
              } else {
                setState(() {
                  _showReadyMessage = false;
                });
              }
            },
          ),

          const SizedBox(height: 12),

          // Chips de sugestões rápidas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSuggestionChip('x^2', 'Parábola'),
              _buildQuickSuggestionChip('sin(x)', 'Seno'),
              _buildQuickSuggestionChip('e^x', 'Exponencial'),
              _buildQuickSuggestionChip('ln(x)', 'Logaritmo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestionChip(String funcao, String label) {
    return ActionChip(
      label: Text(
        '$label ($funcao)',
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: const BorderSide(color: AppColors.primary),
      onPressed: () {
        _funcaoController.text = funcao;
        Get.find<AppController>().setFuncaoAtual(funcao);

        // Mostrar mensagem "Pronto para calcular" temporariamente
        if (_canCalculate()) {
          setState(() {
            _showReadyMessage = true;
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showReadyMessage = false;
              });
            }
          });
        }

        // Feedback visual sutil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Função definida: $funcao'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildIntervaloCard(AppController controller) {
    return SectionCard(
      titulo: 'Intervalo de Integração',
      icon: Icons.straighten,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: AppColors.primary),
        onSelected: (value) {
          final parts = value.split(',');
          final a = double.parse(parts[0]);
          final b = double.parse(parts[1]);
          _setIntervalo(a, b, controller);
        },
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: '-5,5',
                child: Text('[-5, 5] - Padrão'),
              ),
              const PopupMenuItem(
                value: '-2,2',
                child: Text('[-2, 2] - Compacto'),
              ),
              const PopupMenuItem(
                value: '0,10',
                child: Text('[0, 10] - Positivo'),
              ),
              const PopupMenuItem(
                value: '0,6.28',
                child: Text('[0, 2π] - Trigonométrico'),
              ),
              const PopupMenuItem(
                value: '-3.14,3.14',
                child: Text('[-π, π] - Simétrico'),
              ),
            ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _intervaloAController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Limite inferior (a)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.backgroundSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.arrow_downward,
                      color: AppColors.integralColor,
                    ),
                  ),
                  onChanged: (value) {
                    final doubleValue = double.tryParse(value);
                    if (doubleValue != null) {
                      controller.setIntervaloA(doubleValue);
                    }

                    // Mostrar mensagem "Pronto para calcular" temporariamente
                    if (_canCalculate()) {
                      setState(() {
                        _showReadyMessage = true;
                      });

                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _showReadyMessage = false;
                          });
                        }
                      });
                    } else {
                      setState(() {
                        _showReadyMessage = false;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _intervaloBController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Limite superior (b)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.backgroundSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.arrow_upward,
                      color: AppColors.integralColor,
                    ),
                  ),
                  onChanged: (value) {
                    final doubleValue = double.tryParse(value);
                    if (doubleValue != null) {
                      controller.setIntervaloB(doubleValue);
                    }

                    // Mostrar mensagem "Pronto para calcular" temporariamente
                    if (_canCalculate()) {
                      setState(() {
                        _showReadyMessage = true;
                      });

                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _showReadyMessage = false;
                          });
                        }
                      });
                    } else {
                      setState(() {
                        _showReadyMessage = false;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Preview do intervalo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.integralColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.integration_instructions,
                  color: AppColors.integralColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '∫[${_intervaloAController.text}, ${_intervaloBController.text}] f(x) dx',
                  style: const TextStyle(
                    color: AppColors.integralColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcularButton(AppController controller) {
    return Obx(
      () => Column(
        children: [
          // Mensagem "Pronto para calcular" temporária
          if (_showReadyMessage && _canCalculate())
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pronto para calcular',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'f(x) = ${_funcaoController.text}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Botão sempre disponível
          BotaoComLoading(
            texto: 'Calcular Área',
            onPressed: _calcular,
            isLoading: controller.isLoading.value,
            cor: AppColors.integralColor,
            icone: Icons.calculate,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header do painel
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Sugestões de Funções',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    _showSuggestions = false;
                    _funcaoFocusNode.unfocus();
                  });
                },
              ),
            ],
          ),
        ),

        // Categorias
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                _sugestoesFuncoes.keys.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      backgroundColor: AppColors.backgroundSurface,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                }).toList(),
          ),
        ),

        // Status de validação mais simples
        if (_funcaoController.text.isNotEmpty && _showReadyMessage)
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pronto para calcular!',
                    style: TextStyle(color: AppColors.success, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // Lista de sugestões
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: _sugestoesFuncoes[_selectedCategory]?.length ?? 0,
            itemBuilder: (context, index) {
              final sugestao = _sugestoesFuncoes[_selectedCategory]![index];
              return _buildSuggestionCard(sugestao);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, String> sugestao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.backgroundSurface,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.functions,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          sugestao['funcao']!,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          sugestao['descricao']!,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        onTap: () {
          _funcaoController.text = sugestao['funcao']!;
          Get.find<AppController>().setFuncaoAtual(sugestao['funcao']!);
          _funcaoFocusNode.requestFocus();

          // Mostrar mensagem "Pronto para calcular" temporariamente
          if (_canCalculate()) {
            setState(() {
              _showReadyMessage = true;
            });

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _showReadyMessage = false;
                });
              }
            });
          }

          // Feedback visual
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Função selecionada: ${sugestao['funcao']!}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: AppColors.integralColor),
          onPressed: () {
            _funcaoController.text = sugestao['funcao']!;
            Get.find<AppController>().setFuncaoAtual(sugestao['funcao']!);

            // Calcular automaticamente
            _calcular();
          },
          tooltip: 'Aplicar e calcular',
        ),
      ),
    );
  }

  Widget _buildResultado(AppController controller) {
    if (controller.erro.isNotEmpty) {
      return _buildErrorCard(controller.erro);
    }

    final historico = controller.historicoArea;
    if (historico.isEmpty) {
      return _buildEmptyState();
    }

    final ultimoCalculo = historico.first;
    return _buildResultCard(ultimoCalculo);
  }

  Widget _buildErrorCard(String erro) {
    return SectionCard(
      titulo: 'Erro',
      icon: Icons.error_outline,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(erro, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateCard(
      titulo: 'Resultado',
      subtitulo: 'Digite uma função e clique em calcular',
      icon: Icons.area_chart,
    );
  }

  Widget _buildResultCard(dynamic ultimoCalculo) {
    return SectionCard(
      titulo: 'Resultado do Cálculo',
      icon: ultimoCalculo.calculoComSucesso ? Icons.check_circle : Icons.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Função e intervalo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'f(x) = ${ultimoCalculo.funcao.expressaoFormatada}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Intervalo: [${ultimoCalculo.intervaloA}, ${ultimoCalculo.intervaloB}]',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (ultimoCalculo.calculoComSucesso) ...[
            // Gráfico Dual (API + Interativo)
            GraficoDual(
              resultadoCalculo: ultimoCalculo.resultadoArea,
              funcao: ultimoCalculo.funcao,
              intervaloA: ultimoCalculo.intervaloA?.toDouble(),
              intervaloB: ultimoCalculo.intervaloB?.toDouble(),
              areaCalculada: ultimoCalculo.resultadoArea?.areaTotal,
            ),
            const SizedBox(height: 16),

            // Resultados
            Row(
              children: [
                Expanded(
                  child: _buildResultMetric(
                    'Área Total',
                    ultimoCalculo.resultadoArea?.areaTotal?.toStringAsFixed(
                          6,
                        ) ??
                        'N/A',
                    Icons.area_chart,
                    AppColors.integralColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResultMetric(
                    'Valor Integral',
                    ultimoCalculo.resultadoArea?.valorIntegral?.toStringAsFixed(
                          6,
                        ) ??
                        'N/A',
                    Icons.functions,
                    AppColors.primary,
                  ),
                ),
                if (ultimoCalculo.resultadoArea?.erroEstimado != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildResultMetric(
                      'Erro Estimado',
                      ultimoCalculo.resultadoArea!.erroEstimado!
                          .toStringAsExponential(2),
                      Icons.precision_manufacturing,
                      AppColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ultimoCalculo.descricaoResultado,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _setIntervalo(double a, double b, AppController controller) {
    _intervaloAController.text = a.toString();
    _intervaloBController.text = b.toString();
    controller.setIntervalo(a, b);
  }

  bool _canCalculate() {
    if (_funcaoController.text.trim().isEmpty) return false;
    if (_intervaloAController.text.trim().isEmpty) return false;
    if (_intervaloBController.text.trim().isEmpty) return false;

    final a = double.tryParse(_intervaloAController.text);
    final b = double.tryParse(_intervaloBController.text);

    return a != null && b != null && a < b;
  }

  void _calcular() {
    final controller = Get.find<AppController>();

    // Validação com aviso se não houver função
    if (_funcaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: AppColors.warning),
              SizedBox(width: 12),
              Text('Digite uma função matemática antes de calcular'),
            ],
          ),
          backgroundColor: AppColors.warning.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validação dos intervalos com valores padrão se não informados
    double a = -2;
    double b = 2;

    if (_intervaloAController.text.isNotEmpty) {
      a = double.tryParse(_intervaloAController.text) ?? -2;
    } else {
      _intervaloAController.text = a.toString();
    }

    if (_intervaloBController.text.isNotEmpty) {
      b = double.tryParse(_intervaloBController.text) ?? 2;
    } else {
      _intervaloBController.text = b.toString();
    }

    // Verificar se a <= b
    if (a >= b) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: AppColors.error),
              SizedBox(width: 12),
              Text('O limite inferior deve ser menor que o superior'),
            ],
          ),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    controller.setIntervalo(a, b);

    // Feedback visual melhorado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Calculando ∫[${a.toString()}, ${b.toString()}] ${_funcaoController.text} dx...',
            ),
          ],
        ),
        backgroundColor: AppColors.integralColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    controller.calcularArea();
  }

  void _mostrarAjuda() {
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
                  'Como usar',
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
                    '1. Digite uma função matemática usando x como variável\n'
                    '2. Configure o intervalo [a, b] de integração\n'
                    '3. Clique em "Calcular Área" para obter o resultado\n\n'
                    'Funções suportadas:\n'
                    '• Polinômios: x^2, x^3, 2*x + 1\n'
                    '• Trigonométricas: sin(x), cos(x), tan(x)\n'
                    '• Exponenciais: e^x, 2^x\n'
                    '• Logarítmicas: ln(x), log(x)\n'
                    '• Raiz quadrada: sqrt(x)\n\n'
                    'Use o painel de sugestões para explorar exemplos!',
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

  void _mostrarExemplosEducativos() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: const Row(
              children: [
                Icon(Icons.school, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Conceitos de Cálculo II',
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
                    'Integral Definida:\n'
                    'A integral definida ∫[a,b] f(x) dx representa a área entre a curva f(x) e o eixo x, no intervalo [a,b].\n\n'
                    'Exemplos interessantes:\n\n'
                    '• x² em [-1,1]: Parábola simétrica\n'
                    '• sin(x) em [0,π]: Semicírculo do seno\n'
                    '• e^x em [0,1]: Crescimento exponencial\n'
                    '• 1/x em [1,e]: Logaritmo natural\n\n'
                    'Interpretação Geométrica:\n'
                    'O resultado representa a área líquida, considerando regiões acima do eixo x como positivas e abaixo como negativas.',
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
