import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive_helper.dart';
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
  final FocusNode _expressaoFocusNode = FocusNode();
  String _tipoCalculo = 'integral';

  @override
  void dispose() {
    _expressaoController.dispose();
    _expressaoFocusNode.dispose();
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
              ? AppBar(
                backgroundColor: AppColors.backgroundCard,
                title: const Text(
                  'Calculadora Simbólica',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
              )
              : null,
      body: AdaptiveLayout(
        sideMenu: const SideMenu(currentRoute: '/calculadora'),
        currentRoute: '/calculadora',
        body: AnimatedPageEntry(
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
                    _buildTipoCalculoCard(),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    _buildExpressaoCard(),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    _buildTecladoMatematico(),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    _buildBotaoCalcular(controller),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingMedium,
                      ),
                    ),
                    Obx(() => _buildResultado(controller)),
                  ]),
                ),
              ),
            ],
          ),
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
              colors: [AppColors.primary, Colors.orange],
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
                    'Calculadora Simbólica',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cálculo de antiderivadas e integrais',
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
          onPressed: () => _mostrarAjuda(context),
          icon: const Icon(Icons.help_outline, color: Colors.white),
          tooltip: 'Ajuda',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTipoCalculoCard() {
    return SectionCard(
      titulo: 'Tipo de Cálculo',
      icon: Icons.category,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione o tipo de operação matemática:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTipoChip('Integral', 'integral', Icons.functions),
              _buildTipoChip('Derivada', 'derivada', Icons.trending_up),
              _buildTipoChip('Limite', 'limite', Icons.arrow_forward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipoChip(String label, String tipo, IconData icon) {
    final isSelected = _tipoCalculo == tipo;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _tipoCalculo = tipo;
        });
      },
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color:
            isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildExpressaoCard() {
    return SectionCard(
      titulo: 'Expressão Matemática',
      icon: Icons.edit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _expressaoController,
            focusNode: _expressaoFocusNode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: const TextStyle(color: AppColors.textSecondary),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.backgroundSurface,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildExemplos(),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (_tipoCalculo) {
      case 'integral':
        return 'Ex: x^2, sin(x), e^x, x*ln(x)';
      case 'derivada':
        return 'Ex: x^3 + 2*x^2 + x + 1';
      case 'limite':
        return 'Ex: (sin(x))/x, (x^2-1)/(x-1)';
      default:
        return 'Digite uma expressão matemática';
    }
  }

  Widget _buildExemplos() {
    final exemplos = _getExemplos();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          exemplos
              .map(
                (exemplo) => ActionChip(
                  label: Text(exemplo, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                  side: const BorderSide(color: AppColors.primary),
                  onPressed: () {
                    _expressaoController.text = exemplo;
                    _expressaoFocusNode.requestFocus();
                  },
                ),
              )
              .toList(),
    );
  }

  List<String> _getExemplos() {
    switch (_tipoCalculo) {
      case 'integral':
        return ['x^2', 'sin(x)', 'e^x', 'x*ln(x)', '1/x'];
      case 'derivada':
        return ['x^3', 'sin(x)', 'ln(x)', 'e^x', 'tan(x)'];
      case 'limite':
        return ['sin(x)/x', '(x^2-1)/(x-1)', '(e^x-1)/x'];
      default:
        return [];
    }
  }

  Widget _buildTecladoMatematico() {
    return SectionCard(
      titulo: 'Teclado Matemático',
      icon: Icons.keyboard,
      child: TecladoMatematico(
        onInput: (symbol) {
          final text = _expressaoController.text;
          final selection = _expressaoController.selection;
          final newText = text.replaceRange(
            selection.start.clamp(0, text.length),
            selection.end.clamp(0, text.length),
            symbol,
          );
          _expressaoController.text = newText;
          _expressaoController.selection = TextSelection.collapsed(
            offset: (selection.start + symbol.length).clamp(0, newText.length),
          );
        },
        onClear: () {
          _expressaoController.clear();
        },
        onBackspace: () {
          final text = _expressaoController.text;
          final selection = _expressaoController.selection;
          if (text.isNotEmpty && selection.start > 0) {
            final newText = text.replaceRange(
              selection.start - 1,
              selection.end,
              '',
            );
            _expressaoController.text = newText;
            _expressaoController.selection = TextSelection.collapsed(
              offset: (selection.start - 1).clamp(0, newText.length),
            );
          }
        },
      ),
    );
  }

  Widget _buildBotaoCalcular(AppController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _calcular(controller),
        icon: const Icon(Icons.calculate),
        label: Text('Calcular ${_tipoCalculo.toUpperCase()}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildResultado(AppController controller) {
    if (!controller.isLoading.value &&
        controller.ultimoResultado.value.isEmpty) {
      return const SizedBox.shrink();
    }

    if (controller.isLoading.value) {
      return SectionCard(
        titulo: 'Calculando...',
        icon: Icons.calculate,
        child: const Center(child: OptimizedLoadingWidget(size: 32)),
      );
    }

    return SectionCard(
      titulo: 'Resultado',
      icon: Icons.check_circle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.integralColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          controller.ultimoResultado.value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  void _calcular(AppController controller) {
    if (_expressaoController.text.trim().isEmpty) {
      SnackBarUtils.showError(context, 'Digite uma expressão matemática');
      return;
    }

    // Simular cálculo por enquanto
    controller.setLoading(true);
    Future.delayed(const Duration(seconds: 2), () {
      controller.setLoading(false);
      controller.setUltimoResultado(
        'Resultado simulado para: ${_expressaoController.text}\n'
        'Tipo: $_tipoCalculo\n'
        '(Em desenvolvimento)',
      );
    });
  }

  void _mostrarAjuda(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: const Text(
              'Ajuda - Calculadora Simbólica',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'Use esta ferramenta para calcular:\n\n'
              '• Integrais indefinidas\n'
              '• Derivadas\n'
              '• Limites\n\n'
              'Digite a expressão ou use o teclado matemático.\n'
              'Exemplos: x^2, sin(x), e^x, ln(x)',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendi'),
              ),
            ],
          ),
    );
  }
}
