import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/top_controls.dart';
import '../../content/content_repository.dart';
import '../../core/break_controller.dart';
import '../../core/item_feedback.dart';
import '../../core/language_controller.dart';
import '../../core/persistence_service.dart';
import '../../core/theme_controller.dart';
import '../../core/tts_speech_port.dart';
import '../../l10n/generated/app_localizations.dart';
import '../school/school_controller.dart';
import '../school/school_texts.dart';
import '../trail/trail_controller.dart';

/// Área dos pais (seção 4.7), atrás do portão (`HoldToUnlock`). Conteúdo
/// comum a todas as fases: idioma, som e voz (tom + seleção manual + botão
/// de teste), pausa sugerida, progresso, aparência e resumo de privacidade.
/// "Série da criança" (Fase 2) entra só quando a Fase 2 existir.
class ParentsAreaScreen extends ConsumerStatefulWidget {
  const ParentsAreaScreen({super.key});

  @override
  ConsumerState<ParentsAreaScreen> createState() => _ParentsAreaScreenState();
}

const _tones = ['suave', 'fofa', 'super'];
const _breakOptions = [0, 5, 10, 15, 20];

class _ParentsAreaScreenState extends ConsumerState<ParentsAreaScreen> {
  late String _tone = ref.read(persistenceServiceProvider).voiceTone;
  late int _breakMinutes = ref.read(persistenceServiceProvider).breakMinutes;
  List<Map<Object?, Object?>> _voices = const [];
  String? _voiceName;

  @override
  void initState() {
    super.initState();
    final languageCode = ref.read(languageControllerProvider).code ?? 'pt';
    _voiceName = ref
        .read(persistenceServiceProvider)
        .voiceNameFor(languageCode);
    final speech = ref.read(speechPortProvider);
    if (speech is TtsSpeechPort) {
      speech.voicesForCurrentLanguage().then((voices) {
        if (mounted) setState(() => _voices = voices);
      });
    }
  }

  void _setTone(String tone) {
    setState(() => _tone = tone);
    ref.read(persistenceServiceProvider).setVoiceTone(tone);
  }

  void _setVoiceName(String? name) {
    setState(() => _voiceName = name);
    final languageCode = ref.read(languageControllerProvider).code ?? 'pt';
    ref.read(persistenceServiceProvider).setVoiceNameFor(languageCode, name);
  }

  void _setBreakMinutes(int minutes) {
    setState(() => _breakMinutes = minutes);
    ref.read(persistenceServiceProvider).setBreakMinutes(minutes).then((_) {
      ref.read(breakControllerProvider.notifier).restart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final trail = ref.watch(trailControllerProvider);
    final content = ref.watch(contentRepositoryProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        title: Text(
          l10n.parentsAreaTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        // Soma a barra de navegação do Android (edge-to-edge) pra o fim da
        // lista não ficar escondido atrás dela.
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _Section(
            title: l10n.parentsLanguageLabel,
            child: const LanguagePill(),
          ),
          _Section(
            title: l10n.parentsSoundLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.parentsMusicLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    const MusicToggleButton(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.parentsVoiceToneLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tone in _tones)
                      _Chip(
                        label: _toneLabel(l10n, tone),
                        selected: _tone == tone,
                        onTap: () => _setTone(tone),
                      ),
                  ],
                ),
                if (_voices.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.parentsVoicePickLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String?>(
                    value: _voiceName,
                    isExpanded: true,
                    hint: Text(l10n.parentsVoiceAuto),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.parentsVoiceAuto),
                      ),
                      for (final v in _voices)
                        DropdownMenuItem(
                          value: v['name'] as String?,
                          child: Text(v['name'] as String? ?? ''),
                        ),
                    ],
                    onChanged: _setVoiceName,
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(itemFeedbackProvider)
                        .speech
                        .speak(l10n.parentsVoiceTestPhrase),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(l10n.parentsTestVoice),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l10n.parentsBreakLabel,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final minutes in _breakOptions)
                  _Chip(
                    label: minutes == 0
                        ? l10n.parentsBreakOff
                        : l10n.parentsBreakMinutes(minutes),
                    selected: _breakMinutes == minutes,
                    onTap: () => _setBreakMinutes(minutes),
                  ),
              ],
            ),
          ),
          _Section(title: l10n.parentsSchoolLabel, child: _SchoolSection()),
          _Section(
            title: l10n.parentsProgressLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.parentsProgressSteps(trail.done, content.trail.length),
                ),
                const SizedBox(height: 4),
                Text(l10n.parentsProgressStars(trail.stars)),
              ],
            ),
          ),
          _Section(
            title: l10n.parentsAppearanceLabel,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (mode, label) in [
                  (ThemeMode.system, l10n.parentsThemeAuto),
                  (ThemeMode.light, l10n.parentsThemeLight),
                  (ThemeMode.dark, l10n.parentsThemeDark),
                ])
                  _Chip(
                    label: label,
                    selected: themeMode == mode,
                    onTap: () => ref
                        .read(themeControllerProvider.notifier)
                        .setMode(mode),
                  ),
              ],
            ),
          ),
          _Section(
            title: l10n.parentsPrivacyLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.parentsPrivacySummary),
                const SizedBox(height: 10),
                Text(
                  l10n.parentsPrivacyPolicyPlaceholder,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.ink.withValues(alpha: .6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l10n.parentsExitLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.parentsExitHint),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    key: const ValueKey('exitApp'),
                    // Só aqui, atrás do portão (4.10): a criança não fecha
                    // o app sem querer.
                    onPressed: () => SystemNavigator.pop(),
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: Text(l10n.parentsExitLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _toneLabel(AppLocalizations l10n, String tone) => switch (tone) {
    'suave' => l10n.parentsVoiceToneSuave,
    'super' => l10n.parentsVoiceToneSuper,
    _ => l10n.parentsVoiceToneFofa,
  };
}

/// Seção 4.7 (Fase 2): série da criança, com troca posterior sem apagar o
/// construído, e RF-FASE-03 (liberar a Escolinha antes da trilha acabar).
class _SchoolSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unlocked = ref.watch(phase2UnlockedProvider);
    final school = ref.watch(schoolControllerProvider);
    final grades = ref.watch(contentRepositoryProvider).school.grades;
    if (!unlocked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.parentsSchoolLockedHint),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              key: const ValueKey('unlockSchool'),
              onPressed: () =>
                  ref.read(phase2UnlockedProvider.notifier).unlockManually(),
              icon: const Text('🏫'),
              label: Text(l10n.parentsUnlockSchool),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.parentsGradeLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var g = 0; g < grades.length; g++)
              _Chip(
                label: '${grades[g].icon} ${l10n.gradeName(g)}',
                selected: school.grade == g,
                onTap: () =>
                    ref.read(schoolControllerProvider.notifier).chooseGrade(g),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.parentsGradeChangeNote, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Text(l10n.parentsSchoolProgress(school.stars, school.medals)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: colors.purple,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      color: selected ? colors.purple : colors.bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          // `widthFactor: 1` — centraliza sem esticar o chip na largura toda.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : colors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
