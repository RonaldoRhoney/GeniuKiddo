import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_bar.dart';
import '../../app/shake.dart';
import '../../app/hold_to_unlock.dart';
import '../../app/theme.dart';
import '../../app/top_controls.dart';
import '../../content/content_repository.dart';
import '../../core/item_feedback.dart';
import '../../core/language_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../activities/free_draw/free_draw_screen.dart';
import '../parents/parents_area_screen.dart';
import '../school/grade_choice_screen.dart';
import '../school/school_controller.dart';
import '../school/school_screen.dart';
import '../trail/trail_controller.dart';
import '../trail/trail_screen.dart';

/// Menu inicial: raiz da navegação depois da abertura. Cada fase é um
/// cartão grande (a Escolinha fica trancada até liberar, RF-FASE-01) e o
/// rabisco livre está sempre aberto (RT-08). Trilha e escola têm 🏠 pra
/// voltar aqui. O botão voltar do Android não fecha o app daqui (4.10) —
/// sair é só pela área dos pais, atrás do portão.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// O que o guia está dizendo (balão = fala, seção 4.2).
  late String Function(AppLocalizations l10n) _bubble = _welcome;
  int _schoolShakes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _say(_bubble);
    });
  }

  void _say(String Function(AppLocalizations l10n) text) {
    setState(() => _bubble = text);
    ref
        .read(itemFeedbackProvider)
        .speech
        .speak(text(AppLocalizations.of(context)!));
  }

  String _welcome(AppLocalizations l10n) {
    return ref.read(languageControllerProvider).isFirstChoice
        ? l10n.welcomeFirst
        : l10n.welcomeBack;
  }

  void _go(Widget screen) {
    ref.read(itemFeedbackProvider).sound.play(FeedbackSound.pop);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openSchool() {
    if (!ref.read(phase2UnlockedProvider)) {
      ref.read(itemFeedbackProvider).sound.play(FeedbackSound.wrong);
      setState(() => _schoolShakes++);
      _say((l10n) => l10n.homeSchoolLocked);
      return;
    }
    _go(
      ref.read(schoolControllerProvider).grade == null
          ? const GradeChoiceScreen()
          : const SchoolScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _say(_bubble);
        });
      }
    });
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final trail = ref.watch(trailControllerProvider);
    final total = ref.watch(contentRepositoryProvider).trail.length;
    final schoolOpen = ref.watch(phase2UnlockedProvider);
    ref.watch(languageControllerProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: TopControls(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HoldToUnlock(
                      semanticLabel: l10n.parentGateLabel,
                      onUnlock: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ParentsAreaScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GuideBubbleRow(
                text: _bubble(l10n),
                onRepeat: () => _say(_bubble),
                avatarSize: 72,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    _HomeCard(
                      key: const ValueKey('homeTrail'),
                      icon: '🗺️',
                      title: l10n.homeTrail,
                      subtitle: l10n.homeTrailProgress(trail.done, total),
                      color: colors.yellow,
                      darkText: true,
                      onTap: () => _go(const TrailScreen()),
                    ),
                    const SizedBox(height: 14),
                    _HomeCard(
                      key: const ValueKey('btnSchool'),
                      shakes: _schoolShakes,
                      icon: schoolOpen ? '🏫' : '🔒',
                      title: l10n.trailSchool,
                      color: colors.green,
                      locked: !schoolOpen,
                      onTap: _openSchool,
                    ),
                    const SizedBox(height: 14),
                    _HomeCard(
                      key: const ValueKey('homeFreeDraw'),
                      icon: '🖍️',
                      title: l10n.trailFreeDraw,
                      color: colors.purple,
                      onTap: () => _go(const FreeDrawScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.locked = false,
    this.darkText = false,
    this.shakes = 0,
  });

  /// Toques com o cartão trancado (dispara o balanço).
  final int shakes;

  final String icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  /// Trancado = apagado, mas o toque ainda responde (som + fala), pra a
  /// criança entender o porquê (seção 4.6).
  final bool locked;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final textColor = darkText ? const Color(0xFF2B2D42) : Colors.white;
    return Shake(
      trigger: shakes,
      child: Opacity(
        opacity: locked ? .5 : 1,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 52)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textColor.withValues(alpha: .8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
