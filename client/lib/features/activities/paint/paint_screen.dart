import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../content/labels.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../celebration/celebration_overlay.dart';
import '../activity_outcome.dart';
import '../activity_shell.dart';
import '../color_palette.dart';
import 'paint_art.dart';

/// RF-01 — Pintar por toque (Anexo A): regiões pré-definidas, paleta de 6
/// cores, toque na região a preenche, concluída quando todas as regiões
/// forem pintadas, dica (região pisca) após 7s sem interação.
class PaintScreen extends ConsumerStatefulWidget {
  const PaintScreen({super.key, required this.outcome, required this.art});

  final ActivityOutcome outcome;
  final String art;

  @override
  ConsumerState<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends ConsumerState<PaintScreen> {
  static const _colorIds = PaintPalette.ids;

  late final List<PaintRegion> _regions = paintArt(widget.art);
  final Map<String, Color> _painted = {};
  Color _selected = PaintPalette.colors[0];
  String _selectedId = _colorIds[0];
  String? _hintRegionId;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(itemFeedbackProvider)
          .speech
          .speak(AppLocalizations.of(context)!.paintIntro);
    });
    _armHint();
  }

  /// Seção 4.5: "trocar durante uma atividade reinicia essa atividade no
  /// novo idioma" — a pintura já feita se perde de propósito (mesmo
  /// comportamento do protótipo HTML, que chama `startNode` de novo).
  void _restart() {
    setState(() {
      _painted.clear();
      _selected = PaintPalette.colors[0];
      _selectedId = _colorIds[0];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(itemFeedbackProvider)
          .speech
          .speak(AppLocalizations.of(context)!.paintIntro);
    });
    _armHint();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _armHint() {
    _hintTimer?.cancel();
    setState(() => _hintRegionId = null);
    _hintTimer = Timer(const Duration(seconds: 7), () {
      final left = _regions.where((r) => !_painted.containsKey(r.id)).toList();
      if (left.isEmpty || !mounted) return;
      setState(
        () => _hintRegionId = left[DateTime.now().millisecond % left.length].id,
      );
    });
  }

  void _pickColor(int index) {
    setState(() {
      _selected = PaintPalette.colors[index];
      _selectedId = _colorIds[index];
    });
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    feedback.sound.play(FeedbackSound.pop);
    feedback.nameOnly(colorName(l10n, _selectedId));
    _armHint();
  }

  void _onTapUpCanvas(TapUpDetails details, Size renderSize) {
    final scale = paintViewBoxSize / (renderSize.shortestSide);
    // Canvas é sempre desenhado quadrado (ver _SquarePainter abaixo), então
    // a mesma escala vale nos dois eixos.
    final local = details.localPosition * scale;
    for (final region in _regions.reversed) {
      if (region.pathBuilder().contains(local)) {
        if (_painted[region.id] == _selected) return;
        setState(() => _painted[region.id] = _selected);
        ref.read(itemFeedbackProvider).sound.play(FeedbackSound.pop);
        _armHint();
        if (_painted.length == _regions.length) _finish();
        return;
      }
    }
  }

  Future<void> _finish() async {
    _hintTimer?.cancel();
    final l10n = AppLocalizations.of(context)!;
    final badge = await widget.outcome.complete(ref);
    if (!mounted) return;
    await showCelebration(context, badge: badge, message: l10n.paintDone);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) _restart();
    });
    final l10n = AppLocalizations.of(context)!;
    return ActivityShell(
      bubbleText: l10n.paintIntro,
      onRepeat: () =>
          ref.read(itemFeedbackProvider).speech.speak(l10n.paintIntro),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).card,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final side = constraints.biggest.shortestSide;
                  return Center(
                    child: SizedBox(
                      width: side,
                      height: side,
                      child: GestureDetector(
                        key: const ValueKey('paintCanvas'),
                        onTapUp: (d) => _onTapUpCanvas(d, Size(side, side)),
                        child: CustomPaint(
                          painter: _PaintPainter(
                            // Cópia: o pintor anterior guarda o estado de
                            // antes, então `shouldRepaint` vê a mudança.
                            _regions,
                            Map.of(_painted),
                            _hintRegionId,
                          ),
                          size: Size(side, side),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          ColorPaletteBar(
            ids: _colorIds,
            selectedId: _selectedId,
            onPick: _pickColor,
          ),
        ],
      ),
    );
  }
}

class _PaintPainter extends CustomPainter {
  _PaintPainter(this.regions, this.painted, this.hintRegionId);

  final List<PaintRegion> regions;
  final Map<String, Color> painted;
  final String? hintRegionId;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / paintViewBoxSize;
    canvas.save();
    canvas.scale(scale, scale);
    for (final region in regions) {
      final path = region.pathBuilder();
      final isHint = region.id == hintRegionId;
      canvas.drawPath(
        path,
        Paint()
          ..color =
              painted[region.id] ??
              (isHint ? const Color(0xFFFFE39A) : Colors.white)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF2B2D42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PaintPainter oldDelegate) =>
      !_sameColors(oldDelegate.painted, painted) ||
      oldDelegate.hintRegionId != hintRegionId;
}

bool _sameColors(Map<String, Color> a, Map<String, Color> b) =>
    a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
