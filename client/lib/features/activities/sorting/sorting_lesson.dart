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

const sortFruits = [
  'apple', 'banana', 'grape', 'strawberry', 'orange', 'watermelon', //
];
const sortVeggies = ['carrot', 'broccoli', 'potato', 'lettuce', 'onion'];

/// Sequência da aula (exposto pra teste): 3 frutas e 2 legumes, misturados.
List<({String id, bool fruit})> sortingSequence(Random r) {
  final fruits = (List.of(sortFruits)..shuffle(r)).take(3);
  final veggies = (List.of(sortVeggies)..shuffle(r)).take(2);
  return [
    for (final f in fruits) (id: f, fruit: true),
    for (final v in veggies) (id: v, fruit: false),
  ]..shuffle(r);
}

/// Refeitório — separar frutas e legumes (seção 6.8, Anexo B): 5 itens
/// (3 frutas, 2 legumes) e duas cestas rotuladas por texto (nunca só cor);
/// item na cesta errada gera o som sutil e a dica na cesta certa.
class SortingLesson extends ConsumerStatefulWidget {
  const SortingLesson({super.key, required this.grade, required this.outcome});

  final int grade;
  final ActivityOutcome outcome;

  @override
  ConsumerState<SortingLesson> createState() => _SortingLessonState();
}

class _SortingLessonState extends ConsumerState<SortingLesson>
    with ActivityTimers<SortingLesson> {
  final _random = Random();
  late final _seq = sortingSequence(_random);
  int _round = 0;
  bool _locked = false;
  bool? _hint; // true = cesta de frutas
  bool? _correct;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  ({String id, bool fruit}) get _now => _seq[_round];

  String _prompt() {
    final l10n = AppLocalizations.of(context)!;
    final item = ref.read(contentRepositoryProvider).item(_now.id);
    return l10n.sortPrompt(itemGender(context, item), itemName(l10n, item.id));
  }

  void _speakPrompt() {
    if (mounted) ref.read(itemFeedbackProvider).speech.speak(_prompt());
  }

  void _onBasket(bool fruit) {
    if (_locked) return;
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    final name = itemName(l10n, _now.id);
    if (fruit == _now.fruit) {
      _locked = true;
      setState(() => _correct = fruit);
      feedback.correct(capitalize(name), randomPraise(l10n, _round));
      later(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_round + 1 >= _seq.length) {
          finishLesson(context, ref, widget.outcome, l10n.sortDone);
        } else {
          setState(() {
            _round++;
            _locked = false;
            _hint = null;
            _correct = null;
          });
          _speakPrompt();
        }
      });
    } else {
      feedback.wrong(name, l10n.sortRetry);
      setState(() => _hint = _now.fruit);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) {
        cancelLater();
        setState(() {
          _round = 0;
          _locked = false;
          _hint = null;
          _correct = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
      }
    });
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final item = ref.watch(contentRepositoryProvider).item(_now.id);
    final name = itemName(l10n, item.id);
    return ActivityShell(
      bubbleText: _prompt(),
      onRepeat: _speakPrompt,
      body: Column(
        children: [
          RoundDots(total: _seq.length, current: _round),
          const SizedBox(height: 14),
          Expanded(
            child: Semantics(
              button: true,
              label: name,
              child: GestureDetector(
                key: const ValueKey('sortItem'),
                onTap: () {
                  final feedback = ref.read(itemFeedbackProvider);
                  feedback.sound.play(FeedbackSound.pop);
                  feedback.nameOnly(capitalize(name));
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 110)),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final fruit in [true, false])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _Basket(
                      key: ValueKey(fruit ? 'basketFruits' : 'basketVeggies'),
                      label: fruit ? l10n.sortFruits : l10n.sortVeggies,
                      color: fruit ? colors.coral : const Color(0xFF2FAE72),
                      highlighted: _hint == fruit,
                      correct: _correct == fruit,
                      onTap: () => _onBasket(fruit),
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

class _Basket extends StatelessWidget {
  const _Basket({
    super.key,
    required this.label,
    required this.color,
    required this.highlighted,
    required this.correct,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool highlighted;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Container(
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: correct
                  ? Border.all(color: colors.green, width: 7)
                  : highlighted
                  ? Border.all(color: colors.yellow, width: 7)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🧺', style: TextStyle(fontSize: 44)),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
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
