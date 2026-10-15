import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../content/labels.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../celebration/celebration_overlay.dart';
import '../../trail/trail_controller.dart';
import '../activity_shell.dart';
import 'trace_glyphs.dart';

const double _viewBoxSize = 300;
const double _step = 5; // Anexo A
const double _toleranceRadius = 36; // Anexo A
const int _lookaheadWindow = 12; // Anexo A

/// RF-02 — Traçar com caminho imantado (Anexo A): o avanço só ocorre pra
/// frente (sem atalhos), tolerância larga, conclui ao chegar nas 3 últimas
/// amostras.
class TraceScreen extends ConsumerStatefulWidget {
  const TraceScreen({super.key, required this.nodeIndex, required this.glyph});

  final int nodeIndex;
  final String glyph;

  @override
  ConsumerState<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends ConsumerState<TraceScreen> {
  late final Path _path = glyphPath(widget.glyph);
  late final List<Offset> _points = _samplePoints(_path);
  int _idx = 0;
  bool _finished = false;

  static List<Offset> _samplePoints(Path path) {
    final metric = path.computeMetrics().first;
    final total = metric.length;
    final n = (total / _step).floor() + 1;
    return [for (var k = 0; k < n; k++) metric.getTangentForOffset((k * _step).clamp(0, total))!.position];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      ref.read(itemFeedbackProvider).speech.speak(l10n.traceIntro(glyphName(l10n, widget.glyph)));
    });
  }

  /// Seção 4.5: trocar de idioma no meio reinicia o traçado.
  void _restart() {
    setState(() {
      _idx = 0;
      _finished = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ref.read(itemFeedbackProvider).speech.speak(l10n.traceIntro(glyphName(l10n, widget.glyph)));
    });
  }

  void _advance(Offset localInViewBox) {
    if (_finished) return;
    var best = _idx;
    final lim = (_idx + _lookaheadWindow).clamp(0, _points.length - 1);
    for (var j = _idx; j <= lim; j++) {
      if ((_points[j] - localInViewBox).distance < _toleranceRadius) best = j;
    }
    if (best > _idx) {
      setState(() => _idx = best);
      if (_idx >= _points.length - 3) {
        _finished = true;
        setState(() => _idx = _points.length - 1);
        Future.delayed(const Duration(milliseconds: 400), _finish);
      }
    }
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    final isFirst = await ref.read(trailControllerProvider.notifier).complete(widget.nodeIndex);
    if (!mounted) return;
    await showCelebration(context, isFirstCompletion: isFirst, message: l10n.traceDone(glyphName(l10n, widget.glyph)));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Offset _toViewBox(Offset local, double side) => local * (_viewBoxSize / side);

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) _restart();
    });
    final l10n = AppLocalizations.of(context)!;
    final intro = l10n.traceIntro(glyphName(l10n, widget.glyph));
    return ActivityShell(
      bubbleText: intro,
      onRepeat: () => ref.read(itemFeedbackProvider).speech.speak(intro),
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: AppColors.of(context).card, borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.biggest.shortestSide;
              return SizedBox(
                width: side,
                height: side,
                child: GestureDetector(
                  key: const ValueKey('traceCanvas'),
                  onPanStart: (d) => _advance(_toViewBox(d.localPosition, side)),
                  onPanUpdate: (d) => _advance(_toViewBox(d.localPosition, side)),
                  child: CustomPaint(
                    painter: _TracePainter(path: _path, points: _points, idx: _idx),
                    size: Size(side, side),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({required this.path, required this.points, required this.idx});

  final Path path;
  final List<Offset> points;
  final int idx;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _viewBoxSize;
    canvas.save();
    canvas.scale(scale, scale);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF7C5CFF).withValues(alpha: .14) // marca, fixa nos dois temas (seção 9.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 46
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      _dashed(path),
      Paint()
        ..color = const Color(0xFF9D86FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    final metric = path.computeMetrics().first;
    final doneLength = (idx * _step).clamp(0, metric.length).toDouble();
    if (doneLength > 0) {
      final donePath = metric.extractPath(0, doneLength);
      canvas.drawPath(
        donePath,
        Paint()
          ..color = const Color(0xFFFFC93C) // marca, fixa nos dois temas
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (idx <= 2) {
      // Verde de marca, fixo nos dois temas (seção 9.2).
      canvas.drawCircle(points.first, 24, Paint()..color = const Color(0xFF4FCB8D));
    }
    final starCenter = points[idx];
    final textPainter = TextPainter(
      text: const TextSpan(text: '⭐', style: TextStyle(fontSize: 34)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, starCenter - Offset(textPainter.width / 2, textPainter.height / 2));

    canvas.restore();
  }

  Path _dashed(Path source) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final next = (distance + (draw ? 1 : 18)).clamp(0, metric.length).toDouble();
        if (draw) dashed.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) => oldDelegate.idx != idx;
}
