import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../core/performance/performance_config.dart';
import '../../core/utils/responsive_helper.dart';
import 'optimized_widgets.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.borderRadiusMedium,
        ),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppConstants.borderRadiusMedium,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

// Widget para criar seções com título
class SectionCard extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    required this.titulo,
    required this.icon,
    required this.child,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          // Content
          child,
        ],
      ),
    );
  }
}

// Widget para informações estatísticas
class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
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
}

class SideMenu extends StatelessWidget {
  final String currentRoute;

  const SideMenu({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.getSideMenuWidth(context),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundCard, AppColors.backgroundSurface],
        ),
        border: Border(right: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        children: [
          // Header do menu
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/icons/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.integration_instructions,
                          color: AppColors.primary,
                          size: 24,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IntegraMente',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Integrais na palma da mão',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              children: [
                _buildMenuItem(
                  context,
                  title: 'Dashboard',
                  subtitle: 'Visão geral',
                  icon: Icons.dashboard,
                  route: '/home',
                  isSelected: currentRoute == '/home',
                ),

                const SizedBox(height: 8),

                _buildMenuItem(
                  context,
                  title: 'Área sob Curva',
                  subtitle: 'Integral definida',
                  icon: Icons.area_chart,
                  route: '/area',
                  isSelected: currentRoute == '/area',
                ),

                const SizedBox(height: 8),

                _buildMenuItem(
                  context,
                  title: 'Cálculo Simbólico',
                  subtitle: 'Derivadas e integrais',
                  icon: Icons.functions,
                  route: '/calculadora',
                  isSelected: currentRoute == '/calculadora',
                ),

                const SizedBox(height: 8),

                _buildMenuItem(
                  context,
                  title: 'Histórico',
                  subtitle: 'Cálculos anteriores',
                  icon: Icons.history,
                  route: '/historico',
                  isSelected: currentRoute == '/historico',
                ),

                const SizedBox(height: 24),

                // Seção de ajuda
                const Divider(color: AppColors.glassBorder),

                const SizedBox(height: 16),

                _buildMenuItem(
                  context,
                  title: 'Tutorial',
                  subtitle: 'Como usar o app',
                  icon: Icons.school,
                  route: '/tutorial',
                  isSelected: currentRoute == '/tutorial',
                ),

                const SizedBox(height: 8),

                _buildMenuItem(
                  context,
                  title: 'Configurações',
                  subtitle: 'Preferências',
                  icon: Icons.settings,
                  route: '/configuracoes',
                  isSelected: currentRoute == '/configuracoes',
                ),
              ],
            ),
          ),

          // Footer com versão
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: const Text(
              'v1.0.0 - FASE 3',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required bool isSelected,
  }) {
    return MenuItemTransition(
      isSelected: isSelected,
      onTap: () => context.go(route),
      child: AdaptiveAnimatedContainer(
        duration: PerformanceConfig.getAnimationDuration(
          isHeavyOperation: false,
        ),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border:
                isSelected
                    ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    )
                    : null,
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// AnimatedPageTransition foi movido para page_transitions.dart
// Use AnimatedPageEntry em seu lugar para melhor funcionalidade

class MenuItemTransition extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const MenuItemTransition({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<MenuItemTransition> createState() => _MenuItemTransitionState();
}

class _MenuItemTransitionState extends State<MenuItemTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: PerformanceConfig.getAnimationDuration(isHeavyOperation: false),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01, // Reduzido para ser mais sutil
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(MenuItemTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != oldWidget.isSelected &&
        !PerformanceConfig.reduceAnimations) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
      return GestureDetector(onTap: widget.onTap, child: widget.child);
    }

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isSelected) {
          _controller.forward();
        }
      },
      onExit: (_) {
        if (!widget.isSelected) {
          _controller.reverse();
        }
      },
      child: GestureDetector(
        onTap: () {
          // Feedback tátil otimizado
          PerformanceConfig.adaptiveHapticFeedback(actionType: 'light');
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

// Widget para estados vazios centralizados
class EmptyStateCard extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData icon;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyStateCard({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.icon,
    this.action,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      titulo: titulo,
      icon: icon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          if (subtitulo != null) ...[
            Text(
              subtitulo!,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          if (action != null)
            action!
          else if (actionLabel != null && onActionPressed != null)
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
