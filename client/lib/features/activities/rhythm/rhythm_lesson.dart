import 'dart:async';
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

/// Pátio — repetir sequência de sons (seção 6.8, Anexo B): 4 botões
/// (vermelho ●, azul ▲, amarelo ■, verde ★; notas 262, 330, 392, 523 Hz).
/// Pré I repete sequências de 2 e 3; Pré II de 3 e 4. Intervalo de 750 ms.
/// Erro só repete a sequência, sem falha. 2 rodadas.
class RhythmLesson extends ConsumerStatefulWidget {
  const RhythmLesson({super.key, required this.grade, required this.outcome});

  final int grade;
  final ActivityOutcome outcome;

  @override
  ConsumerState<RhythmLesson> createState() => _RhythmLessonState();
}

/// Tamanho da sequência de cada rodada (exposto pra teste).
List<int> rhythmLengths(int grade) => grade >= 2 ? const [3, 4] : const [2, 3];

/// Vermelho ●, azul ▲, amarelo ■, verde ★ (Anexo B) — cores da paleta.
final _padColors = [
  for (final id in ['red', 'blue', 'yellow', 'green']) PaintPalette.byId(id),
];
const _padSymbols = ['●', '▲', '■', '★'];
const _padSounds = [
  FeedbackSound.pad0,
  FeedbackSound.pad1,
  FeedbackSound.pad2,
  FeedbackSound.pad3,
];

class _RhythmLessonState extends ConsumerState<RhythmLesson> {
  static const _step = Duration(milliseconds: 750);
  static const _lead = Duration(milliseconds: 1100);
  final _random = Random();
  final List<Timer> _timers = [];
  int _round = 0;
  List<int> _seq = const [];
  int _idx = 0;
  bool _input = false;
  int? _lit;
  String _bubble = '';

  late final List<int> _lengths = rhythmLengths(widget.grade);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _newRound());
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void _later(Duration d, VoidCallback fn) {
    _timers.add(
      Timer(d, () {
        if (mounted) fn();
      }),
    );
  }

  void _say(String text) {
    setState(() => _bubble = text);
    ref.read(itemFeedbackProvider).speech.speak(text);
  }

  void _newRound() {
    if (!mounted) return;
    _seq = List.generate(_lengths[_round], (_) => _random.nextInt(4));
    _play();
  }

  void _play() {
    final l10n = AppLocalizations.of(context)!;
    _cancelTimers();
    _input = false;
    _say(l10n.rhythmWatch);
    for (var k = 0; k < _seq.length; k++) {
      _later(_lead + _step * k, () => _flash(_seq[k]));
    }
    _later(_lead + _step * _seq.length + const Duration(milliseconds: 150), () {
      _input = true;
      _idx = 0;
      _say(l10n.rhythmTurn);
    });
  }

  void _flash(int pad) {
    ref.read(itemFeedbackProvider).sound.play(_padSounds[pad]);
    setState(() => _lit = pad);
    _later(const Duration(milliseconds: 380), () {
      if (_lit == pad) setState(() => _lit = null);
    });
  }

  void _onTap(int pad) {
    if (!_input) {
      // Ainda é a vez do Kiddo mostrar: responde ao toque (4.6) sem
      // tocar a nota, pra não confundir a sequência.
      ref.read(itemFeedbackProvider).sound.play(FeedbackSound.pop);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    _flash(pad);
    if (pad == _seq[_idx]) {
      _idx++;
      if (_idx < _seq.length) return;
      _input = false;
      _later(const Duration(milliseconds: 450), () {
        feedback.sound.play(FeedbackSound.correct);
        _say(randomPraise(l10n, _round));
      });
      _later(const Duration(milliseconds: 2100), () {
        if (_round + 1 >= _lengths.length) {
          finishLesson(context, ref, widget.outcome, l10n.rhythmDone);
        } else {
          setState(() => _round++);
          _newRound();
        }
      });
    } else {
      // Erro só repete a sequência (Anexo B) — nunca "errou".
      _input = false;
      _idx = 0;
      _later(const Duration(milliseconds: 350), () {
        feedback.sound.play(FeedbackSound.wrong);
        _say(l10n.rhythmRetry);
      });
      _later(const Duration(milliseconds: 2400), _play);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) {
        setState(() => _round = 0);
        WidgetsBinding.instance.addPostFrameCallback((_) => _newRound());
      }
    });
    final l10n = AppLocalizations.of(context)!;
    return ActivityShell(
      bubbleText: _bubble,
      onRepeat: () {
        if (_input || _seq.isEmpty) _play();
      },
      body: Column(
        children: [
          RoundDots(total: _lengths.length, current: _round),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                for (var p = 0; p < 4; p++)
                  Semantics(
                    button: true,
                    label: l10n.rhythmPad(p + 1),
                    excludeSemantics: true,
                    child: GestureDetector(
                      key: ValueKey('pad_$p'),
                      onTap: () => _onTap(p),
                      child: AnimatedContainer(
                        duration: motion(
                          context,
                          const Duration(milliseconds: 120),
                        ),
                        decoration: BoxDecoration(
                          color: _lit == p
                              ? Color.lerp(_padColors[p], Colors.white, .45)
                              : _padColors[p],
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            if (_lit != p)
                              const BoxShadow(
                                color: Color(0x33000000),
                                offset: Offset(0, 7),
                              ),
                          ],
                        ),
                        transform:
                            _lit == p &&
                                !MediaQuery.of(context).disableAnimations
                            ? Matrix4.translationValues(0, 5, 0)
                            : Matrix4.identity(),
                        child: Center(
                          child: Text(
                            _padSymbols[p],
                            style: const TextStyle(
                              fontSize: 64,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(l10n.rhythmNote, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
