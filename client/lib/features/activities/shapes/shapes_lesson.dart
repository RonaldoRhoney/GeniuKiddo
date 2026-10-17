import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../content/content_repository.dart';
import '../../../content/labels.dart';
import '../../../content/models.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../activity_outcome.dart';
import '../activity_shell.dart';
import '../lesson_common.dart';
import '../round_dots.dart';

/// Sala de aula — formas e cores (seção 6.8, Anexo B). Maternal: 3 formas
/// de cor fixa, pedido pela forma. Pré I: 4 formas de cores distintas,
/// pedido pela forma. Pré II: pedido por forma + cor entre 4 opções (alvo;
/// mesma forma outra cor; outra forma mesma cor; outra forma e cor).
class ShapesLesson extends ConsumerStatefulWidget {
  const ShapesLesson({super.key, required this.grade, required this.outcome});

  final int grade;
  final ActivityOutcome outcome;

  @override
  ConsumerState<ShapesLesson> createState() => _ShapesLessonState();
}

typedef ShapeOption = ({String shape, String color});

/// Cores usadas nas formas (as mesmas da paleta de pintura).
const shapeColorIds = ['red', 'blue', 'yellow', 'green', 'purple'];

/// Sorteio de uma rodada (exposto pra teste).
({ShapeOption target, List<ShapeOption> options}) shapeRound(
  int grade,
  Random random,
) {
  List<T> shuffled<T>(Iterable<T> it) => List.of(it)..shuffle(random);
  if (grade <= 0) {
    const fixed = {'circle': 'red', 'square': 'blue', 'triangle': 'yellow'};
    final options = shuffled([
      for (final e in fixed.entries) (shape: e.key, color: e.value),
    ]);
    return (target: options[random.nextInt(3)], options: options);
  }
  final shapes = shuffled(['circle', 'square', 'triangle', 'star', 'heart']);
  final colors = shuffled(shapeColorIds);
  if (grade == 1) {
    final options = [
      for (var i = 0; i < 4; i++) (shape: shapes[i], color: colors[i]),
    ];
    return (target: options[random.nextInt(4)], options: shuffled(options));
  }
  final target = (shape: shapes[0], color: colors[0]);
  return (
    target: target,
    options: shuffled([
      target,
      (shape: shapes[0], color: colors[1]),
      (shape: shapes[1], color: colors[0]),
      (shape: shapes[2], color: colors[2]),
    ]),
  );
}

class _ShapesLessonState extends ConsumerState<ShapesLesson>
    with ActivityTimers<ShapesLesson> {
  late final int _rounds = ref
      .read(contentRepositoryProvider)
      .school
      .lessonRounds(LessonType.shapes);
  final _random = Random();
  int _round = 0;
  bool _locked = false;
  late ShapeOption _target;
  List<ShapeOption> _options = const [];
  ShapeOption? _hint;
  ShapeOption? _correct;

  bool get _withColor => widget.grade >= 2;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    // Mesma regra da Horta: não repetir o pedido da rodada anterior.
    var r = shapeRound(widget.grade, _random);
    while (_round > 0 && r.target.shape == _target.shape) {
      r = shapeRound(widget.grade, _random);
    }
    setState(() {
      _target = r.target;
      _options = r.options;
      _locked = false;
      _hint = null;
      _correct = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(itemFeedbackProvider).speech.speak(_prompt());
    });
  }

  /// Formas são itens do conteúdo (nome + gênero por idioma) — a
  /// concordância ("a estrela vermelha", "the red star") fica toda no ARB.
  String _gender(ShapeOption o) =>
      itemGender(context, ref.read(contentRepositoryProvider).item(o.shape));

  String _name(ShapeOption o) {
    final l10n = AppLocalizations.of(context)!;
    final shape = itemName(l10n, o.shape);
    if (!_withColor) return shape;
    return l10n.shapeWithColor(
      shape,
      colorAdjective(l10n, o.color, _gender(o)),
    );
  }

  String _prompt() =>
      AppLocalizations.of(context)!
          .listenPrompt(_gender(_target), _name(_target));

  void _onTap(ShapeOption o) {
    if (_locked) return;
    final feedback = ref.read(itemFeedbackProvider);
    final l10n = AppLocalizations.of(context)!;
    if (o == _target) {
      _locked = true;
      setState(() => _correct = o);
      feedback.correct(capitalize(_name(o)), randomPraise(l10n, _round));
      later(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_round + 1 >= _rounds) {
          finishLesson(context, ref, widget.outcome, l10n.shapesDone);
        } else {
          _round++;
          _newRound();
        }
      });
    } else {
      feedback.wrong(_name(o), _prompt());
      setState(() => _hint = _target);
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
    return ActivityShell(
      bubbleText: _prompt(),
      onRepeat: () => ref.read(itemFeedbackProvider).speech.speak(_prompt()),
      body: Column(
        children: [
          RoundDots(total: _rounds, current: _round),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.count(
              // Maternal (3 formas): uma linha só, sem buraco na grade.
              crossAxisCount: _options.length == 3 ? 3 : 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                for (final o in _options)
                  LessonCard(
                    key: ValueKey('shape_${o.shape}_${o.color}'),
                    semanticLabel: _name(o),
                    highlighted: o == _hint,
                    correct: o == _correct,
                    onTap: () => _onTap(o),
                    child: SizedBox.square(
                      dimension: 110,
                      child: CustomPaint(
                        painter: ShapePainter(
                          o.shape,
                          PaintPalette.byId(o.color),
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

/// Mesmas formas do protótipo (viewBox 100x100, contorno escuro).
class ShapePainter extends CustomPainter {
  const ShapePainter(this.shape, this.color);

  final String shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final path = switch (shape) {
      'circle' =>
        Path()
          ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 38)),
      'square' =>
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(14, 14, 72, 72),
            const Radius.circular(8),
          ),
        ),
      'triangle' =>
        Path()
          ..moveTo(50, 10)
          ..lineTo(92, 86)
          ..lineTo(8, 86)
          ..close(),
      'star' => _polygon(const [
        50, 8, 61, 38, 93, 38, 67, 57, 77, 88, //
        50, 69, 23, 88, 33, 57, 7, 38, 39, 38,
      ]),
      _ =>
        Path()
          ..moveTo(50, 86)
          ..cubicTo(10, 58, 8, 28, 30, 22)
          ..cubicTo(42, 19, 50, 28, 50, 34)
          ..cubicTo(50, 28, 58, 19, 70, 22)
          ..cubicTo(92, 28, 90, 58, 50, 86)
          ..close(),
    };
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2B2D42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  static Path _polygon(List<double> p) {
    final path = Path()..moveTo(p[0], p[1]);
    for (var i = 2; i < p.length; i += 2) {
      path.lineTo(p[i], p[i + 1]);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant ShapePainter old) =>
      old.shape != shape || old.color != color;
}
