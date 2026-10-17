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
import '../round_dots.dart';

/// RF-03 — Ouvir e tocar: 3 rodadas, 4 cartões (2x2), pedido falado. Segue
/// RT-01 a RT-04 via `ItemFeedback`.
class ListenScreen extends ConsumerStatefulWidget {
  const ListenScreen({super.key, required this.outcome, required this.items});

  final ActivityOutcome outcome;
  final List<String> items;

  @override
  ConsumerState<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends ConsumerState<ListenScreen> {
  static const _rounds = 3;
  final _random = Random();
  late final List<String> _targets = (List.of(
    widget.items,
  )..shuffle(_random)).take(_rounds).toList();
  int _round = 0;
  bool _locked = false;
  List<String> _grid = [];
  String? _hintId;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  /// Seção 4.5: trocar de idioma no meio reinicia a atividade (volta pra
  /// 1ª rodada, mesmos alvos sorteados).
  void _restart() {
    setState(() => _round = 0);
    _newRound();
  }

  void _newRound() {
    _locked = false;
    _hintId = null;
    _grid = List.of(widget.items)..shuffle(_random);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  void _speakPrompt() {
    final l10n = AppLocalizations.of(context)!;
    final content = ref.read(contentRepositoryProvider);
    final item = content.item(_targets[_round]);
    final gender = itemGender(context, item);
    ref
        .read(itemFeedbackProvider)
        .speech
        .speak(l10n.listenPrompt(gender, itemName(l10n, item.id)));
  }

  void _onTapCard(String id) {
    if (_locked) return;
    final feedback = ref.read(itemFeedbackProvider);
    final l10n = AppLocalizations.of(context)!;
    final content = ref.read(contentRepositoryProvider);
    if (id == _targets[_round]) {
      _locked = true;
      feedback.correct(
        itemName(l10n, content.item(id).id),
        randomPraise(l10n, _round + id.length),
      );
      setState(() {});
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_round + 1 >= _rounds) {
          _finish();
        } else {
          setState(() => _round++);
          _newRound();
        }
      });
    } else {
      final target = _targets[_round];
      final tItem = content.item(target);
      feedback.wrong(
        itemName(l10n, content.item(id).id),
        l10n.listenPrompt(itemGender(context, tItem), itemName(l10n, tItem.id)),
      );
      setState(() => _hintId = target);
    }
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    final badge = await widget.outcome.complete(ref);
    if (!mounted) return;
    await showCelebration(context, badge: badge, message: l10n.listenDone);
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
    final prompt = l10n.listenPrompt(
      itemGender(context, target),
      itemName(l10n, target.id),
    );
    return ActivityShell(
      bubbleText: prompt,
      onRepeat: _speakPrompt,
      body: Column(
        children: [
          RoundDots(total: _rounds, current: _round),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                for (final id in _grid)
                  _ListenCard(
                    emoji: content.item(id).emoji,
                    highlighted: id == _hintId,
                    onTap: () => _onTapCard(id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListenCard extends StatelessWidget {
  const _ListenCard({
    required this.emoji,
    required this.highlighted,
    required this.onTap,
  });

  final String emoji;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.of(context).card,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: highlighted
                ? Border.all(color: AppColors.of(context).yellow, width: 7)
                : null,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 64)),
          ),
        ),
      ),
    );
  }
}
