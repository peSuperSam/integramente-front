import 'package:flutter/material.dart';
import '../../core/performance/performance_config.dart';

/// Sistema de animações de página reutilizáveis
class PageTransitions {
  static const Duration defaultDuration = Duration(milliseconds: 800);
  static const Duration quickDuration = Duration(milliseconds: 400);
  static const Duration slowDuration = Duration(milliseconds: 1200);
}

/// Widget principal para animações de entrada de página
class AnimatedPageEntry extends StatefulWidget {
  final Widget child;
  final String? pageKey;
  final Duration? duration;
  final AnimationType animationType;
  final bool autoStart;
  final VoidCallback? onComplete;

  const AnimatedPageEntry({
    super.key,
    required this.child,
    this.pageKey,
    this.duration,
    this.animationType = AnimationType.fadeIn,
    this.autoStart = true,
    this.onComplete,
  });

  @override
  State<AnimatedPageEntry> createState() => _AnimatedPageEntryState();
}

class _AnimatedPageEntryState extends State<AnimatedPageEntry>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    final duration =
        widget.duration ??
        PerformanceConfig.getAnimationDuration(isHeavyOperation: false);

    _controller = AnimationController(duration: duration, vsync: this);

    // Configurar todas as animações
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  void _startAnimation() {
    if (!PerformanceConfig.reduceAnimations && mounted) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedPageEntry oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reiniciar animação se a chave da página mudou
    if (oldWidget.pageKey != widget.pageKey && widget.pageKey != null) {
      _controller.reset();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PerformanceConfig.reduceAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildAnimatedChild();
      },
    );
  }

  Widget _buildAnimatedChild() {
    switch (widget.animationType) {
      case AnimationType.fadeIn:
        return FadeTransition(opacity: _fadeAnimation, child: widget.child);

      case AnimationType.slideUp:
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
        );

      case AnimationType.scaleIn:
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
        );

      case AnimationType.slideAndScale:
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
          ),
        );

      case AnimationType.rotateIn:
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
          ),
        );

      case AnimationType.elasticSlide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: widget.child,
        );
    }
  }
}

/// Tipos de animação disponíveis
enum AnimationType {
  fadeIn,
  slideUp,
  scaleIn,
  slideAndScale,
  rotateIn,
  elasticSlide,
}

/// Widget específico para animações de cards
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final bool autoStart;

  const AnimatedCard({
    super.key,
    required this.child,
    this.delay,
    this.duration,
    this.autoStart = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    final duration = widget.duration ?? PageTransitions.defaultDuration;

    _controller = AnimationController(duration: duration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (PerformanceConfig.reduceAnimations) {
      _controller.value = 1.0;
      return;
    }

    final delay = widget.delay ?? Duration.zero;

    if (delay != Duration.zero) {
      Future.delayed(delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PerformanceConfig.reduceAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
        );
      },
    );
  }
}

/// Widget para animações de lista (items aparecem em sequência)
class AnimatedListBuilder extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration itemDelay;
  final Duration? itemDuration;
  final bool reverse;

  const AnimatedListBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemDelay = const Duration(milliseconds: 100),
    this.itemDuration,
    this.reverse = false,
  });

  @override
  State<AnimatedListBuilder> createState() => _AnimatedListBuilderState();
}

class _AnimatedListBuilderState extends State<AnimatedListBuilder> {
  final List<bool> _itemsVisible = [];

  @override
  void initState() {
    super.initState();
    _itemsVisible.addAll(List.filled(widget.itemCount, false));
    _startSequentialAnimation();
  }

  void _startSequentialAnimation() {
    if (PerformanceConfig.reduceAnimations) {
      setState(() {
        for (int i = 0; i < _itemsVisible.length; i++) {
          _itemsVisible[i] = true;
        }
      });
      return;
    }

    final indices =
        widget.reverse
            ? List.generate(widget.itemCount, (i) => widget.itemCount - 1 - i)
            : List.generate(widget.itemCount, (i) => i);

    for (int i = 0; i < indices.length; i++) {
      final delay = widget.itemDelay * i;

      Future.delayed(delay, () {
        if (mounted && indices[i] < _itemsVisible.length) {
          setState(() {
            _itemsVisible[indices[i]] = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return AnimatedCard(
          autoStart:
              _itemsVisible.length > index ? _itemsVisible[index] : false,
          duration: widget.itemDuration,
          child: widget.itemBuilder(context, index),
        );
      }),
    );
  }
}

/// Widget para animação de mudança de conteúdo
class AnimatedContentSwitcher extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final AnimationType switchType;

  const AnimatedContentSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.switchType = AnimationType.fadeIn,
  });

