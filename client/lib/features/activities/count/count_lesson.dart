import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../app/motion.dart';
import '../../../content/labels.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../activity_outcome.dart';
import '../activity_shell.dart';
import '../lesson_common.dart';
import '../round_dots.dart';

/// Horta — contar (seção 6.8, Anexo B): a criança toca nas plantinhas pra
/// contar (aparece o número e a fala "um, dois, três…") e escolhe o número.
/// Maternal 1–3 (opções até 4) · Pré I 1–5 (até 6) · Pré II 3–9 (até 10,
/// 4 opções). 3 rodadas, sem repetir o número anterior; acerto faz as
/// plantinhas crescerem (🌱 → 🌻).
class CountLesson extends ConsumerStatefulWidget {
  const CountLesson({super.key, required this.grade, required this.outcome});

  final int grade;
  final ActivityOutcome outcome;

  @override
  ConsumerState<CountLesson> createState() => _CountLessonState();
}

/// Parâmetros por série (exposto pra teste).
({int min, int max, int maxOption, int optionCount}) countParams(int grade) =>
    switch (grade) {
      <= 0 => (min: 1, max: 3, maxOption: 4, optionCount: 3),
      1 => (min: 1, max: 5, maxOption: 6, optionCount: 3),
      _ => (min: 3, max: 9, maxOption: 10, optionCount: 4),
    };

/// Sorteio de uma rodada (exposto pra teste).
({int n, List<int> options}) countRound(int grade, int previous, Random r) {
  final p = countParams(grade);
  int n;
  do {
    n = p.min + r.nextInt(p.max - p.min + 1);
  } while (n == previous);
  final pool = [
    for (var k = 1; k <= p.maxOption; k++)
      if (k != n) k,
  ]..shuffle(r);
  final options = [n, ...pool.take(p.optionCount - 1)]..shuffle(r);
  return (n: n, options: options);
}

class _CountLessonState extends ConsumerState<CountLesson>
    with ActivityTimers<CountLesson> {
  static const _rounds = 3;
  final _random = Random();
  int _round = 0;
  int _previous = 0;
  int _n = 1;
  List<int> _options = const [];

  /// Ordem em que cada plantinha foi tocada (0 = ainda não contada).
  List<int> _countedAt = const [];
  int _counted = 0;
  bool _grown = false;
  bool _locked = false;
  int? _correct;

  /// Dica (RT-03): depois de um toque fora, o número certo ganha contorno.
  int? _hint;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final r = countRound(widget.grade, _previous, _random);
    _previous = r.n;
    setState(() {
      _n = r.n;
      _options = r.options;
      _countedAt = List.filled(r.n, 0);
      _counted = 0;
      _grown = false;
      _locked = false;
      _correct = null;
      _hint = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(itemFeedbackProvider)
          .speech
          .speak(AppLocalizations.of(context)!.countIntro);
    });
  }

  String _word(int k) {
    final words = AppLocalizations.of(context)!.countNumbers.split(',');
    return k < words.length ? words[k] : '$k';
  }

  void _tapPlant(int i) {
    if (_locked) return;
    if (_countedAt[i] != 0) {
      // Já contada: responde mesmo assim (4.6), repetindo o número dela.
      ref.read(itemFeedbackProvider).nameOnly(_word(_countedAt[i]));
      return;
    }
    setState(() {
      _counted++;
      _countedAt = [..._countedAt]..[i] = _counted;
    });
    final feedback = ref.read(itemFeedbackProvider);
    feedback.sound.play(FeedbackSound.pop);
    feedback.nameOnly(_word(_counted));
  }

  void _tapOption(int k) {
    if (_locked) return;
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    if (k == _n) {
      _locked = true;
      setState(() {
        _correct = k;
        _grown = true;
      });
      feedback.correct(_word(k), randomPraise(l10n, _round + k));
      later(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        if (_round + 1 >= _rounds) {
          finishLesson(context, ref, widget.outcome, l10n.countDone);
        } else {
          _round++;
          _newRound();
        }
      });
    } else {
      feedback.wrong(_word(k), l10n.countRetry);
      setState(() => _hint = _n);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) {
        cancelLater();
        _round = 0;
        _newRound();
      }
    });
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return ActivityShell(
      bubbleText: l10n.countIntro,
      onRepeat: () =>
          ref.read(itemFeedbackProvider).speech.speak(l10n.countIntro),
      body: Column(
        children: [
          RoundDots(total: _rounds, current: _round),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.green.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var i = 0; i < _n; i++)
                      Semantics(
                        button: true,
                        label: l10n.countPlant,
                        child: GestureDetector(
                          key: ValueKey('plant_$i'),
                          onTap: () => _tapPlant(i),
                          child: SizedBox(
                            width: 72,
                            height: 84,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedScale(
                                  scale: _grown ? 1.2 : 1,
                                  duration: motion(
                                    context,
                                    const Duration(milliseconds: 400),
                                  ),
                                  child: Text(
                                    _grown ? '🌻' : '🌱',
                                    style: const TextStyle(fontSize: 54),
                                  ),
                                ),
                                if (_countedAt[i] != 0)
                                  Positioned(
                                    top: 0,
                                    right: 4,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: colors.purple,
                                      child: Text(
                                        '${_countedAt[i]}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final k in _options)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      height: 96,
                      child: LessonCard(
                        key: ValueKey('count_$k'),
                        semanticLabel: _word(k),
                        correct: k == _correct,
                        highlighted: k == _hint,
                        onTap: () => _tapOption(k),
                        child: Text(
                          '$k',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
