import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';
import 'school_controller.dart';
import 'school_texts.dart';

/// Folha inferior do espaço (seção 6.6): ▶ Ter aula / ⬆️ Melhorar ⭐N /
/// 🔨 Construir ⭐N; sem estrelas, o botão fica apagado e aparece
/// ▶ Ganhar estrelas.
class SpaceSheet extends ConsumerWidget {
  const SpaceSheet({
    super.key,
    required this.space,
    required this.onBuild,
    required this.onLesson,
    required this.onQuickLesson,
    required this.onNeedStars,
    required this.onLessonElsewhere,
  });

  final SpaceDef space;
  final VoidCallback onBuild;
  final VoidCallback onLesson;
  final VoidCallback onQuickLesson;
  final VoidCallback onNeedStars;

  /// Aulas em ordem: tocou "Ter aula" fora da aula da vez — recebe o id do
  /// espaço da aula da vez pra o guia dizer onde é.
  final void Function(String nextSpaceId) onLessonElsewhere;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final school = ref.read(schoolControllerProvider.notifier);
    final level = ref.watch(schoolControllerProvider).levelOf(space.id);
    final cost = school.costFor(space.id);
    final can = school.canAfford(space.id);
    final preview = space.levels[level == 0 ? 0 : level - 1].join(' ');
    final nextLesson = school.currentLessonSpace();
    final isLessonTurn = nextLesson == space.id;

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
                dim: !isLessonTurn,
                onTap: isLessonTurn || nextLesson == null
                    ? onLesson
                    : () => onLessonElsewhere(nextLesson),
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
