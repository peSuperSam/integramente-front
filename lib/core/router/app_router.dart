import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../utils/app_state.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/area_screen.dart';
import '../../presentation/screens/calculadora_screen.dart';
import '../../presentation/screens/historico_screen.dart';
import '../../presentation/screens/tutorial_screen.dart';
import '../../presentation/screens/configuracoes_screen.dart';
import '../../presentation/screens/advanced_features_screen.dart';

class AppRouter {
  static const String root = '/';
  static const String home = '/home';
  static const String area = '/area';
  static const String calculadora = '/calculadora';
  static const String historico = '/historico';
  static const String tutorial = '/tutorial';
  static const String configuracoes = '/configuracoes';
  static const String advancedFeatures = '/advanced-features';

  static final GoRouter router = GoRouter(
    initialLocation: root,
    routes: [
      GoRoute(
        path: root,
        name: 'root',
        builder: (context, state) => const _AppInitializer(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: area,
        name: 'area',
        builder: (context, state) => const AreaScreen(),
      ),
      GoRoute(
        path: calculadora,
        name: 'calculadora',
        builder: (context, state) => const CalculadoraScreen(),
      ),
      GoRoute(
        path: historico,
        name: 'historico',
        builder: (context, state) => const HistoricoScreen(),
      ),
      GoRoute(
        path: tutorial,
        name: 'tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: configuracoes,
        name: 'configuracoes',
        builder: (context, state) => const ConfiguracoesScreen(),
      ),
      GoRoute(
        path: advancedFeatures,
        name: 'advancedFeatures',
        builder: (context, state) => const AdvancedFeaturesScreen(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Página não encontrada',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'A página "${state.uri}" não existe.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(home),
                  child: const Text('Voltar ao Início'),
                ),
              ],
            ),
          ),
        ),
  );
}

/// Widget que decide se mostra splash ou vai direto para home
class _AppInitializer extends StatelessWidget {
  const _AppInitializer();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppState>(
      builder: (appState) {
        // Se já passou pelo splash, vai direto para home
        if (appState.splashCompleted) {
          // Use WidgetsBinding para navegar após o build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
          // Mostra loading simples enquanto navega
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          );
        }

        // Primeira vez, mostra splash
        return const SplashScreen();
      },
    );
  }
}
