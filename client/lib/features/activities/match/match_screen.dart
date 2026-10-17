import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../content/content_repository.dart';
import '../../../content/labels.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../celebration/celebration_overlay.dart';
import '../activity_outcome.dart';
import '../activity_shell.dart';
import '../lesson_common.dart';
import '../round_dots.dart';

/// RF-04 — Associar ("quem é a sombra?"): 3 rodadas, silhueta e 3 opções,
/// acerto revela a figura colorida. RT-05: a silhueta só fala o nome DEPOIS
/// de revelada — nunca antes (nunca chamamos `nameOnly` na silhueta).
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key, required this.outcome, required this.items});

  final ActivityOutcome outcome;
  final List<String> items;

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen>
    with ActivityTimers<MatchScreen> {
  static const _rounds = 3;
  final _random = Random();
  late final List<String> _targets = (List.of(
    widget.items,
  )..shuffle(_random)).take(_rounds).toList();
  int _round = 0;
  bool _locked = false;
  bool _revealed = false;

  /// Dica (RT-03): depois de um toque fora, a opção certa ganha contorno.
  String? _hintId;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  /// Seção 4.5: trocar de idioma no meio reinicia a atividade.
  void _restart() {
    cancelLater();
    setState(() => _round = 0);
    _newRound();
  }

  void _newRound() {
    _locked = false;
    _revealed = false;
    _hintId = null;
    final target = _targets[_round];
    final distractors =
        (List.of(widget.items)
              ..remove(target)
              ..shuffle(_random))
            .take(2)
            .toList();
    _options = [target, ...distractors]..shuffle(_random);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  void _speakPrompt() {
    ref
        .read(itemFeedbackProvider)
        .speech
        .speak(AppLocalizations.of(context)!.matchIntro);
  }

  void _onTapOption(String id) {
    if (_locked) return;
    final l10n = AppLocalizations.of(context)!;
    final content = ref.read(contentRepositoryProvider);
    final feedback = ref.read(itemFeedbackProvider);
    final target = _targets[_round];
    if (id == target) {
      _locked = true;
      setState(() => _revealed = true);
      feedback.correct(
        itemName(l10n, content.item(target).id),
        randomPraise(l10n, _round + id.length),
      );
      later(const Duration(milliseconds: 1700), () {
        if (!mounted) return;
        if (_round + 1 >= _rounds) {
          _finish();
        } else {
          setState(() => _round++);
          _newRound();
        }
      });
    } else {
      feedback.wrong(itemName(l10n, content.item(id).id), l10n.matchIntro);
      setState(() => _hintId = _targets[_round]);
    }
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    final badge = await widget.outcome.complete(ref);
    if (!mounted) return;
    await showCelebration(context, badge: badge, message: l10n.matchDone);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) _restart();
    });
    final l10n = AppLocalizations.of(context)!;
    final content = ref.watch(contentRepositoryProvider);
    final target = content.item(_targets[_round]);
    return ActivityShell(
      bubbleText: l10n.matchIntro,
      onRepeat: _speakPrompt,
      body: Column(
        children: [
          RoundDots(total: _rounds, current: _round),
          const SizedBox(height: 14),
          Expanded(
            key: ValueKey('matchTarget_${_targets[_round]}'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).card,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey('${_round}_$_revealed'),
                  // Silhueta (RT-05): filtro de cor substitui todo pixel não
                  // transparente do emoji por preto sólido, igual ao
                  // `filter: brightness(0)` do protótipo — só revela a cor
                  // de verdade depois do acerto.
                  child: _revealed
                      ? Text(
                          target.emoji,
                          style: const TextStyle(fontSize: 120),
                        )
                      : ColorFiltered(
                          // Silhueta na cor do texto: escura no tema claro,
                          // clara no escuro — sempre visível no cartão.
                          colorFilter: ColorFilter.mode(
                            AppColors.of(context).ink,
                            BlendMode.srcIn,
                          ),
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
          SizedBox(
            height: 110,
            child: Row(
              children: [
                for (final id in _options)
                  Expanded(
                    key: ValueKey('matchOption_$id'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: LessonCard(
                        semanticLabel: itemName(
                          AppLocalizations.of(context)!,
                          id,
                        ),
                        highlighted: id == _hintId,
                        onTap: () => _onTapOption(id),
                        child: Text(
                          content.item(id).emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
