import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/performance/performance_config.dart';

class LoadingMath extends StatefulWidget {
  final String? message;
  final LoadingType tipo;
  final double size;

  const LoadingMath({
    super.key,
    this.message,
    this.tipo = LoadingType.integral,
    this.size = 80.0,
  });

  @override
  State<LoadingMath> createState() => _LoadingMathState();
}

class _LoadingMathState extends State<LoadingMath>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: PerformanceConfig.getAnimationDuration(isHeavyOperation: false),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (!PerformanceConfig.reduceAnimations) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildLoadingAnimation(),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingAnimation() {
    if (PerformanceConfig.reduceAnimations) {
      return _buildStaticIcon();
    }

    switch (widget.tipo) {
      case LoadingType.integral:
        return _buildIntegralAnimation();
      case LoadingType.grafico:
        return _buildGraficoAnimation();
      case LoadingType.calculo:
        return _buildCalculoAnimation();
      case LoadingType.simbolico:
        return _buildSimbolicoAnimation();
    }
  }

  Widget _buildStaticIcon() {
    IconData icon;
    Color color;

    switch (widget.tipo) {
      case LoadingType.integral:
        icon = Icons.integration_instructions;
        color = AppColors.integralColor;
        break;
      case LoadingType.grafico:
        icon = Icons.show_chart;
        color = AppColors.graphFunction;
        break;
      case LoadingType.calculo:
        icon = Icons.calculate;
        color = AppColors.primary;
        break;
      case LoadingType.simbolico:
        icon = Icons.functions;
        color = AppColors.derivativeColor;
        break;
    }

    return Icon(icon, size: widget.size * 0.5, color: color);
  }

  Widget _buildIntegralAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 6.28, // 2π
          child: Icon(
            Icons.integration_instructions,
            size: widget.size * 0.5,
            color: AppColors.integralColor,
          ),
        );
      },
    );
  }

  Widget _buildGraficoAnimation() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: const Icon(
            Icons.show_chart,
            size: 40,
            color: AppColors.graphFunction,
          ),
        );
      },
    );
  }

  Widget _buildCalculoAnimation() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 6.28,
          child: Container(
            width: widget.size * 0.6,
            height: widget.size * 0.6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calculate, color: Colors.white, size: 24),
          ),
        );
      },
    );
  }

  Widget _buildSimbolicoAnimation() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: const Icon(
            Icons.functions,
            size: 40,
            color: AppColors.derivativeColor,
          ),
        );
      },
    );
  }
}

enum LoadingType { integral, grafico, calculo, simbolico }

// Widget para overlay de loading em tela cheia
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType tipo;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.tipo = LoadingType.calculo,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.backgroundDark.withValues(alpha: 0.8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: LoadingMath(
                  message: message ?? 'Calculando...',
                  tipo: tipo,
                  size: 100,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Widget simples para botão com loading
class BotaoComLoading extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? cor;
  final IconData? icone;

  const BotaoComLoading({
    super.key,
    required this.texto,
    this.onPressed,
    this.isLoading = false,
    this.cor,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon:
          isLoading
              ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    cor ?? AppColors.primary,
                  ),
                ),
              )
              : Icon(icone ?? Icons.calculate),
      label: Text(isLoading ? 'Carregando...' : texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: cor ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}
