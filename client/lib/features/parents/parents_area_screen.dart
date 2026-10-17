import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_info.dart';
import '../../app/theme.dart';
import '../../app/top_controls.dart';
import '../../content/content_repository.dart';
import '../../core/break_controller.dart';
import '../../core/item_feedback.dart';
import '../../core/language_controller.dart';
import '../../core/persistence_service.dart';
import '../../core/supported_languages.dart';
import '../../core/theme_controller.dart';
import '../../core/tts_speech_port.dart';
import '../../l10n/generated/app_localizations.dart';
import '../school/school_controller.dart';
import '../school/school_texts.dart';
import '../trail/trail_controller.dart';
import 'how_to_use_screen.dart';

/// Controle dos pais (seção 4.7), atrás do portão de segurar 2 s: um menu
/// de cartões com um resumo no topo. Cada cartão abre a sua tela —
/// idioma e voz, pausa, Escolinha, progresso, aparência, privacidade e
/// "Como usar" — e "Sair do app" fica no fim.
class ParentsAreaScreen extends ConsumerStatefulWidget {
  const ParentsAreaScreen({super.key});

  @override
  ConsumerState<ParentsAreaScreen> createState() => _ParentsAreaScreenState();
}

class _ParentsAreaScreenState extends ConsumerState<ParentsAreaScreen> {
  /// Abre a tela; na volta, redesenha (o resumo reflete o que mudou lá).
  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  void _open(BuildContext context, String title, Widget section) =>
      _push(_SectionPage(title: title, child: section));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final cards = <({String key, String icon, String title, Widget section})>[
      (
        key: 'voice',
        icon: '🗣️',
        title: l10n.parentsCardVoice,
        section: const _VoiceSection(),
      ),
      (
        key: 'break',
        icon: '😴',
        title: l10n.parentsBreakLabel,
        section: const _BreakSection(),
      ),
      (
        key: 'school',
        icon: '🏫',
        title: l10n.parentsSchoolLabel,
        section: const _SchoolSection(),
      ),
      (
        key: 'progress',
        icon: '📊',
        title: l10n.parentsProgressLabel,
        section: const _ProgressSection(),
      ),
      (
        key: 'appearance',
        icon: '🎨',
        title: l10n.parentsAppearanceLabel,
        section: const _AppearanceSection(),
      ),
      (
        key: 'privacy',
        icon: '🔐',
        title: l10n.parentsPrivacyLabel,
        section: const _PrivacySection(),
      ),
    ];

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
          4,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          // Sem `const`: precisa redesenhar quando o menu redesenha.
          _Summary(),
          const SizedBox(height: 16),
          _HelpCard(onTap: () => _push(const HowToUseScreen())),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              for (final c in cards)
                _MenuCard(
                  key: ValueKey('parentsCard_${c.key}'),
                  icon: c.icon,
                  title: c.title,
                  onTap: () => _open(context, c.title, c.section),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              key: const ValueKey('exitApp'),
              // Só aqui, atrás do portão (4.10): a criança não fecha o app
              // sem querer.
              onPressed: () => SystemNavigator.pop(),
              icon: const Icon(Icons.exit_to_app_rounded),
              label: Text(l10n.parentsExitLabel),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.parentsExitHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colors.ink.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resumo no topo: série, trilha, pausa e voz, num relance.
class _Summary extends ConsumerWidget {
  const _Summary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final trail = ref.watch(trailControllerProvider);
    final content = ref.watch(contentRepositoryProvider);
    final school = ref.watch(schoolControllerProvider);
    final persistence = ref.read(persistenceServiceProvider);
    final minutes = persistence.breakMinutes;
    final items = <String>[
      if (school.grade != null)
        '${content.school.grades[school.grade!].icon} ${l10n.gradeName(school.grade!)}',
      '🗺️ ${l10n.parentsSummaryTrail(trail.done, content.trail.length)}',
      minutes == 0
          ? '😴 ${l10n.parentsSummaryBreakOff}'
          : '😴 ${l10n.parentsSummaryBreak(minutes)}',
      if (!persistence.voiceEnabled) '🔇 ${l10n.parentsSummaryVoiceOff}',
    ];
    return Container(
      key: const ValueKey('parentsSummary'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.purple.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          for (final i in items)
            Text(i, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Como usar" em destaque, logo abaixo do resumo.
class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return Material(
      key: const ValueKey('parentsCard_help'),
      color: colors.yellow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text('❓', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.parentsCardHelp,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.inkOnBright,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkOnBright,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela de uma seção do Controle dos pais.
class _SectionPage extends StatelessWidget {
  const _SectionPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

const _tones = ['suave', 'fofa', 'super'];
const _breakOptions = [0, 5, 10, 15, 20];

/// Idioma, música e voz: liga/desliga, tom, escolha da voz e teste.
class _VoiceSection extends ConsumerStatefulWidget {
  const _VoiceSection();

  @override
  ConsumerState<_VoiceSection> createState() => _VoiceSectionState();
}

class _VoiceSectionState extends ConsumerState<_VoiceSection> {
  late String _tone = ref.read(persistenceServiceProvider).voiceTone;
  late bool _voiceOn = ref.read(persistenceServiceProvider).voiceEnabled;
  List<Map<Object?, Object?>> _voices = const [];
  String? _voiceName;

  String get _languageCode =>
      ref.read(languageControllerProvider).code ??
      supportedLanguages.first.code;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  /// Vozes do idioma ATUAL — recarregadas quando o idioma muda aqui mesmo,
  /// pra nunca gravar uma voz de um idioma no outro.
  void _loadVoices() {
    final languageCode = _languageCode;
    _voiceName = ref
        .read(persistenceServiceProvider)
        .voiceNameFor(languageCode);
    _voices = const [];
    final speech = ref.read(speechPortProvider);
    if (speech is TtsSpeechPort) {
      speech.voicesForCurrentLanguage().then((voices) {
        if (!mounted || languageCode != _languageCode) return;
        setState(() {
          _voices = voices;
          // Voz salva que sumiu do aparelho: volta pro automático.
          if (!voices.any((v) => v['name'] == _voiceName)) _voiceName = null;
        });
      });
    }
  }

  void _setVoiceOn(bool on) {
    setState(() => _voiceOn = on);
    ref.read(persistenceServiceProvider).setVoiceEnabled(on);
  }

  void _setTone(String tone) {
    setState(() => _tone = tone);
    ref.read(persistenceServiceProvider).setVoiceTone(tone);
  }

  void _setVoiceName(String? name) {
    setState(() => _voiceName = name);
    ref.read(persistenceServiceProvider).setVoiceNameFor(_languageCode, name);
  }

  String _toneLabel(AppLocalizations l10n, String tone) => switch (tone) {
    'suave' => l10n.parentsVoiceToneSuave,
    'super' => l10n.parentsVoiceToneSuper,
    _ => l10n.parentsVoiceToneFofa,
  };

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) setState(_loadVoices);
    });
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l10n.parentsLanguageLabel),
        const LanguagePill(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _Label(l10n.parentsMusicLabel)),
            const MusicToggleButton(),
          ],
        ),
        Row(
          children: [
            Expanded(child: _Label(l10n.parentsVoiceOnLabel)),
            Switch(
              key: const ValueKey('voiceOn'),
              value: _voiceOn,
              onChanged: _setVoiceOn,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Label(l10n.parentsVoiceToneLabel),
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
          _Label(l10n.parentsVoicePickLabel),
          DropdownButton<String?>(
            value: _voiceName,
            isExpanded: true,
            hint: Text(l10n.parentsVoiceAuto),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.parentsVoiceAuto)),
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
    );
  }
}

/// Pausa sugerida (seção 4.8): desligada, 5, 10, 15 (padrão) ou 20 min.
class _BreakSection extends ConsumerStatefulWidget {
  const _BreakSection();

  @override
  ConsumerState<_BreakSection> createState() => _BreakSectionState();
}

class _BreakSectionState extends ConsumerState<_BreakSection> {
  late int _minutes = ref.read(persistenceServiceProvider).breakMinutes;

  void _set(int minutes) {
    setState(() => _minutes = minutes);
    ref.read(persistenceServiceProvider).setBreakMinutes(minutes).then((_) {
      ref.read(breakControllerProvider.notifier).restart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final minutes in _breakOptions)
          _Chip(
            label: minutes == 0
                ? l10n.parentsBreakOff
                : l10n.parentsBreakMinutes(minutes),
            selected: _minutes == minutes,
            onTap: () => _set(minutes),
          ),
      ],
    );
  }
}

/// Seção 4.7 (Fase 2): série da criança, com troca posterior sem apagar o
/// construído, e RF-FASE-03 (liberar a Escolinha antes da trilha acabar).
class _SchoolSection extends ConsumerWidget {
  const _SchoolSection();

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
        _Label(l10n.parentsGradeLabel),
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

/// Progresso da trilha, com "liberar todas as etapas" (RF-FASE-03).
class _ProgressSection extends ConsumerWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trail = ref.watch(trailControllerProvider);
    final total = ref.watch(contentRepositoryProvider).trail.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.parentsProgressSteps(trail.done, total)),
        const SizedBox(height: 4),
        Text(l10n.parentsProgressStars(trail.stars)),
        if (trail.done < total) ...[
          const SizedBox(height: 10),
          Text(
            l10n.parentsUnlockTrailHint,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              key: const ValueKey('unlockTrail'),
              onPressed: () =>
                  ref.read(trailControllerProvider.notifier).unlockAll(total),
              child: Text(l10n.parentsUnlockTrail),
            ),
          ),
        ],
      ],
    );
  }
}

/// Aparência: automático, claro ou escuro (seção 4.7).
class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeControllerProvider);
    return Wrap(
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
            onTap: () =>
                ref.read(themeControllerProvider.notifier).setMode(mode),
          ),
      ],
    );
  }
}

/// Resumo de privacidade em linguagem simples + endereço da política
/// completa (seção 4.7). O endereço é selecionável e copiável — abrir o
/// navegador exigiria um pacote novo (regra 0.5).
class _PrivacySection extends StatelessWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.parentsPrivacySummary),
        const SizedBox(height: 14),
        _Label(l10n.parentsPrivacyFullPolicy),
        const SelectableText(AppInfo.privacyPolicyUrl),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            key: const ValueKey('copyPolicy'),
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: AppInfo.privacyPolicyUrl),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.parentsPrivacyCopied)),
              );
            },
            icon: const Icon(Icons.copy_rounded),
            label: Text(l10n.parentsPrivacyCopy),
          ),
        ),
        const SizedBox(height: 14),
        _Label(l10n.parentsPrivacyContact),
        const SelectableText(AppInfo.supportEmail),
      ],
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
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
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
      ),
    );
  }
}
