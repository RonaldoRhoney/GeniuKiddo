import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shake.dart';
import '../../app/theme.dart';
import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';
import 'school_controller.dart';
import 'school_texts.dart';

/// Um lote da escola: fechado (série futura), vazio (🔨) ou construído
/// (visual do nível + ⭐ do nível, ⬆️ quando dá pra melhorar). O sugerido
/// pulsa com a mão 👆 (seção 6.6).
class SchoolLot extends ConsumerStatefulWidget {
  const SchoolLot({
    super.key,
    required this.space,
    required this.gradeIcon,
    required this.suggested,
    required this.grown,
    required this.onTap,
    this.shakes = 0,
  });

  /// Toques com o espaço trancado (dispara o balanço).
  final int shakes;
  final SpaceDef space;
  final String gradeIcon;
  final bool suggested;
  final bool grown;
  final VoidCallback onTap;

  @override
  ConsumerState<SchoolLot> createState() => _SchoolLotState();
}

class _SchoolLotState extends ConsumerState<SchoolLot>
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
  void didUpdateWidget(covariant SchoolLot oldWidget) {
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
    final blocked = open && school.blockedBy(widget.space) != null;
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
    } else if (blocked) {
      scene = Opacity(
        opacity: .35,
        child: Text(widget.space.icon, style: const TextStyle(fontSize: 46)),
      );
      foot = const Text('🔒', style: TextStyle(fontSize: 20));
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
        : blocked
        ? l10n.schoolLotSequenceLocked(name)
        : level == 0
        ? l10n.schoolLotEmpty(name, school.costFor(widget.space.id) ?? 0)
        : l10n.schoolLotLevel(name, level, widget.space.maxLevel);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Shake(
        trigger: widget.shakes,
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
                              child: Text(
                                '✨⭐✨',
                                style: TextStyle(fontSize: 24),
                              ),
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
      ),
    );
  }
}
