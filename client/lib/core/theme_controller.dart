import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_service.dart';

/// Seção 4.7/9.1: aparência automático/claro/escuro, visível e trocável a
/// qualquer momento (mesmo padrão de alcance da pílula de idioma).
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.watch(persistenceServiceProvider).themeModeName;
    return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
  }

  Future<void> setMode(ThemeMode mode) async {
    await ref.read(persistenceServiceProvider).setThemeModeName(mode.name);
    state = mode;
  }

  /// Alterna automático → claro → escuro → automático, pra um botão só
  /// (em vez de 3 segmentos) poder ciclar o tema.
  Future<void> cycle() => setMode(switch (state) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      });
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
