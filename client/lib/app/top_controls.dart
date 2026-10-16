import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio_services.dart';
import '../core/language_controller.dart';
import '../core/supported_languages.dart';
import '../core/theme_controller.dart';
import 'theme.dart';

/// Pílula de idioma (seção 4.5: "troca a qualquer momento... no topo"),
/// gerada a partir de `supportedLanguages` — um idioma novo na lista
/// aparece aqui sozinho, sem editar este arquivo.
class LanguagePill extends ConsumerWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final current = ref.watch(languageControllerProvider).code;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < supportedLanguages.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            _PillButton(
              label: supportedLanguages[i].greeting,
              selected: supportedLanguages[i].code == current,
              onTap: () => ref
                  .read(languageControllerProvider.notifier)
                  .choose(supportedLanguages[i].code),
            ),
          ],
        ],
      ),
    );
  }
}

/// Alvo de toque ≥ 64dp (seção 4.10: "área da criança"), texto grande e
/// contraste forte no estado selecionado — pedido direto do Rhoney
/// (14/10/2026) pra melhorar a usabilidade da pílula, que estava pequena
/// demais pra tocar com precisão.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: selected ? colors.purple : Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: selected ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: selected ? Colors.white : colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão de aparência (seção 4.7: "automático, claro, escuro"), visível em
/// toda tela, cicla automático → claro → escuro a cada toque.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final mode = ref.watch(themeControllerProvider);
    final icon = switch (mode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.brightness_auto_rounded,
    };
    final label = switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Escuro',
      ThemeMode.system => 'Automático',
    };
    return IconButton(
      onPressed: () => ref.read(themeControllerProvider.notifier).cycle(),
      icon: Icon(icon),
      tooltip: label,
      iconSize: 26,
      style: IconButton.styleFrom(
        backgroundColor: colors.card,
        shape: const CircleBorder(),
        minimumSize: const Size(64, 64),
      ),
    );
  }
}

/// Botão de mudo da música (seção 4.4: "botão de silenciar sempre
/// visível"). Efeitos curtos nunca são afetados por este botão — só a
/// melodia de fundo (mesmo comportamento dos protótipos).
class MusicToggleButton extends ConsumerWidget {
  const MusicToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final enabled = ref.watch(musicControllerProvider);
    return IconButton(
      onPressed: () => ref.read(musicControllerProvider.notifier).toggle(),
      icon: Icon(enabled ? Icons.music_note_rounded : Icons.music_off_rounded),
      tooltip: enabled ? 'Música ligada' : 'Música desligada',
      iconSize: 26,
      style: IconButton.styleFrom(
        backgroundColor: colors.card,
        shape: const CircleBorder(),
        minimumSize: const Size(64, 64),
      ),
    );
  }
}

/// Os três controles juntos, na ordem usada em todas as telas pós-idioma
/// (seção 4.5/4.7/4.4: idioma, aparência e música sempre alcançáveis,
/// nunca só na área dos pais enquanto o portão — M4 — não existir).
class TopControls extends StatelessWidget {
  const TopControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        LanguagePill(),
        SizedBox(width: 8),
        MusicToggleButton(),
        SizedBox(width: 8),
        ThemeToggleButton(),
      ],
    );
  }
}
