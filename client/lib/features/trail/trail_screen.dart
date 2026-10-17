import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_bar.dart';
import '../../app/shake.dart';
import '../../app/hold_to_unlock.dart';
import '../../app/theme.dart';
import '../../app/top_controls.dart';
import '../../content/content_repository.dart';
import '../../content/labels.dart';
import '../../content/models.dart';
import '../../core/item_feedback.dart';
import '../../core/language_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../activities/activity_outcome.dart';
import '../activities/listen/listen_screen.dart';
import '../activities/match/match_screen.dart';
import '../activities/paint/paint_screen.dart';
import '../activities/speak/speak_screen.dart';
import '../activities/trace/trace_screen.dart';
import '../parents/parents_area_screen.dart';
import 'trail_controller.dart';

const _activityIcons = <ActivityType, IconData>{
  ActivityType.paint: Icons.palette_rounded,
  ActivityType.listen: Icons.hearing_rounded,
  ActivityType.match: Icons.extension_rounded,
  ActivityType.trace: Icons.edit_rounded,
  ActivityType.speak: Icons.record_voice_over_rounded,
};

/// Trilha de atividades (seção 5): mapa de 8 etapas, libera por
/// participação, rabisco livre sempre disponível.
class TrailScreen extends ConsumerStatefulWidget {
  const TrailScreen({super.key});

  @override
  ConsumerState<TrailScreen> createState() => _TrailScreenState();
}

class _TrailScreenState extends ConsumerState<TrailScreen> {
  /// O que o guia está dizendo (balão = fala, seção 4.2), guardado como
  /// frase em função do idioma pra trocar de idioma traduzir na hora.
  String Function(AppLocalizations l10n) _bubble = (_) => '';

  /// Toques em etapa trancada, por etapa (dispara o balanço).
  final Map<int, int> _shakes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _say(_hint);
    });
  }

  void _say(String Function(AppLocalizations l10n) text) {
    setState(() => _bubble = text);
    ref
        .read(itemFeedbackProvider)
        .speech
        .speak(text(AppLocalizations.of(context)!));
  }

  /// Dica do guia: a estrela brilhante, ou "tudo feito" com a trilha
  /// completa.
  String _hint(AppLocalizations l10n) {
    final done = ref.read(trailControllerProvider).done;
    final total = ref.read(contentRepositoryProvider).trail.length;
    return done >= total ? l10n.trailAllDone : l10n.trailHint;
  }

  void _openNode(int index, TrailNodeDef node) {
    final status = ref.read(trailControllerProvider.notifier).statusOf(index);
    if (status == TrailNodeStatus.locked) {
      // Seção 5.2: balanço leve, som suave e fala encorajadora.
      ref.read(itemFeedbackProvider).sound.play(FeedbackSound.wrong);
      setState(() => _shakes[index] = (_shakes[index] ?? 0) + 1);
      _say((l10n) => l10n.trailLocked);
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => _activityFor(index, node)))
        .then((_) {
          if (!mounted) return;
          final trail = ref.read(trailControllerProvider);
          final total = ref.read(contentRepositoryProvider).trail.length;
          final justFinishedThis = trail.done == index + 1;
          if (!justFinishedThis) {
            _say((l10n) => l10n.trailPlayMore);
          } else if (trail.done < total) {
            _say((l10n) => l10n.trailNewActivity);
          } else {
            _say((l10n) => l10n.trailAllDone);
          }
        });
  }

  Widget _activityFor(int index, TrailNodeDef node) {
    return switch (node.type) {
      ActivityType.paint => PaintScreen(
        outcome: TrailStepOutcome(index),
        art: node.art!,
      ),
      ActivityType.trace => TraceScreen(
        outcome: TrailStepOutcome(index),
        glyph: node.glyph!,
      ),
      ActivityType.listen => ListenScreen(
        outcome: TrailStepOutcome(index),
        items: node.items!,
      ),
      ActivityType.match => MatchScreen(
        outcome: TrailStepOutcome(index),
        items: node.items!,
      ),
      ActivityType.speak => SpeakScreen(
        outcome: TrailStepOutcome(index),
        items: node.items!,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev == null || prev.code == next.code) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _say(_bubble);
      });
    });
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final content = ref.watch(contentRepositoryProvider);
    final trail = ref.watch(trailControllerProvider);

    // O voltar do Android (e o 🏠) volta ao menu inicial — quem segura o
    // app aberto (4.10) é o menu, que é a raiz da navegação.
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('trailHome'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    tooltip: l10n.homeButton,
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      backgroundColor: colors.card,
                      shape: const CircleBorder(),
                      minimumSize: const Size(64, 64),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(
                          '${trail.stars}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Em telas estreitas os controles encolhem o mínimo
                  // necessário — nunca empurram o cadeado (4.7) pra fora.
                  const Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
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
            GuideBubbleRow(text: _bubble(l10n), onRepeat: () => _say(_bubble)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: content.trail.length,
                itemBuilder: (context, index) {
                  final node = content.trail[index];
                  final status = ref
                      .watch(trailControllerProvider.notifier)
                      .statusOf(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: index.isOdd
                          ? Alignment.centerRight
                          : (index % 4 == 2
                                ? Alignment.centerLeft
                                : Alignment.center),
                      child: _TrailNode(
                        key: ValueKey('trailNode_$index'),
                        shakes: _shakes[index] ?? 0,
                        title: trailNodeTitle(l10n, node.id),
                        icon: _activityIcons[node.type]!,
                        status: status,
                        onTap: () => _openNode(index, node),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailNode extends StatefulWidget {
  const _TrailNode({
    super.key,
    required this.title,
    required this.icon,
    required this.status,
    required this.onTap,
    required this.shakes,
  });

  final String title;
  final IconData icon;
  final TrailNodeStatus status;
  final VoidCallback onTap;
  final int shakes;

  @override
  State<_TrailNode> createState() => _TrailNodeState();
}

/// Etapa da trilha. A atual pulsa com a mão 👆 (seção 5.2); a trancada
/// balança quando tocada.
class _TrailNodeState extends State<_TrailNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _TrailNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (widget.status == TrailNodeStatus.current && !reduce) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bg = switch (widget.status) {
      TrailNodeStatus.done => colors.green,
      TrailNodeStatus.current => colors.yellow,
      TrailNodeStatus.locked => const Color(0xFFCFCBE6),
    };
    final label = widget.status == TrailNodeStatus.locked ? '?' : widget.title;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Shake(
        trigger: widget.shakes,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) =>
              Transform.scale(scale: 1 + _pulse.value * .06, child: child),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                      ),
                      child: widget.status == TrailNodeStatus.locked
                          ? ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 2.4,
                                sigmaY: 2.4,
                              ),
                              child: Icon(
                                widget.icon,
                                size: 38,
                                color: Colors.white.withValues(alpha: .7),
                              ),
                            )
                          : Icon(widget.icon, size: 38, color: Colors.white),
                    ),
                    if (widget.status == TrailNodeStatus.done)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: colors.green,
                            size: 20,
                          ),
                        ),
                      ),
                    if (widget.status == TrailNodeStatus.current)
                      const Positioned(
                        right: -24,
                        bottom: -8,
                        child: Text('👆', style: TextStyle(fontSize: 30)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 120,
                  child: Text(
                    widget.status == TrailNodeStatus.locked
                        ? '?'
                        : widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.ink.withValues(alpha: .75),
                    ),
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
