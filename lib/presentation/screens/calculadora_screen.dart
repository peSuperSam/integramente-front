import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../data/models/funcao_matematica.dart';
import '../../data/models/historico_item.dart';
import '../../data/models/calculo_response.dart';
import '../controllers/app_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/teclado_matematico.dart';
import '../widgets/optimized_widgets.dart';
import '../widgets/page_transitions.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final TextEditingController _expressaoController = TextEditingController();
  final TextEditingController _pontoLimiteController = TextEditingController();
  final FocusNode _expressaoFocusNode = FocusNode();
  final FocusNode _pontoLimiteFocusNode = FocusNode();

  String _tipoCalculoSelecionado = 'integral';
  bool _mostrarTeclado = true;

  @override
  void dispose() {
    _expressaoController.dispose();
    _pontoLimiteController.dispose();
    _expressaoFocusNode.dispose();
    _pontoLimiteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer:
          ResponsiveHelper.shouldUseDrawer(context)
              ? const SideMenu(currentRoute: '/calculadora')
              : null,
      appBar:
          ResponsiveHelper.shouldUseDrawer(context)
              ? _buildMobileAppBar()
              : null,
      body: AdaptiveLayout(
        sideMenu: const SideMenu(currentRoute: '/calculadora'),
        currentRoute: '/calculadora',
        body: _buildMainContent(controller),
      ),
    );
  }

  // AppBar para mobile
  AppBar _buildMobileAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Calculadora Simbólica',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      actions: [
        IconButton(
          onPressed: _mostrarAjuda,
          icon: const Icon(Icons.help_outline),
          tooltip: 'Ajuda',
        ),
      ],
    );
  }

  // Conteúdo principal da tela
  Widget _buildMainContent(AppController controller) {
    return AnimatedPageEntry(
      animationType: AnimationType.slideUp,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (!ResponsiveHelper.shouldUseDrawer(context)) _buildDesktopHeader(),

          SliverPadding(
            padding: EdgeInsets.all(
              ResponsiveHelper.getHorizontalPadding(context),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSeletorTipoCalculo(),
                _buildSpacing(),
                _buildCampoExpressao(),
                if (_tipoCalculoSelecionado == 'limite') ...[
                  _buildSpacing(),
                  _buildCampoPontoLimite(),
                ],
                _buildSpacing(),
                _buildToggleTeclado(),
                if (_mostrarTeclado) ...[
                  _buildSpacing(),
                  _buildTecladoMatematico(),
                ],
                _buildSpacing(),
                _buildBotaoCalcular(controller),
                _buildSpacing(),
                _buildAreaResultado(controller),
                _buildSpacing(large: true),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Header para desktop/tablet
  Widget _buildDesktopHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundCard,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.integralColor],
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
                      const Icon(
                        Icons.functions,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calculadora Simbólica',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Resolva integrais, derivadas e limites simbolicamente',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildHeaderActions(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Ações do header
  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeaderButton(
          icon: Icons.history,
          tooltip: 'Histórico',
          onPressed: () => Get.toNamed('/historico'),
        ),
        const SizedBox(width: 8),
        _buildHeaderButton(
          icon: Icons.help_outline,
          tooltip: 'Ajuda',
          onPressed: _mostrarAjuda,
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
      ),
    );
  }

  // Seletor de tipo de cálculo
  Widget _buildSeletorTipoCalculo() {
    return SectionCard(
      titulo: 'Tipo de Operação',
      icon: Icons.category_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione o tipo de cálculo matemático:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildTiposCalculoChips(),
        ],
      ),
    );
  }

  Widget _buildTiposCalculoChips() {
    final tipos = [
      {
        'label': 'Integral',
        'value': 'integral',
        'icon': Icons.functions,
        'color': AppColors.integralColor,
      },
      {
        'label': 'Derivada',
        'value': 'derivada',
        'icon': Icons.trending_up,
        'color': AppColors.functionColor,
      },
      {
        'label': 'Limite',
        'value': 'limite',
        'icon': Icons.arrow_forward,
        'color': AppColors.variableColor,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: tipos.map((tipo) => _buildTipoChip(tipo)).toList(),
    );
  }

  Widget _buildTipoChip(Map<String, dynamic> tipo) {
    final isSelected = _tipoCalculoSelecionado == tipo['value'];
    final color = tipo['color'] as Color;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _tipoCalculoSelecionado = tipo['value'];
        });
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tipo['icon'] as IconData,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(
            tipo['label'],
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color : color.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
      elevation: isSelected ? 2 : 0,
    );
  }

  // Campo de expressão matemática
  Widget _buildCampoExpressao() {
    return SectionCard(
      titulo: 'Expressão Matemática',
      icon: Icons.edit_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCampoTexto(
            controller: _expressaoController,
            focusNode: _expressaoFocusNode,
            hintText: _getHintTextPorTipo(),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildExemplosRapidos(),
        ],
      ),
    );
  }

  // Campo do ponto limite
  Widget _buildCampoPontoLimite() {
    return SectionCard(
      titulo: 'Ponto do Limite',
      icon: Icons.gps_fixed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Digite o valor para o qual x se aproxima:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildCampoTexto(
            controller: _pontoLimiteController,
            focusNode: _pontoLimiteFocusNode,
            hintText: 'Ex: 0, 1, -1, +∞, -∞',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
          ),
          const SizedBox(height: 12),
          _buildChipsPontoLimite(),
        ],
      ),
    );
  }

  Widget _buildChipsPontoLimite() {
    final pontos = ['0', '1', '-1', '+∞', '-∞'];

    return Wrap(
      spacing: 8,
      children:
          pontos.map((ponto) {
            return ActionChip(
              label: Text(ponto, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.variableColor.withValues(alpha: 0.1),
              side: const BorderSide(color: AppColors.variableColor),
              onPressed: () {
                _pontoLimiteController.text = ponto;
                _pontoLimiteFocusNode.requestFocus();
              },
            );
          }).toList(),
    );
  }

  // Campo de texto reutilizável
  Widget _buildCampoTexto({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontSize: 16,
        ),
        filled: true,
        fillColor: AppColors.backgroundSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    controller.clear();
                    setState(() {});
                  },
                )
                : null,
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  // Exemplos rápidos
  Widget _buildExemplosRapidos() {
    final exemplos = _getExemplosPorTipo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exemplos rápidos:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              exemplos.map((exemplo) {
                return ActionChip(
                  label: Text(exemplo, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                  side: const BorderSide(color: AppColors.primary),
                  onPressed: () {
                    _expressaoController.text = exemplo;
                    _expressaoFocusNode.requestFocus();
                    setState(() {});
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  // Toggle do teclado matemático
  Widget _buildToggleTeclado() {
    return SectionCard(
      titulo: 'Teclado Matemático',
      icon: Icons.keyboard,
      trailing: Switch(
        value: _mostrarTeclado,
        onChanged: (value) {
          setState(() {
            _mostrarTeclado = value;
          });
        },
        activeColor: AppColors.primary,
      ),
      child: Text(
        _mostrarTeclado
            ? 'Teclado ativo - use os símbolos abaixo para inserir expressões'
            : 'Teclado oculto - ative para usar símbolos matemáticos',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  // Teclado matemático
  Widget _buildTecladoMatematico() {
    return SectionCard(
      titulo: 'Símbolos Matemáticos',
      icon: Icons.calculate,
      child: TecladoMatematico(
        onInput: _inserirSimbolo,
        onClear: _limparExpressao,
        onBackspace: _apagarCaractere,
      ),
    );
  }

  // Botão de calcular
  Widget _buildBotaoCalcular(AppController controller) {
    final isEnabled =
        _expressaoController.text.trim().isNotEmpty &&
        (_tipoCalculoSelecionado != 'limite' ||
            _pontoLimiteController.text.trim().isNotEmpty);

    return Obx(() {
      final isLoading = controller.isLoading.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          gradient:
              isEnabled && !isLoading
                  ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.integralColor],
                  )
                  : null,
          color:
              !isEnabled || isLoading
                  ? AppColors.textSecondary.withValues(alpha: 0.3)
                  : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isEnabled && !isLoading
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                isEnabled && !isLoading
                    ? () => _executarCalculo(controller)
                    : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Calculando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Icon(_getIconePorTipo(), color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Calcular $_tipoCalculoSelecionado'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Área de resultado
  Widget _buildAreaResultado(AppController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingResult();
      }

      if (!_temResultadoDisponivel(controller)) {
        return _buildEstadoVazio();
      }

      return _buildResultadoCard(controller);
    });
  }

  Widget _buildLoadingResult() {
    return SectionCard(
      titulo: 'Processando...',
      icon: Icons.hourglass_empty,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const OptimizedLoadingWidget(size: 48),
            const SizedBox(height: 16),
            Text(
              'Resolvendo $_tipoCalculoSelecionado...',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return EmptyStateCard(
      titulo: 'Pronto para Calcular',
      subtitulo: _getMensagemEstadoVazio(),
      icon: _getIconePorTipo(),
    );
  }

  Widget _buildResultadoCard(AppController controller) {
    final ultimoItem = _obterUltimoResultado(controller);

    return SectionCard(
      titulo: 'Resultado',
      icon: Icons.check_circle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () => _compartilharResultado(ultimoItem),
            tooltip: 'Compartilhar',
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.primary),
            onPressed: () => _copiarResultado(ultimoItem),
            tooltip: 'Copiar',
          ),
        ],
      ),
      child: _buildConteudoResultado(ultimoItem),
    );
  }

  Widget _buildConteudoResultado(HistoricoItem? item) {
    if (item == null) return const SizedBox.shrink();

    switch (item.tipo) {
      case TipoCalculo.simbolico:
        return _buildResultadoSimbolico(item.resultadoSimbolico);
      case TipoCalculo.derivada:
        return _buildResultadoDerivada(item.resultadoDerivada);
      case TipoCalculo.limite:
        return _buildResultadoLimite(item.resultadoLimite);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildResultadoSimbolico(CalculoSimbolicoResponse? resultado) {
    if (resultado == null || !resultado.sucesso) {
      return _buildWidgetErro(resultado?.erro ?? 'Erro desconhecido');
    }

    return _buildContainerResultado(
      titulo: 'Integral Indefinida',
      resultado: resultado.antiderivada ?? 'Resultado não disponível',
      cor: AppColors.integralColor,
      passos: resultado.passosResolucao,
    );
  }

  Widget _buildResultadoDerivada(CalculoDerivadaResponse? resultado) {
    if (resultado == null || !resultado.sucesso) {
      return _buildWidgetErro(resultado?.erro ?? 'Erro desconhecido');
    }

    return _buildContainerResultado(
      titulo: 'Derivada',
      resultado: resultado.derivada ?? 'Resultado não disponível',
      cor: AppColors.functionColor,
      passos: resultado.passosResolucao,
    );
  }

  Widget _buildResultadoLimite(CalculoLimiteResponse? resultado) {
    if (resultado == null || !resultado.sucesso) {
      return _buildWidgetErro(resultado?.erro ?? 'Erro desconhecido');
    }

    String textoResultado;
    if (resultado.existeLimite && resultado.valorLimite != null) {
      textoResultado = resultado.valorLimite!.toStringAsFixed(6);
    } else {
      textoResultado = 'O limite não existe';
    }

    return _buildContainerResultado(
      titulo: 'Limite',
      resultado: textoResultado,
      cor: AppColors.variableColor,
      passos: resultado.passosResolucao,
      informacaoExtra:
          resultado.pontoLimite != null
              ? 'quando x → ${resultado.pontoLimite!}'
              : null,
    );
  }

  Widget _buildContainerResultado({
    required String titulo,
    required String resultado,
    required Color cor,
    List<String>? passos,
    String? informacaoExtra,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: cor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                resultado,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (informacaoExtra != null) ...[
                const SizedBox(height: 8),
                Text(
                  informacaoExtra,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (passos != null && passos.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildPassosResolucao(passos, cor),
        ],
      ],
    );
  }

  Widget _buildPassosResolucao(List<String> passos, Color cor) {
    return ExpansionTile(
      title: Text(
        'Passos da Resolução (${passos.length})',
        style: TextStyle(color: cor, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      iconColor: cor,
      collapsedIconColor: cor,
      children:
          passos.asMap().entries.map((entry) {
            return ListTile(
              dense: true,
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      color: cor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              title: Text(
                entry.value,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildWidgetErro(String erro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Erro no Cálculo',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  erro,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Espaçamento responsivo
  Widget _buildSpacing({bool large = false}) {
    return SizedBox(
      height: ResponsiveHelper.getResponsiveSpacing(
        context,
        large ? AppConstants.paddingLarge : AppConstants.paddingMedium,
      ),
    );
  }

  // Métodos auxiliares
  String _getHintTextPorTipo() {
    switch (_tipoCalculoSelecionado) {
      case 'integral':
        return 'Ex: x^2, sin(x), e^x, x*ln(x)';
      case 'derivada':
        return 'Ex: x^3 + 2*x^2 + x + 1, sin(x)*cos(x)';
      case 'limite':
        return 'Ex: sin(x)/x, (x^2-1)/(x-1), (e^x-1)/x';
      default:
        return 'Digite uma expressão matemática';
    }
  }

  List<String> _getExemplosPorTipo() {
    switch (_tipoCalculoSelecionado) {
      case 'integral':
        return ['x^2', 'sin(x)', 'e^x', 'x*ln(x)', '1/x', 'sqrt(x)'];
      case 'derivada':
        return ['x^3', 'sin(x)', 'ln(x)', 'e^x', 'tan(x)', 'x^2*sin(x)'];
      case 'limite':
        return ['sin(x)/x', '(x^2-1)/(x-1)', '(e^x-1)/x', '(1-cos(x))/x^2'];
      default:
        return [];
    }
  }

  IconData _getIconePorTipo() {
    switch (_tipoCalculoSelecionado) {
      case 'integral':
        return Icons.functions;
      case 'derivada':
        return Icons.trending_up;
      case 'limite':
        return Icons.arrow_forward;
      default:
        return Icons.calculate;
    }
  }

  String _getMensagemEstadoVazio() {
    switch (_tipoCalculoSelecionado) {
      case 'integral':
        return 'Digite uma função e calcule sua integral indefinida\n\nExemplos: x², sin(x), eˣ, x·ln(x)';
      case 'derivada':
        return 'Digite uma função e calcule sua derivada\n\nExemplos: x³ + 2x², sin(x)·cos(x), ln(x)';
      case 'limite':
        return 'Digite uma função e o ponto do limite\n\nExemplos: sin(x)/x quando x → 0';
      default:
        return 'Selecione um tipo de cálculo e digite uma expressão';
    }
  }

  // Métodos de ação
  void _inserirSimbolo(String simbolo) {
    final texto = _expressaoController.text;
    final selecao = _expressaoController.selection;

    final novoTexto = texto.replaceRange(
      selecao.start.clamp(0, texto.length),
      selecao.end.clamp(0, texto.length),
      simbolo,
    );

    _expressaoController.text = novoTexto;
    _expressaoController.selection = TextSelection.collapsed(
      offset: (selecao.start + simbolo.length).clamp(0, novoTexto.length),
    );

    setState(() {});
  }

  void _limparExpressao() {
    _expressaoController.clear();
    setState(() {});
  }

  void _apagarCaractere() {
    final texto = _expressaoController.text;
    final selecao = _expressaoController.selection;

    if (texto.isNotEmpty && selecao.start > 0) {
      final novoTexto = texto.replaceRange(selecao.start - 1, selecao.end, '');

      _expressaoController.text = novoTexto;
      _expressaoController.selection = TextSelection.collapsed(
        offset: (selecao.start - 1).clamp(0, novoTexto.length),
      );

      setState(() {});
    }
  }

  void _executarCalculo(AppController controller) {
    if (_expressaoController.text.trim().isEmpty) {
      SnackBarUtils.showError(context, 'Digite uma expressão matemática');
      return;
    }

    if (_tipoCalculoSelecionado == 'limite' &&
        _pontoLimiteController.text.trim().isEmpty) {
      SnackBarUtils.showError(context, 'Digite o ponto do limite');
      return;
    }

    final funcao = FuncaoMatematica.criarDaExpressao(_expressaoController.text);
    if (!funcao.isValida) {
      SnackBarUtils.showError(context, 'Expressão matemática inválida');
      return;
    }

    controller.setFuncaoAtual(_expressaoController.text);

    switch (_tipoCalculoSelecionado) {
      case 'integral':
        SnackBarUtils.showCalculationStarted(
          context,
          'integral',
          funcao.expressao,
        );
        controller.calcularSimbolico();
        break;

      case 'derivada':
        SnackBarUtils.showCalculationStarted(
          context,
          'derivada',
          funcao.expressao,
        );
        controller.calcularDerivada();
        break;

      case 'limite':
        final pontoTexto = _pontoLimiteController.text.trim();
        double? pontoLimite = _parseaPontoLimite(pontoTexto);

        if (pontoLimite == null) {
          SnackBarUtils.showError(
            context,
            'Ponto do limite deve ser um número válido ou ±∞',
          );
          return;
        }

        final pontoFormatado = _formataPontoLimite(pontoLimite);
        SnackBarUtils.showCalculationStarted(
          context,
          'limite',
          '${funcao.expressao} quando x → $pontoFormatado',
        );
        controller.calcularLimite(pontoLimite: pontoLimite);
        break;
    }
  }

  double? _parseaPontoLimite(String texto) {
    if (texto == '+∞' || texto == '∞' || texto == 'inf') {
      return double.infinity;
    } else if (texto == '-∞' || texto == '-inf') {
      return double.negativeInfinity;
    } else {
      return double.tryParse(texto);
    }
  }

  String _formataPontoLimite(double ponto) {
    if (ponto.isInfinite) {
      return ponto.isNegative ? '-∞' : '+∞';
    }
    return ponto.toString();
  }

  bool _temResultadoDisponivel(AppController controller) {
    final hasSymbolic =
        controller.historicoSimbolico.isNotEmpty &&
        controller.historicoSimbolico.last.resultadoSimbolico?.sucesso == true;

    final hasDerivada =
        controller.historico.isNotEmpty &&
        controller.historico.last.tipo == TipoCalculo.derivada &&
        controller.historico.last.resultadoDerivada?.sucesso == true;

    final hasLimite =
        controller.historico.isNotEmpty &&
        controller.historico.last.tipo == TipoCalculo.limite &&
        controller.historico.last.resultadoLimite?.sucesso == true;

    return hasSymbolic || hasDerivada || hasLimite;
  }

  HistoricoItem? _obterUltimoResultado(AppController controller) {
    return controller.historico.isNotEmpty ? controller.historico.last : null;
  }

  void _compartilharResultado(HistoricoItem? item) {
    // TODO: Implementar compartilhamento
    SnackBarUtils.showInfo(
      context,
      'Funcionalidade de compartilhamento em desenvolvimento',
    );
  }

  void _copiarResultado(HistoricoItem? item) {
    // TODO: Implementar cópia para clipboard
    SnackBarUtils.showInfo(
      context,
      'Resultado copiado para a área de transferência',
    );
  }

  void _mostrarAjuda() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Como usar a Calculadora',
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
                    'Esta calculadora resolve simbolicamente:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Integrais indefinidas\n'
                    '• Derivadas de funções\n'
                    '• Limites de funções\n\n'
                    'Digite a expressão matemática ou use o teclado virtual.\n\n'
                    'Exemplos de sintaxe:\n'
                    '• x^2 (x ao quadrado)\n'
                    '• sin(x), cos(x), tan(x)\n'
                    '• e^x (exponencial)\n'
                    '• ln(x) (logaritmo natural)\n'
                    '• sqrt(x) (raiz quadrada)',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text('Entendi'),
              ),
            ],
          ),
    );
  }
}
