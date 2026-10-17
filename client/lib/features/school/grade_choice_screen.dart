import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/hold_to_unlock.dart';
import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../core/item_feedback.dart';
import '../../l10n/generated/app_localizations.dart';
import 'school_controller.dart';
import 'school_screen.dart';
import 'school_texts.dart';

/// Escolha da série (seção 6.3): tela exclusiva dos pais na primeira
/// entrada na escola — atrás do portão de segurar 2s, pra a criança não
/// escolher sozinha. Só configuração local; nenhuma data de nascimento.
class GradeChoiceScreen extends ConsumerStatefulWidget {
  const GradeChoiceScreen({super.key});

  @override
  ConsumerState<GradeChoiceScreen> createState() => _GradeChoiceScreenState();
}

class _GradeChoiceScreenState extends ConsumerState<GradeChoiceScreen> {
  bool _unlocked = false;

  Future<void> _choose(int grade) async {
    ref.read(itemFeedbackProvider).sound.play(FeedbackSound.pop);
    await ref.read(schoolControllerProvider.notifier).chooseGrade(grade);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SchoolScreen(firstVisit: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final grades = ref.watch(contentRepositoryProvider).school.grades;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(backgroundColor: colors.bg, elevation: 0),
      body: SafeArea(
        top: false,
        child: !_unlocked
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.gradeGateTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.gradeGateHint, textAlign: TextAlign.center),
                      const SizedBox(height: 28),
                      HoldToUnlock(
                        size: 72,
                        semanticLabel: l10n.parentGateLabel,
                        onUnlock: () => setState(() => _unlocked = true),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Text(
                    l10n.gradeChoiceTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.gradeChoiceSubtitle),
                  const SizedBox(height: 20),
                  for (var g = 0; g < grades.length; g++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GradeCard(
                        icon: grades[g].icon,
                        name: l10n.gradeName(g),
                        age: l10n.gradeAge(grades[g].age),
                        onTap: () => _choose(g),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Cartão grande de série (ícone, nome, idade).
class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.icon,
    required this.name,
    required this.age,
    required this.onTap,
  });

  final String icon;
  final String name;
  final String age;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 44)),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                    ),
                  ),
                  Text(
                    age,
                    style: TextStyle(color: colors.ink.withValues(alpha: .7)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
