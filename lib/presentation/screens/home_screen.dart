import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../controllers/app_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_transitions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer:
          ResponsiveHelper.shouldUseDrawer(context)
              ? const SideMenu(currentRoute: '/home')
              : null,
      appBar:
          ResponsiveHelper.shouldUseDrawer(context)
              ? AppBar(
                backgroundColor: AppColors.backgroundCard,
                title: const Text(
                  'IntegraMente',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
              )
              : null,
      body: AdaptiveLayout(
        sideMenu: const SideMenu(currentRoute: '/home'),
        currentRoute: '/home',
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
                    _buildWelcomeSection(context),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingLarge,
                      ),
                    ),
                    _buildQuickActions(context),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingLarge,
                      ),
                    ),
                    _buildStatsSection(controller),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        AppConstants.paddingLarge,
                      ),
                    ),
                    _buildRecentActivity(controller, context),
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
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bem-vindo ao IntegraMente',
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
          onPressed: () => _showHelp(context),
          icon: const Icon(Icons.help_outline, color: Colors.white),
          tooltip: 'Ajuda',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return SectionCard(
      titulo: 'Início Rápido',
      icon: Icons.rocket_launch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pronto para explorar o Cálculo II? Comece com uma dessas opções:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickChip('Calcular x²', Icons.functions, () {
                Get.find<AppController>().setFuncaoAtual('x^2');
                context.go('/area');
              }),
              _buildQuickChip('Explorar sin(x)', Icons.graphic_eq, () {
                Get.find<AppController>().setFuncaoAtual('sin(x)');
                context.go('/area');
              }),
              _buildQuickChip('Tutorial', Icons.school, () {
                context.go('/tutorial');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: const BorderSide(color: AppColors.primary),
      onPressed: onTap,
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
          crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
          childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(context),
          children: [
            _buildActionCard(
              context,
              'Área sob Curva',
              'Integrais definidas',
              Icons.area_chart,
              AppColors.integralColor,
              '/area',
            ),
            _buildActionCard(
              context,
              'Cálculo Simbólico',
              'Derivadas e integrais',
              Icons.functions,
              AppColors.primary,
              '/calculadora',
            ),
            _buildActionCard(
              context,
              'Histórico',
              'Cálculos anteriores',
              Icons.history,
              AppColors.success,
              '/historico',
            ),
            _buildActionCard(
              context,
              'Configurações',
              'Personalizar app',
              Icons.settings,
              AppColors.warning,
              '/configuracoes',
            ),
            _buildActionCard(
              context,
              'Funcionalidades Avançadas',
              'IA, 3D e Performance',
              Icons.auto_awesome,
              Colors.purple,
              '/advanced-features',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return GlassCard(
      onTap: () => context.go(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
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

  Widget _buildStatsSection(AppController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Cálculos de Área',
                  controller.historicoArea.length.toString(),
                  Icons.area_chart,
                  AppColors.integralColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Cálculos Simbólicos',
                  controller.historicoSimbolico.length.toString(),
                  Icons.functions,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  (controller.historicoArea.length +
                          controller.historicoSimbolico.length)
                      .toString(),
                  Icons.calculate,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
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

  Widget _buildRecentActivity(AppController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Atividade Recente',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.go('/historico'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Ver tudo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final recentItems =
              [...controller.historicoArea, ...controller.historicoSimbolico]
                ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm))
                ..take(3);

          if (recentItems.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children:
                recentItems
                    .map((item) => _buildActivityCard(item, context))
                    .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateCard(
      titulo: 'Nenhuma atividade recente',
      subtitulo: 'Seus cálculos aparecerão aqui',
      icon: Icons.timeline,
      actionLabel: 'Fazer primeiro cálculo',
      onActionPressed: () => context.go('/area'),
    );
  }

  Widget _buildActivityCard(dynamic item, BuildContext context) {
    final isArea = item.tipo.toString().contains('area');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.backgroundSurface,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isArea ? AppColors.integralColor : AppColors.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isArea ? Icons.area_chart : Icons.functions,
            color: isArea ? AppColors.integralColor : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          item.funcao.expressaoFormatada,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          isArea
              ? 'Área: [${item.intervaloA}, ${item.intervaloB}]'
              : 'Cálculo simbólico',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Icon(
          item.calculoComSucesso ? Icons.check_circle : Icons.error,
          color: item.calculoComSucesso ? AppColors.success : AppColors.error,
          size: 16,
        ),
        onTap: () => context.go(isArea ? '/area' : '/calculadora'),
      ),
    );
  }

  void _showHelp(BuildContext context) {
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
              child: Text(
                'IntegraMente - Seu assistente de Cálculo II\n\n'
                '• Use "Área sob Curva" para calcular integrais definidas\n'
                '• Explore "Cálculo Simbólico" para derivadas e integrais\n'
                '• Consulte o "Histórico" para revisar cálculos\n'
                '• Use o menu lateral para navegação rápida\n\n'
                'Dica: Clique nas sugestões para começar rapidamente!',
                style: TextStyle(color: AppColors.textSecondary),
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