  @override
  State<AnimatedContentSwitcher> createState() =>
      _AnimatedContentSwitcherState();
}

class _AnimatedContentSwitcherState extends State<AnimatedContentSwitcher> {
  @override
  Widget build(BuildContext context) {
    if (PerformanceConfig.reduceAnimations) {
      return widget.child;
    }

    return AnimatedSwitcher(
      duration: widget.duration,
      transitionBuilder: (child, animation) {
        switch (widget.switchType) {
          case AnimationType.fadeIn:
            return FadeTransition(opacity: animation, child: child);

          case AnimationType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );

          case AnimationType.scaleIn:
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );

          default:
            return FadeTransition(opacity: animation, child: child);
        }
      },
      child: widget.child,
    );
  }
}

/// Widget para animar status/loading states
class AnimatedStatusWidget extends StatefulWidget {
  final Widget? loadingWidget;
  final Widget? successWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final AnimatedStatus status;
  final Duration duration;

  const AnimatedStatusWidget({
    super.key,
    required this.status,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
    this.emptyWidget,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedStatusWidget> createState() => _AnimatedStatusWidgetState();
}

class _AnimatedStatusWidgetState extends State<AnimatedStatusWidget> {
  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (widget.status) {
      case AnimatedStatus.loading:
        currentWidget =
            widget.loadingWidget ??
            const Center(child: CircularProgressIndicator());
        break;
      case AnimatedStatus.success:
        currentWidget = widget.successWidget ?? const SizedBox.shrink();
        break;
      case AnimatedStatus.error:
        currentWidget =
            widget.errorWidget ??
            const Center(child: Icon(Icons.error, color: Colors.red));
        break;
      case AnimatedStatus.empty:
        currentWidget = widget.emptyWidget ?? const SizedBox.shrink();
        break;
    }

    return AnimatedContentSwitcher(
      duration: widget.duration,
      switchType: AnimationType.fadeIn,
      child: Container(key: ValueKey(widget.status), child: currentWidget),
    );
  }
}

enum AnimatedStatus { loading, success, error, empty }

/// Extensão para facilitar o uso das animações
extension AnimatedPageEntryExtension on Widget {
  /// Adiciona animação de entrada à página
  Widget withPageAnimation({
    String? pageKey,
    Duration? duration,
    AnimationType type = AnimationType.fadeIn,
    bool autoStart = true,
    VoidCallback? onComplete,
  }) {
    return AnimatedPageEntry(
      pageKey: pageKey,
      duration: duration,
      animationType: type,
      autoStart: autoStart,
      onComplete: onComplete,
      child: this,
    );
  }

  /// Adiciona animação de card
  Widget withCardAnimation({
    Duration? delay,
    Duration? duration,
    bool autoStart = true,
  }) {
    return AnimatedCard(
      delay: delay,
      duration: duration,
      autoStart: autoStart,
      child: this,
    );
  }
}

/// Mixin para telas que usam animações
mixin AnimatedPageMixin<T extends StatefulWidget> on State<T> {
  AnimationController? _pageAnimationController;
  Animation<double>? _pageOpacity;
  Animation<Offset>? _pageSlide;

  /// Getter para o controller (deve ser implementado pela classe que usa o mixin)
  TickerProvider get tickerProvider;

  /// Inicializar animações da página
  void initPageAnimations({Duration? duration, Curve curve = Curves.easeOut}) {
    final animDuration =
        duration ??
        PerformanceConfig.getAnimationDuration(isHeavyOperation: false);

    _pageAnimationController = AnimationController(
      duration: animDuration,
      vsync: tickerProvider,
    );

    _pageOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pageAnimationController!, curve: curve));

    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageAnimationController!, curve: curve));
  }

  /// Iniciar animação da página
  void startPageAnimation() {
    if (!PerformanceConfig.reduceAnimations &&
        mounted &&
        _pageAnimationController != null) {
      _pageAnimationController!.forward();
    } else if (_pageAnimationController != null) {
      _pageAnimationController!.value = 1.0;
    }
  }

  /// Widget animado para o conteúdo da página
  Widget buildAnimatedPageContent(Widget child) {
    if (PerformanceConfig.reduceAnimations ||
        _pageOpacity == null ||
        _pageSlide == null) {
      return child;
    }

    return SlideTransition(
      position: _pageSlide!,
      child: FadeTransition(opacity: _pageOpacity!, child: child),
    );
  }

  /// Dispose das animações (deve ser chamado no dispose da classe)
  void disposePageAnimations() {
    _pageAnimationController?.dispose();
  }
}
