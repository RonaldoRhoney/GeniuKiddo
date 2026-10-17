import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../core/item_feedback.dart';
import '../../l10n/generated/app_localizations.dart';
import 'school_controller.dart';
import 'school_texts.dart';

/// 🏆 Objetivos do ano (seção 6.7): medalhas, barra de progresso, botão
/// "pegar ⭐+2" quando cumprido e, com os 3 resgatados, 🎓 Passar de ano
/// (ou Formatura no Pré II).
class GoalsSheet extends ConsumerWidget {
  const GoalsSheet({
    super.key,
    required this.onClaimed,
    required this.onPromote,
  });

  final VoidCallback onClaimed;
  final VoidCallback onPromote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final def = ref.watch(contentRepositoryProvider).school;
    final state = ref.watch(schoolControllerProvider);
    final school = ref.read(schoolControllerProvider.notifier);
    final grade = state.grade ?? 0;
    final missions = school.missions;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${def.grades[grade].icon} ${l10n.goalsTitle(l10n.gradeName(grade))}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.schoolClose,
                ),
              ],
            ),
            Text(
              '🏅 ${state.medals}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < missions.length; i++)
              _MissionRow(
                key: ValueKey('mission_$i'),
                icon: missions[i].icon,
                text: l10n.mission(missions[i]),
                progress: school.missionProgress(i).clamp(0, missions[i].n),
                total: missions[i].n,
                done: school.missionDone(i),
                claimed: state.claimed[i],
                locked: !school.missionUnlocked(i),
                lockedLabel: l10n.missionLocked,
                bonus: def.bonus,
                claimLabel: l10n.goalClaim,
                onClaim: () async {
                  if (await school.claim(i)) {
                    ref
                        .read(itemFeedbackProvider)
                        .sound
                        .play(FeedbackSound.win);
                    onClaimed();
                  }
                },
              ),
            const SizedBox(height: 8),
            if (state.graduated)
              Text(
                l10n.graduationDoneNote,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              )
            else if (school.allClaimed)
              SizedBox(
                height: 64,
                child: FilledButton(
                  key: const ValueKey('goalsPromote'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.green,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onPromote,
                  child: Text(
                    '🎓 ${grade < def.lastGrade ? l10n.promoteButton : l10n.graduateButton}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    super.key,
    required this.icon,
    required this.text,
    required this.progress,
    required this.total,
    required this.done,
    required this.claimed,
    required this.locked,
    required this.lockedLabel,
    required this.bonus,
    required this.claimLabel,
    required this.onClaim,
  });

  final String icon;
  final String text;
  final int progress;
  final int total;
  final bool done;
  final bool claimed;

  /// Objetivos em ordem: trancado até o anterior ser resgatado.
  final bool locked;
  final String lockedLabel;
  final int bonus;
  final String claimLabel;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (locked) {
      return Opacity(
        opacity: .5,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🔒', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(lockedLabel, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? colors.green.withValues(alpha: .18) : colors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 1 : progress / total,
                    minHeight: 10,
                    backgroundColor: colors.ink.withValues(alpha: .1),
                    valueColor: AlwaysStoppedAnimation(colors.green),
                  ),
                ),
                const SizedBox(height: 2),
                Text('$progress/$total', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (claimed)
            Text(
              '✓',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: colors.green,
              ),
            )
          else if (done)
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.yellow,
                  shape: const StadiumBorder(),
                ),
                onPressed: onClaim,
                child: Text(
                  '⭐ +$bonus',
                  semanticsLabel: '$claimLabel ⭐ +$bonus',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2D42),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
