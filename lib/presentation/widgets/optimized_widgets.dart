import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/performance/performance_config.dart';
import 'dart:async';

/// Widget otimizado para exibir loading com animação adaptativa
class OptimizedLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const OptimizedLoadingWidget({super.key, this.size = 20.0, this.color});

  @override
  Widget build(BuildContext context) {
    if (PerformanceConfig.reduceAnimations) {
      return Icon(
        Icons.hourglass_empty,
        size: size,
        color: color ?? AppColors.primary,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );
  }
}

/// Widget otimizado para animações adaptativas
class AdaptiveAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration? duration;
  final Curve curve;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const AdaptiveAnimatedContainer({
    super.key,
    required this.child,
    this.duration,
    this.curve = Curves.easeOut,
    this.decoration,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final animationDuration =
        duration ?? PerformanceConfig.adaptiveAnimationDuration;

    if (PerformanceConfig.reduceAnimations) {
      return Container(
        decoration: decoration,
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        child: child,
      );
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: curve,
      decoration: decoration,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Widget otimizado para listas com lazy loading
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Otimizações de performance
      cacheExtent: 1000,
      physics: const BouncingScrollPhysics(),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }
}

/// Widget otimizado para imagens com cache
class OptimizedImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const OptimizedImage({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    return Image.asset(
      imagePath!,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
      errorBuilder: (context, error, stackTrace) {
        return placeholder ??
            const Icon(Icons.error_outline, color: AppColors.error);
      },
    );
  }
}

/// Widget otimizado para botões com feedback tátil
class OptimizedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enableFeedback;

  const OptimizedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.primary,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: InkWell(
        onTap:
            onPressed != null
                ? () {
                  if (enableFeedback) {
                    PerformanceConfig.lightImpact();
                  }
                  onPressed!();
                }
                : null,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}

/// Widget otimizado para entrada de texto com debounce
class OptimizedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Duration debounceDuration;
  final InputDecoration? decoration;

  const OptimizedTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.decoration,
  });

  @override
  State<OptimizedTextField> createState() => _OptimizedTextFieldState();
}

class _OptimizedTextFieldState extends State<OptimizedTextField> {
  Timer? _debounceTimer;

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(value);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged != null ? _onTextChanged : null,
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
    );
  }
}
