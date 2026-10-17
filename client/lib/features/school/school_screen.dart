import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_bar.dart';
import '../../app/hold_to_unlock.dart';
import '../../app/theme.dart';
import '../../app/top_controls.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../core/item_feedback.dart';
import '../../core/language_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../celebration/celebration_overlay.dart';
import '../parents/parents_area_screen.dart';
import 'goals_sheet.dart';
import 'school_controller.dart';
import 'school_lessons.dart';
import 'school_lot.dart';
import 'school_texts.dart';
import 'space_sheet.dart';
import 'world_life.dart';
import 'world_view.dart';

/// Escolinha do Kiddo (seção 6) no mapa livre (M6, seção 7): a criança
/// arrasta pra explorar, mas construir e ter aula continuam sendo só
/// toque em terrenos fixos (6.9) — e a câmera sempre ajuda a achar o
/// espaço brilhante.
class SchoolScreen extends ConsumerStatefulWidget {
  const SchoolScreen({super.key, this.firstVisit = false});

  final bool firstVisit;

  @override
  ConsumerState<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends ConsumerState<SchoolScreen> {
  /// Qual frase o guia está dizendo — guardada como "frase em função do
  /// idioma", não como texto pronto, pra trocar de idioma traduzir o balão
  /// na hora (e o guia repetir a frase no idioma novo).
  String Function(AppLocalizations l10n) _bubble = (_) => '';

  final _worldKey = GlobalKey<WorldViewState>();

  /// Espaço que acabou de ser construído/melhorado (animação de crescer).
  String? _justChanged;
  Timer? _laterTimer;

  SchoolController get _school => ref.read(schoolControllerProvider.notifier);
  ItemFeedback get _feedback => ref.read(itemFeedbackProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _say(
        (l10n) => widget.firstVisit
            ? l10n.schoolWelcomeFirst
            : l10n.schoolWelcomeBack,
      );
    });
  }

  @override
  void dispose() {
    _laterTimer?.cancel();
    super.dispose();
  }

  void _say(String Function(AppLocalizations l10n) text) {
    setState(() => _bubble = text);
    _feedback.speech.speak(text(AppLocalizations.of(context)!));
  }

  /// Dica do guia (mesma prioridade do protótipo): objetivo a resgatar,
  /// depois estrelas pra gastar, senão "faça uma aula".
  String _hint(AppLocalizations l10n) {
    if (_school.claimableCount > 0) return l10n.schoolHintGoal;
    final sug = _school.suggestion();
    if (sug != null && _school.canAfford(sug)) return l10n.schoolHintStars;
    return l10n.schoolHintLesson;
  }

  /// Toques em espaço trancado, por espaço (dispara o balanço, 6.6).
  final Map<String, int> _shakes = {};
  void _shake(String id) =>
      setState(() => _shakes[id] = (_shakes[id] ?? 0) + 1);

  void _tapSpace(SpaceDef space) {
    if (!_school.isOpen(space)) {
      _feedback.sound.play(FeedbackSound.wrong);
      _shake(space.id);
      _say((l10n) => l10n.schoolGradeLocked(l10n.gradeName(space.grade)));
      return;
    }
    // Ordem de liberação: o anterior ainda não foi concluído.
    final blocker = _school.blockedBy(space);
    if (blocker != null) {
      _feedback.sound.play(FeedbackSound.wrong);
      _shake(space.id);
      _say((l10n) => l10n.schoolLockedPrev(l10n.spaceName(blocker.id)));
      return;
    }
    _feedback.sound.play(FeedbackSound.pop);
    _school.markSeen(space.id);
    _say(
      (l10n) =>
          l10n.spaceIntro(l10n.spaceName(space.id), l10n.spaceDesc(space.id)),
    );
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.of(context).card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => SpaceSheet(
        space: space,
        onBuild: () => _buildOrUpgrade(space),
        onLesson: () => _startLesson(space),
        onQuickLesson: _quickLesson,
        onNeedStars: () {
          _feedback.sound.play(FeedbackSound.wrong);
          _say((l10n) => l10n.schoolNeedStars);
        },
        onLessonElsewhere: (next) {
          _feedback.sound.play(FeedbackSound.wrong);
          _say((l10n) => l10n.schoolNextLesson(l10n.spaceName(next)));
        },
      ),
    );
  }

  Future<void> _buildOrUpgrade(SpaceDef space) async {
    final isNew = ref.read(schoolControllerProvider).levelOf(space.id) == 0;
    final ok = await _school.buildOrUpgrade(space.id);
    if (!ok || !mounted) return;
    Navigator.of(context).pop(); // fecha a folha
    _feedback.sound.play(FeedbackSound.build);
    setState(() => _justChanged = space.id);
    _say((l10n) => isNew ? l10n.schoolBuilt : l10n.schoolUpgraded);
    _laterTimer?.cancel();
    _laterTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() => _justChanged = null);
      if (_school.claimableCount > 0) _say((l10n) => l10n.schoolHintGoal);
    });
  }

  Future<void> _startLesson(SpaceDef space) async {
    final grade = ref.read(schoolControllerProvider).grade ?? 0;
    Navigator.of(context).pop(); // fecha a folha
    final before = _school.claimableCount;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => lessonScreenFor(space, grade)));
    if (!mounted) return;
    final reachedGoal = _school.claimableCount > before;
    _say((l10n) => reachedGoal ? l10n.schoolHintGoal : _hint(l10n));
    _showGlowingSpace();
  }

  /// Câmera até o espaço brilhante, se ele estiver fora da tela.
  void _showGlowingSpace() {
    final sug = _school.suggestion();
    final world = _worldKey.currentState;
    if (sug != null && world != null && !world.isVisible(sug)) {
      world.flyTo(sug);
    }
  }

  /// "▶ Ganhar estrelas": vai direto pra aula da vez (aulas em ordem).
  void _quickLesson() {
    final next = _school.currentLessonSpace();
    if (next == null) return;
    final def = ref.read(contentRepositoryProvider).school;
    _startLesson(def.space(next));
  }

  void _openGoals() {
    _feedback.sound.play(FeedbackSound.pop);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.of(context).card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => GoalsSheet(
        onClaimed: () =>
            _say((l10n) => AppLocalizations.of(context)!.medalEarned),
        onPromote: () {
          Navigator.of(context).pop();
          _promote();
        },
      ),
    );
  }

  Future<void> _promote() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await _school.promote();
    if (!mounted || result == PromotionResult.notReady) return;
    final grade = ref.read(schoolControllerProvider).grade ?? 0;
    final message = result == PromotionResult.promoted
        ? l10n.promoted(l10n.gradeName(grade))
        : l10n.graduated;
    await showCelebration(context, message: message, icon: '🎓');
    if (!mounted) return;
    _say(
      (l10n) => result == PromotionResult.promoted
          ? l10n.afterPromotion
          : l10n.afterGraduation,
    );
    // RM-06: as nuvens da série nova se abrem; a câmera vai até o espaço
    // novo pra criança ver a área que chegou.
    _showGlowingSpace();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev == null || prev.code == next.code) return;
      // Espera o frame com o idioma novo pra falar já traduzido.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _say(_bubble);
      });
    });
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final def = ref.watch(contentRepositoryProvider).school;
    final state = ref.watch(schoolControllerProvider);
    final school = _school;
    final grade = state.grade ?? 0;
    final suggestion = school.suggestion();
    final claimable = school.claimableCount;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  KidIconButton(
                    icon: Icons.home_rounded,
                    label: l10n.homeButton,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  _StarsPill(stars: state.stars),
                  const SizedBox(width: 8),
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
            GuideBubbleRow(
              text: _bubble(l10n),
              onRepeat: () => _say(_bubble),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: WorldView(
                      key: _worldKey,
                      initialFocus: suggestion,
                      beacon: suggestion,
                      onFogTap: (g) {
                        _feedback.sound.play(FeedbackSound.wrong);
                        _say(
                          (l10n) => l10n.schoolGradeLocked(l10n.gradeName(g)),
                        );
                      },
                      lotBuilder: (space) => SchoolLot(
                        key: ValueKey('lot_${space.id}'),
                        space: space,
                        gradeIcon: def.grades[space.grade].icon,
                        suggested: space.id == suggestion,
                        grown: space.id == _justChanged,
                        shakes: _shakes[space.id] ?? 0,
                        onTap: () => _tapSpace(space),
                      ),
                      worldChildren: const [
                        Positioned.fill(child: WorldLife()),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.yellow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${def.grades[grade].icon} ${l10n.gradeName(grade)} · '
                            '${l10n.gradeAge(def.grades[grade].age)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B2D42),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _DockButton(
                      key: const ValueKey('btnGoals'),
                      icon: '🏆',
                      label: l10n.goalsButton,
                      badge: claimable,
                      color: colors.purple,
                      onTap: _openGoals,
                    ),
                  ),
                  if (state.graduated || school.allClaimed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DockButton(
                        key: const ValueKey('btnPromote'),
                        icon: '🎓',
                        label: state.graduated
                            ? l10n.graduatedBadge
                            : grade < def.lastGrade
                            ? l10n.promoteButton
                            : l10n.graduateButton,
                        color: colors.green,
                        onTap: state.graduated ? null : _promote,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsPill extends StatelessWidget {
  const _StarsPill({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      key: const ValueKey('schoolStars'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            '$stars',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge = 0,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 64,
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: color.withValues(alpha: .6),
              shape: const StadiumBorder(),
            ),
            onPressed: onTap,
            child: FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.of(context).coral,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
