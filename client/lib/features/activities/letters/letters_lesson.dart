import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../content/content_repository.dart';
import '../../../content/labels.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../activity_outcome.dart';
import '../activity_shell.dart';
import '../lesson_common.dart';
import '../round_dots.dart';

/// Figuras da Biblioteca (mesma lista do protótipo). A figura é a mesma nos
/// dois idiomas, mas a letra certa sai do NOME NO IDIOMA ATIVO — 🍇 é "U"
/// (uva) em português e "G" (grape) em inglês.
const letterItems = [
  'dog', 'cat', 'fish', 'bird', 'apple', 'banana', 'car', 'ball', 'sun', //
  'flower', 'moon', 'house', 'grape', 'frog', 'duck', 'cow', 'lion', 'egg',
  'bee', 'bear',
];

/// Lê a regra de acentos do idioma (`letterFold` no ARB, pares
/// "á=a,ç=c"). Fica na tradução de propósito: cada idioma decide o que é
/// letra própria (o "ñ" do espanhol não vira "n").
Map<String, String> parseLetterFold(String spec) => {
  for (final pair in spec.split(','))
    if (pair.contains('='))
      pair.split('=')[0].trim().toLowerCase(): pair
          .split('=')[1]
          .trim()
          .toLowerCase(),
};

/// Letra inicial, maiúscula, aplicando a regra de acentos do idioma
/// ("água" → "A" em português).
String initialOf(String word, [Map<String, String> fold = const {}]) {
  final first = String.fromCharCode(word.trim().toLowerCase().runes.first);
  return (fold[first] ?? first).toUpperCase();
}

/// Opções de uma rodada: a letra certa + `count - 1` distratoras, tiradas
/// das iniciais das figuras NO MESMO IDIOMA (nunca de outro), sem repetir e
/// nunca iguais à certa. `names` = nomes das figuras no idioma ativo.
List<String> letterOptions(
  Iterable<String> names,
  String target,
  int count,
  Random random, [
  Map<String, String> fold = const {},
]) {
  final correct = initialOf(target, fold);
  final pool = {for (final n in names) initialOf(n, fold)}..remove(correct);
  final distractors = pool.toList()..shuffle(random);
  return [correct, ...distractors.take(count - 1)]..shuffle(random);
}

/// Biblioteca — com qual letra começa? (seção 6.8, Anexo B): 3 rodadas,
/// 3 opções no Pré I e 4 no Pré II; acerto fala "Cachorro começa com C!".
class LettersLesson extends ConsumerStatefulWidget {
  const LettersLesson({super.key, required this.grade, required this.outcome});

  final int grade;
  final ActivityOutcome outcome;

  @override
  ConsumerState<LettersLesson> createState() => _LettersLessonState();
}

class _LettersLessonState extends ConsumerState<LettersLesson>
    with ActivityTimers<LettersLesson> {
  static const _rounds = 3;
  final _random = Random();
  late final List<String> _targets = (List.of(
    letterItems,
  )..shuffle(_random)).take(_rounds).toList();
  int _round = 0;
  bool _locked = false;
  List<String> _options = const [];
  String? _correct;

  /// Dica (RT-03): depois de um toque fora, a letra certa ganha contorno.
  String? _hint;

  int get _optionCount => widget.grade >= 2 ? 4 : 3;

  Map<String, String> get _fold =>
      parseLetterFold(AppLocalizations.of(context)!.letterFold);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _newRound());
  }

  String _nameOf(String id) => itemName(AppLocalizations.of(context)!, id);
  String get _targetName => _nameOf(_targets[_round]);

  /// Recalculado a cada rodada e a cada troca de idioma — as letras
  /// dependem do idioma, nunca ficam "presas" no anterior.
  void _newRound() {
    if (!mounted) return;
    setState(() {
      _locked = false;
      _correct = null;
      _hint = null;
      _options = letterOptions(
        letterItems.map(_nameOf),
        _targetName,
        _optionCount,
        _random,
        _fold,
      );
    });
    ref.read(itemFeedbackProvider).speech.speak(_prompt());
  }

  String _prompt() =>
      AppLocalizations.of(context)!.lettersPrompt(capitalize(_targetName));

  void _onTap(String letter) {
    if (_locked) return;
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    if (letter == initialOf(_targetName, _fold)) {
      _locked = true;
      setState(() => _correct = letter);
      feedback.correct(
        capitalize(_targetName),
        l10n.lettersCorrect(randomPraise(l10n, _round), letter),
      );
      later(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        if (_round + 1 >= _rounds) {
          finishLesson(context, ref, widget.outcome, l10n.lettersDone);
        } else {
          _round++;
          _newRound();
        }
      });
    } else {
      feedback.wrong(letter, _prompt());
      setState(() => _hint = initialOf(_targetName, _fold));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) {
        cancelLater();
        _round = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) => _newRound());
      }
    });
    final colors = AppColors.of(context);
    final content = ref.watch(contentRepositoryProvider);
    final target = content.item(_targets[_round]);
    return ActivityShell(
      bubbleText: _prompt(),
      onRepeat: () => ref.read(itemFeedbackProvider).speech.speak(_prompt()),
      body: Column(
        children: [
          RoundDots(total: _rounds, current: _round),
          const SizedBox(height: 14),
          Expanded(
            child: Semantics(
              button: true,
              label: capitalize(_targetName),
              child: GestureDetector(
                key: const ValueKey('letterFigure'),
                onTap: () {
                  final feedback = ref.read(itemFeedbackProvider);
                  feedback.sound.play(FeedbackSound.pop);
                  feedback.nameOnly(capitalize(_targetName));
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      target.emoji,
                      style: const TextStyle(fontSize: 120),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final letter in _options)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      height: 96,
                      child: LessonCard(
                        key: ValueKey('letter_$letter'),
                        semanticLabel: letter,
                        correct: letter == _correct,
                        highlighted: letter == _hint,
                        onTap: () => _onTap(letter),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 48,
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
