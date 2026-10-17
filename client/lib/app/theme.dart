import 'package:flutter/material.dart';

/// Tokens de cor da identidade visual (especificação formal, seção 9.2).
/// Nomes dos campos espelham os nomes dos tokens do documento
/// (`purple`, `blue`, `yellow`, `green`, `coral`, `bg`, `ink`) de propósito,
/// pra facilitar auditoria contra a seção 9.2 e contra os protótipos HTML.
class AppColors {
  const AppColors({
    required this.purple,
    required this.blue,
    required this.yellow,
    required this.green,
    required this.coral,
    required this.bg,
    required this.ink,
    required this.card,
  });

  final Color purple;
  final Color blue;
  final Color yellow;
  final Color green;
  final Color coral;
  final Color bg;
  final Color ink;
  final Color card;

  /// Resolve pelo brilho ATUAL do tema (seção 4.7: automático/claro/escuro)
  /// — usar isto em vez de `AppColors.light` direto em qualquer tela.
  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const light = AppColors(
    purple: Color(0xFF7C5CFF),
    blue: Color(0xFF4DA8FF),
    yellow: Color(0xFFFFC93C),
    green: Color(0xFF4FCB8D),
    coral: Color(0xFFFF6B6B),
    bg: Color(0xFFFFF8E7),
    ink: Color(0xFF2B2D42),
    card: Color(0xFFFFFFFF),
  );

  // Tema escuro (opcional), seção 9.2: bg #1D1A3A, card #2F2A5C, ink #F4F1FF.
  static const dark = AppColors(
    purple: Color(0xFF7C5CFF),
    blue: Color(0xFF4DA8FF),
    yellow: Color(0xFFFFC93C),
    green: Color(0xFF4FCB8D),
    coral: Color(0xFFFF6B6B),
    bg: Color(0xFF1D1A3A),
    ink: Color(0xFFF4F1FF),
    card: Color(0xFF2F2A5C),
  );
}

/// Paleta de pintura (seção 9.2) — 6 cores fixas usadas nas atividades de
/// pintar/rabisco livre, independente de tema claro/escuro.
class PaintPalette {
  /// Ids das cores, na mesma ordem de `colors` (nome via `colorName`).
  static const ids = ['red', 'blue', 'yellow', 'green', 'purple', 'orange'];

  static Color byId(String id) => colors[ids.indexOf(id)];

  static const colors = <Color>[
    Color(0xFFFF5A5F), // vermelho
    Color(0xFF4DA8FF), // azul
    Color(0xFFFFC93C), // amarelo
    Color(0xFF4FCB8D), // verde
    Color(0xFF7C5CFF), // roxo
    Color(0xFFFF9B3D), // laranja
  ];
}

ThemeData buildAppTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.purple,
    onPrimary: Colors.white,
    secondary: c.blue,
    onSecondary: Colors.white,
    error: c.coral,
    onError: Colors.white,
    surface: c.card,
    onSurface: c.ink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    fontFamily: 'Baloo 2',
    textTheme: const TextTheme().apply(
      fontFamily: 'Baloo 2',
      bodyColor: c.ink,
      displayColor: c.ink,
    ),
  );
}
