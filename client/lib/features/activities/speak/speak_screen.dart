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

/// RF-05 — Falar (repetir sem gravar): o guia diz a palavra, a criança
/// repete em voz alta e toca num botão grande ✓. ADR-004: nenhum acesso ao
/// microfone, nunca.
class SpeakScreen extends ConsumerStatefulWidget {
  const SpeakScreen({super.key, required this.outcome, required this.items});

  final ActivityOutcome outcome;
  final List<String> items;

  @override
  ConsumerState<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends ConsumerState<SpeakScreen>
    with ActivityTimers<SpeakScreen> {
  int _round = 0;
  bool _locked = false;

  /// Depois do ✓ o balão mostra o elogio que está sendo falado (4.2).
  bool _praised = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  /// Seção 4.5: trocar de idioma no meio reinicia a atividade.
  void _restart() {
    cancelLater();
    setState(() {
      _round = 0;
      _locked = false;
      _praised = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  void _speakPrompt() {
    final l10n = AppLocalizations.of(context)!;
    final item = ref.read(contentRepositoryProvider).item(widget.items[_round]);
    ref
        .read(itemFeedbackProvider)
        .speech
        .speak(l10n.speakPrompt(itemName(l10n, item.id)));
  }

  void _onTapItem() {
    final l10n = AppLocalizations.of(context)!;
    final item = ref.read(contentRepositoryProvider).item(widget.items[_round]);
    ref.read(itemFeedbackProvider).nameOnly(itemName(l10n, item.id));
  }

  void _onConfirm() {
    if (_locked) return;
    _locked = true;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _praised = true);
    ref.read(itemFeedbackProvider).speech.speak(l10n.speakGood);
    later(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      if (_round + 1 >= widget.items.length) {
        _finish();
      } else {
        setState(() {
          _round++;
          _locked = false;
          _praised = false;
        });
        _speakPrompt();
      }
    });
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    final badge = await widget.outcome.complete(ref);
    if (!mounted) return;
    await showCelebration(context, badge: badge, message: l10n.speakDone);
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
    final item = content.item(widget.items[_round]);
    final prompt = l10n.speakPrompt(itemName(l10n, item.id));
    return ActivityShell(
      bubbleText: _praised ? l10n.speakGood : prompt,
      onRepeat: _speakPrompt,
      body: Column(
        children: [
          RoundDots(total: widget.items.length, current: _round),
          const SizedBox(height: 14),
          Expanded(
            child: Material(
              color: AppColors.of(context).card,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _onTapItem,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 150)),
                      const SizedBox(height: 4),
                      Text(
                        itemName(l10n, item.id),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.of(context).purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: AppColors.of(context).green,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _onConfirm,
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Icon(
                  Icons.check_rounded,
                  size: 46,
                  color: Colors.white,
                  semanticLabel: l10n.speakISaidIt,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.speakMicNote,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
