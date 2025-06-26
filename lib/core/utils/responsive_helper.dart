import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utilitário para responsividade baseado em breakpoints
class ResponsiveHelper {
  // Breakpoints padrão
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Detecta o tipo de dispositivo baseado na largura
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Verifica se é mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Verifica se é tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Largura do SideMenu baseada no dispositivo
  static double getSideMenuWidth(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 0; // SideMenu oculto em mobile
      case DeviceType.tablet:
        return 240; // Mais compacto em tablet
      case DeviceType.desktop:
        return 280; // Largura atual para desktop
    }
  }

  /// Largura do painel lateral de sugestões
  static double getSuggestionsPanelWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return screenWidth * 0.9; // 90% da tela em mobile
      case DeviceType.tablet:
        return 320; // Largura fixa otimizada para tablet
      case DeviceType.desktop:
        return 350; // Largura atual para desktop
    }
  }

  /// Número de colunas do grid baseado no dispositivo
  static int getGridCrossAxisCount(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1; // 1 coluna em mobile
      case DeviceType.tablet:
        return 2; // 2 colunas em tablet
      case DeviceType.desktop:
        return 3; // 3 colunas em desktop
    }
  }

  /// Proporção do grid baseada no dispositivo
  static double getGridChildAspectRatio(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 2.5; // Mais alto em mobile
      case DeviceType.tablet:
        return 1.8; // Balanceado em tablet
      case DeviceType.desktop:
        return 1.5; // Atual para desktop
    }
  }

  /// Padding horizontal responsivo
  static double getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 16; // Padding menor em mobile
      case DeviceType.tablet:
        return 24; // Padding médio em tablet
      case DeviceType.desktop:
        return screenWidth > desktopBreakpoint
            ? 32
            : 24; // Mais padding em telas grandes
    }
  }

  /// Altura da AppBar responsiva
  static double getAppBarHeight(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 100; // Mais baixa em mobile
      case DeviceType.tablet:
        return 110; // Altura média
      case DeviceType.desktop:
        return 120; // Altura atual
    }
  }

  /// Tamanho de fonte responsivo
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return baseFontSize * 0.9; // 10% menor em mobile
      case DeviceType.tablet:
        return baseFontSize; // Tamanho base
      case DeviceType.desktop:
        return baseFontSize * 1.1; // 10% maior em desktop
    }
  }

  /// Espaçamento responsivo
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return baseSpacing * 0.8; // 20% menor em mobile
      case DeviceType.tablet:
        return baseSpacing; // Espaçamento base
      case DeviceType.desktop:
        return baseSpacing * 1.2; // 20% maior em desktop
    }
  }

  /// Verifica se deve mostrar SideMenu
  static bool shouldShowSideMenu(BuildContext context) {
    return !isMobile(context);
  }

  /// Verifica se deve usar drawer em mobile
  static bool shouldUseDrawer(BuildContext context) {
    return isMobile(context);
  }

  /// Largura máxima do conteúdo em desktop
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context) && screenWidth > desktopBreakpoint) {
      return desktopBreakpoint; // Limita largura em telas muito grandes
    }
    return double.infinity;
  }

  /// Orientação responsiva permitida
  static List<DeviceOrientation> getAllowedOrientations(BuildContext context) {
    if (isMobile(context)) {
      // Mobile permite ambas orientações
      return [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
    } else {
      // Tablet e desktop mantêm atual
      return [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
    }
  }
}

/// Enum para tipos de dispositivo
enum DeviceType { mobile, tablet, desktop }

/// Widget helper para layouts responsivos
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// Widget para layout adaptativo com SideMenu
class AdaptiveLayout extends StatelessWidget {
  final Widget sideMenu;
  final Widget body;
  final String currentRoute;
  final Widget? drawer;

  const AdaptiveLayout({
    super.key,
    required this.sideMenu,
    required this.body,
    required this.currentRoute,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return Scaffold(drawer: drawer ?? sideMenu, body: body);

          case DeviceType.tablet:
          case DeviceType.desktop:
            return Row(
              children: [
                if (ResponsiveHelper.shouldShowSideMenu(context)) sideMenu,
                Expanded(child: body),
              ],
            );
        }
      },
    );
  }
}
