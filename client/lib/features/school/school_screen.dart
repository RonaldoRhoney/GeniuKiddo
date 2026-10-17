import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_avatar.dart';
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
import 'school_texts.dart';

/// Escolinha do Kiddo (seção 6): grade de espaços em lotes prontos — só
/// toque, nunca arrastar (6.9), pra funcionar aos 3 anos. O mundo
/// explorável por arrasto é o M6.
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

  void _tapSpace(SpaceDef space) {
    if (!_school.isOpen(space)) {
      _feedback.sound.play(FeedbackSound.wrong);
      _say((l10n) => l10n.schoolGradeLocked(l10n.gradeName(space.grade)));
      return;
    }
    _feedback.sound.play(FeedbackSound.pop);
    _school.markSeen(space.id);
    _say((l10n) => '${l10n.spaceName(space.id)}! ${l10n.spaceDesc(space.id)}');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.of(context).card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => _SpaceSheet(
        space: space,
        onBuild: () => _buildOrUpgrade(space),
        onLesson: () => _startLesson(space),
        onQuickLesson: _quickLesson,
        onNeedStars: () {
          _feedback.sound.play(FeedbackSound.wrong);
          _say((l10n) => l10n.schoolNeedStars);
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
    _say(
      (l10n) =>
          _school.claimableCount > before ? l10n.schoolHintGoal : _hint(l10n),
    );
  }

  /// "▶ Ganhar estrelas": aula rápida num espaço já construído.
  void _quickLesson() {
    final options = _school.lessonSpaces;
    _startLesson(options[Random().nextInt(options.length)]);
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
    _feedback.speech.speak(message);
    await showCelebration(context, message: message, icon: '🎓');
    if (!mounted) return;
    _say(
      (l10n) => result == PromotionResult.promoted
          ? l10n.afterPromotion
          : l10n.afterGraduation,
    );
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      backgroundColor: colors.card,
                      shape: const CircleBorder(),
                      minimumSize: const Size(64, 64),
                    ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Row(
                children: [
                  const GuideAvatar(size: 56),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _bubble(l10n),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                children: [
                  Center(
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
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [
                      for (final space in def.spaces)
                        _Lot(
                          key: ValueKey('lot_${space.id}'),
                          space: space,
                          gradeIcon: def.grades[space.grade].icon,
                          suggested: space.id == suggestion,
                          grown: space.id == _justChanged,
                          onTap: () => _tapSpace(space),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Kids(
                    count: school.kids,
                    label: l10n.schoolKidsLabel(school.kids),
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

/// Um lote da escola: fechado (série futura), vazio (🔨) ou construído
/// (visual do nível + ⭐ do nível, ⬆️ quando dá pra melhorar). O sugerido
/// pulsa com a mão 👆 (seção 6.6).
class _Lot extends ConsumerStatefulWidget {
  const _Lot({
    super.key,
    required this.space,
    required this.gradeIcon,
    required this.suggested,
    required this.grown,
    required this.onTap,
  });

  final SpaceDef space;
  final String gradeIcon;
  final bool suggested;
  final bool grown;
  final VoidCallback onTap;

  @override
  ConsumerState<_Lot> createState() => _LotState();
}

class _LotState extends ConsumerState<_Lot>
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
  void didUpdateWidget(covariant _Lot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (widget.suggested && !reduce) {
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
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final school = ref.read(schoolControllerProvider.notifier);
    final level = ref.watch(schoolControllerProvider).levelOf(widget.space.id);
    final open = school.isOpen(widget.space);
    final canAfford = school.canAfford(widget.space.id);
    final name = l10n.spaceName(widget.space.id);

    final Widget scene;
    final Widget foot;
    if (!open) {
      scene = Opacity(
        opacity: .35,
        child: Text(widget.space.icon, style: const TextStyle(fontSize: 46)),
      );
      foot = Text(widget.gradeIcon, style: const TextStyle(fontSize: 20));
    } else if (level == 0) {
      scene = const Text('🔨', style: TextStyle(fontSize: 46));
      foot = Text(
        '⭐ ${school.costFor(widget.space.id)}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      );
    } else {
      scene = FittedBox(
        child: Text(
          widget.space.levels[level - 1].join(),
          style: const TextStyle(fontSize: 40),
        ),
      );
      foot = Text(
        '${'⭐' * level}${'☆' * (widget.space.maxLevel - level)}',
        style: const TextStyle(fontSize: 16),
      );
    }

    final semanticLabel = !open
        ? l10n.schoolLotLocked(name, l10n.gradeName(widget.space.grade))
        : level == 0
        ? l10n.schoolLotEmpty(name, school.costFor(widget.space.id) ?? 0)
        : l10n.schoolLotLevel(name, level, widget.space.maxLevel);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: widget.grown ? 1.08 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) =>
              Transform.scale(scale: 1 + _pulse.value * .04, child: child),
          child: Material(
            color: open ? colors.card : colors.card.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(26),
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: widget.suggested && open
                      ? Border.all(color: colors.yellow, width: 4)
                      : null,
                ),
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Center(child: scene)),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        foot,
                      ],
                    ),
                    if (open && level > 0 && canAfford)
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: Text('⬆️', style: TextStyle(fontSize: 22)),
                      ),
                    if (widget.suggested && open)
                      const Positioned(
                        bottom: 30,
                        right: 0,
                        child: Text('👆', style: TextStyle(fontSize: 28)),
                      ),
                    if (widget.grown)
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment(0, -.7),
                            child: Text('✨⭐✨', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Folha inferior do espaço (seção 6.6): ▶ Ter aula / ⬆️ Melhorar ⭐N /
/// 🔨 Construir ⭐N; sem estrelas, o botão fica apagado e aparece
/// ▶ Ganhar estrelas.
class _SpaceSheet extends ConsumerWidget {
  const _SpaceSheet({
    required this.space,
    required this.onBuild,
    required this.onLesson,
    required this.onQuickLesson,
    required this.onNeedStars,
  });

  final SpaceDef space;
  final VoidCallback onBuild;
  final VoidCallback onLesson;
  final VoidCallback onQuickLesson;
  final VoidCallback onNeedStars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final school = ref.read(schoolControllerProvider.notifier);
    final level = ref.watch(schoolControllerProvider).levelOf(space.id);
    final cost = school.costFor(space.id);
    final can = school.canAfford(space.id);
    final preview = space.levels[level == 0 ? 0 : level - 1].join(' ');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.schoolClose,
              ),
            ),
            Opacity(
              opacity: level == 0 ? .55 : 1,
              child: Text(
                preview,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 52),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.spaceName(space.id),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(l10n.spaceDesc(space.id), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            if (level == 0) ...[
              _SheetButton(
                key: const ValueKey('sheetBuild'),
                icon: '🔨',
                label: l10n.schoolBuild,
                cost: cost,
                color: colors.green,
                dim: !can,
                onTap: can ? onBuild : onNeedStars,
              ),
              if (!can) ...[
                const SizedBox(height: 10),
                _SheetButton(
                  key: const ValueKey('sheetQuick'),
                  icon: '▶',
                  label: l10n.schoolEarnStars,
                  color: colors.purple,
                  onTap: onQuickLesson,
                ),
              ],
            ] else ...[
              _SheetButton(
                key: const ValueKey('sheetLesson'),
                icon: '▶',
                label: l10n.schoolLesson,
                color: colors.purple,
                onTap: onLesson,
              ),
              const SizedBox(height: 10),
              if (cost == null)
                Text(
                  l10n.schoolMaxed,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                )
              else
                _SheetButton(
                  key: const ValueKey('sheetUpgrade'),
                  icon: '⬆️',
                  label: l10n.schoolUpgrade,
                  cost: cost,
                  color: colors.green,
                  dim: !can,
                  onTap: can ? onBuild : onNeedStars,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.cost,
    this.dim = false,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? cost;

  /// Apagado = faltam estrelas; o toque ainda responde (som + fala), pra a
  /// criança entender o porquê (seção 4.6).
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? .45 : 1,
      child: Material(
        color: color,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                if (cost != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '⭐ $cost',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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

/// População de alunos (Anexo B: `min(14, 2 + soma dos níveis)`).
class _Kids extends StatelessWidget {
  const _Kids({required this.count, required this.label});

  final int count;
  final String label;

  static const _pool = [
    '🧒',
    '👧',
    '👦',
    '🧒🏽',
    '👧🏾',
    '👦🏻',
    '🧒🏿',
    '👧🏼',
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          for (var i = 0; i < count; i++)
            Text(_pool[i % _pool.length], style: const TextStyle(fontSize: 26)),
        ],
      ),
    );
  }
}
