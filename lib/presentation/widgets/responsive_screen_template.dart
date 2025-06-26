import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import 'glass_card.dart';
import 'page_transitions.dart';

/// Template de tela responsiva para ser usado como base
class ResponsiveScreenTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final String currentRoute;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScreenTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentRoute,
    required this.children,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,

      // Drawer para mobile
      drawer:
          ResponsiveHelper.shouldUseDrawer(context)
              ? const SideMenu(currentRoute: '/home')
              : null,

      // AppBar para mobile
      appBar:
          ResponsiveHelper.shouldUseDrawer(context)
              ? AppBar(
                backgroundColor: AppColors.backgroundCard,
                title: Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
                actions: actions,
              )
              : null,

      // FAB responsivo
      floatingActionButton: floatingActionButton,

      // Corpo adaptativo
      body: AdaptiveLayout(
        sideMenu: SideMenu(currentRoute: currentRoute),
        currentRoute: currentRoute,
        body: AnimatedPageEntry(
          animationType: AnimationType.slideUp,
          child: CustomScrollView(
            slivers: [
              // AppBar para tablet/desktop
              if (!ResponsiveHelper.shouldUseDrawer(context))
                _buildAppBar(context),

              // Conteúdo principal
              SliverPadding(
                padding: EdgeInsets.all(
                  ResponsiveHelper.getHorizontalPadding(context),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildResponsiveContent(context),
                  ),
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
      expandedHeight: ResponsiveHelper.getAppBarHeight(context),
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
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                ResponsiveHelper.getHorizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        28,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(context, 4),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: actions,
    );
  }

  List<Widget> _buildResponsiveContent(BuildContext context) {
    final List<Widget> responsiveChildren = [];

    for (int i = 0; i < children.length; i++) {
      responsiveChildren.add(children[i]);

      // Adicionar espaçamento responsivo entre elementos
      if (i < children.length - 1) {
        responsiveChildren.add(
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              AppConstants.paddingMedium,
            ),
          ),
        );
      }
    }

    return responsiveChildren;
  }
}

/// Widget para grid responsivo
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing:
          mainAxisSpacing ?? ResponsiveHelper.getResponsiveSpacing(context, 16),
      crossAxisSpacing:
          crossAxisSpacing ??
          ResponsiveHelper.getResponsiveSpacing(context, 16),
      childAspectRatio:
          childAspectRatio ?? ResponsiveHelper.getGridChildAspectRatio(context),
      children: children,
    );
  }
}

/// Card responsivo para métricas
class ResponsiveMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ResponsiveMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsiveSpacing(context, 16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: ResponsiveHelper.getResponsiveSpacing(context, 24),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveSpacing(context, 8),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exemplo de uso do template responsivo
class ExemploTela extends StatelessWidget {
  const ExemploTela({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScreenTemplate(
      title: 'Exemplo Responsivo',
      subtitle: 'Template adaptativo',
      currentRoute: '/exemplo',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.help_outline, color: Colors.white),
        ),
      ],
      children: [
        // Seção de cards
        ResponsiveGrid(
          children: [
            const ResponsiveMetricCard(
              title: 'Total',
              value: '42',
              icon: Icons.calculate,
              color: AppColors.primary,
            ),
            const ResponsiveMetricCard(
              title: 'Sucesso',
              value: '95%',
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
            const ResponsiveMetricCard(
              title: 'Média',
              value: '8.5',
              icon: Icons.trending_up,
              color: AppColors.warning,
            ),
          ],
        ),

        // Seção de conteúdo
        SectionCard(
          titulo: 'Conteúdo Adaptativo',
          icon: Icons.devices,
          child: ResponsiveBuilder(
            builder: (context, deviceType) {
              switch (deviceType) {
                case DeviceType.mobile:
                  return const Column(
                    children: [
                      Text('Layout para Mobile'),
                      Text('Uma coluna, compacto'),
                    ],
                  );
                case DeviceType.tablet:
                  return const Row(
                    children: [
                      Expanded(child: Text('Layout para Tablet')),
                      Expanded(child: Text('Duas colunas balanceadas')),
                    ],
                  );
                case DeviceType.desktop:
                  return const Row(
                    children: [
                      Expanded(child: Text('Layout para Desktop')),
                      Expanded(child: Text('Três colunas')),
                      Expanded(child: Text('Máximo aproveitamento')),
                    ],
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
