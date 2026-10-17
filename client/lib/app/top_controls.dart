import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio_services.dart';
import '../core/language_controller.dart';
import '../core/supported_languages.dart';
import '../core/theme_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'theme.dart';

/// Botões de idioma (seção 4.5: "troca a qualquer momento... no topo"),
/// gerados a partir de `supportedLanguages` — um idioma novo na lista
/// aparece aqui sozinho. Cada idioma é um botão redondo de 64 dp com a
/// bandeira, do mesmo tamanho da música e do tema; o ativo fica roxo.
class LanguagePill extends ConsumerWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageControllerProvider).code;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < supportedLanguages.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _FlagButton(
            key: ValueKey('lang_${supportedLanguages[i].code}'),
            lang: supportedLanguages[i],
            selected: supportedLanguages[i].code == current,
            onTap: () => ref
                .read(languageControllerProvider.notifier)
                .choose(supportedLanguages[i].code),
          ),
        ],
      ],
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({
    super.key,
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  final SupportedLanguage lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: lang.nativeName,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.purple : colors.card,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: selected ? null : onTap,
          child: SizedBox.square(
            dimension: 64,
            child: Center(
              child: Text(lang.flag, style: const TextStyle(fontSize: 30)),
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
    final l10n = AppLocalizations.of(context)!;
    final label = switch (mode) {
      ThemeMode.light => l10n.parentsThemeLight,
      ThemeMode.dark => l10n.parentsThemeDark,
      ThemeMode.system => l10n.parentsThemeAuto,
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
      tooltip: enabled
          ? AppLocalizations.of(context)!.musicOn
          : AppLocalizations.of(context)!.musicOff,
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
/// (seção 4.5/4.7/4.4: idioma, aparência e música sempre alcançáveis pela
/// criança, além de também ficarem na área dos pais).
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
