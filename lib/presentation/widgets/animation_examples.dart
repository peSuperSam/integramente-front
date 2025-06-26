import 'package:flutter/material.dart';
import 'page_transitions.dart';
import '../../core/constants/app_colors.dart';

/// Exemplos de uso do sistema de animações
///
/// Este arquivo demonstra como usar as animações reutilizáveis em diferentes cenários
class AnimationExamples extends StatelessWidget {
  const AnimationExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Exemplos de Animações'),
        backgroundColor: AppColors.primary,
      ),
      body: AnimatedPageEntry(
        animationType: AnimationType.slideUp,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Exemplo 1: Entrada básica de página
            _buildExample(
              'Entrada Básica de Página',
              'Animação simples de fade in',
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Página com fadeIn')),
              ).withPageAnimation(type: AnimationType.fadeIn),
            ),

            const SizedBox(height: 24),

            // Exemplo 2: Slide up com escala
            _buildExample(
              'Slide com Escala',
              'Combina slide up com scale para efeito suave',
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.integralColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Slide + Scale')),
              ).withPageAnimation(type: AnimationType.slideAndScale),
            ),

            const SizedBox(height: 24),

            // Exemplo 3: Cards com delay
            _buildExample(
              'Cards com Delay',
              'Múltiplos cards aparecendo em sequência',
              Column(
                children: List.generate(3, (index) {
                  return Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('Card ${index + 1}')),
                  ).withCardAnimation(
                    delay: Duration(milliseconds: 200 * index),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Exemplo 4: Lista animada
            _buildExample(
              'Lista Animada',
              'Items aparecem em sequência automaticamente',
              AnimatedListBuilder(
                itemCount: 4,
                itemDelay: const Duration(milliseconds: 150),
                itemBuilder: (context, index) {
                  return Container(
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('Item da Lista ${index + 1}')),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Exemplo 5: Rotação
            _buildExample(
              'Rotação Suave',
              'Entrada com rotação e escala',
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.derivativeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.refresh,
                  size: 40,
                  color: AppColors.derivativeColor,
                ),
              ).withPageAnimation(type: AnimationType.rotateIn),
            ),

            const SizedBox(height: 24),

            // Exemplo 6: Switch de conteúdo
            _buildExample(
              'Switch de Conteúdo',
              'Troca suave entre diferentes widgets',
              _AnimatedContentExample(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExample(String title, String description, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Exemplo de widget que demonstra mudança de conteúdo
class _AnimatedContentExample extends StatefulWidget {
  @override
  State<_AnimatedContentExample> createState() =>
      _AnimatedContentExampleState();
}

class _AnimatedContentExampleState extends State<_AnimatedContentExample> {
  int _currentIndex = 0;
  final List<Widget> _contents = [
    Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('Conteúdo 1')),
    ),
    Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('Conteúdo 2')),
    ),
    Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('Conteúdo 3')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContentSwitcher(
          switchType: AnimationType.slideUp,
          child: Container(
            key: ValueKey(_currentIndex),
            child: _contents[_currentIndex],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = (_currentIndex - 1) % _contents.length;
                });
              },
              child: const Text('Anterior'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = (_currentIndex + 1) % _contents.length;
                });
              },
              child: const Text('Próximo'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Documentação de uso das animações
/// 
/// ## Como usar animações de página:
/// 
/// ### 1. Entrada básica de página:
/// ```dart
/// Widget build(BuildContext context) {
///   return Scaffold(
///     body: AnimatedPageEntry(
///       animationType: AnimationType.slideUp,
///       child: YourPageContent(),
///     ),
///   );
/// }
/// ```
/// 
/// ### 2. Cards com animação:
/// ```dart
/// Widget myCard = Container(
///   child: Text('Meu card'),
/// ).withCardAnimation(
///   delay: Duration(milliseconds: 200),
/// );
/// ```
/// 
/// ### 3. Lista animada:
/// ```dart
/// AnimatedListBuilder(
///   itemCount: items.length,
///   itemDelay: Duration(milliseconds: 100),
///   itemBuilder: (context, index) => YourListItem(index),
/// )
/// ```
/// 
/// ### 4. Switch de conteúdo:
/// ```dart
/// AnimatedContentSwitcher(
///   switchType: AnimationType.slideUp,
///   child: Container(
///     key: ValueKey(currentState),
///     child: currentContent,
///   ),
/// )
/// ```
/// 
/// ### 5. Estados de loading/erro:
/// ```dart
/// AnimatedStatusWidget(
///   status: isLoading ? AnimatedStatus.loading : AnimatedStatus.success,
///   loadingWidget: MyLoadingWidget(),
///   successWidget: MyContentWidget(),
/// )
/// ```
/// 
/// ## Tipos de animação disponíveis:
/// - `AnimationType.fadeIn`: Simples fade in
/// - `AnimationType.slideUp`: Slide de baixo para cima
/// - `AnimationType.scaleIn`: Escala de pequeno para tamanho normal
/// - `AnimationType.slideAndScale`: Combina slide e escala
/// - `AnimationType.rotateIn`: Rotação suave com escala
/// - `AnimationType.elasticSlide`: Slide com efeito elástico
/// 
/// ## Dicas de performance:
/// - Todas as animações respeitam `PerformanceConfig.reduceAnimations`
/// - Use delays moderados (100-300ms) entre items de lista
/// - Para listas grandes, use `AnimatedListBuilder` em vez de múltiplos `AnimatedCard` 