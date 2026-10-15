import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../content/labels.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../activity_shell.dart';

/// RF-06 — Rabisco livre: pincel grosso, 6 cores, botão limpar, sem salvar
/// nem compartilhar (seção 5.3). Sempre liberado, nunca "concluído" — não
/// mexe em `TrailController`.
class FreeDrawScreen extends ConsumerStatefulWidget {
  const FreeDrawScreen({super.key});

  @override
  ConsumerState<FreeDrawScreen> createState() => _FreeDrawScreenState();
}

class _Stroke {
  _Stroke(this.color);
  final Color color;
  final List<Offset> points = [];
}

class _FreeDrawScreenState extends ConsumerState<FreeDrawScreen> {
  static const _colorIds = ['red', 'blue', 'yellow', 'green', 'purple', 'orange'];

  final List<_Stroke> _strokes = [];
  Color _color = PaintPalette.colors[0];
  String _colorId = _colorIds[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itemFeedbackProvider).speech.speak(AppLocalizations.of(context)!.freeDrawIntro);
    });
  }

  /// Seção 4.5: trocar de idioma no meio reinicia a atividade — mesmo
  /// comportamento do protótipo (`startFree()` de novo, tela limpa).
  void _restart() {
    setState(_strokes.clear);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(itemFeedbackProvider).speech.speak(AppLocalizations.of(context)!.freeDrawIntro);
    });
  }

  void _pickColor(int index) {
    setState(() {
      _color = PaintPalette.colors[index];
      _colorId = _colorIds[index];
    });
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    feedback.sound.play(FeedbackSound.pop);
    feedback.nameOnly(colorName(l10n, _colorId));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LanguageState>(languageControllerProvider, (prev, next) {
      if (prev != null && prev.code != next.code) _restart();
    });
    final l10n = AppLocalizations.of(context)!;
    return ActivityShell(
      bubbleText: l10n.freeDrawIntro,
      onRepeat: () => ref.read(itemFeedbackProvider).speech.speak(l10n.freeDrawIntro),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                color: Colors.white,
                child: GestureDetector(
                  key: const ValueKey('freeDrawCanvas'),
                  onPanStart: (d) => setState(() {
                    _strokes.add(_Stroke(_color)..points.add(d.localPosition));
                  }),
                  onPanUpdate: (d) => setState(() {
                    _strokes.last.points.add(d.localPosition);
                  }),
                  child: CustomPaint(painter: _FreeDrawPainter(_strokes), size: Size.infinite),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: Row(
              children: [
                for (var i = 0; i < _colorIds.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickColor(i),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: PaintPalette.colors[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _colorId == _colorIds[i] ? AppColors.of(context).ink : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(_strokes.clear),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cleaning_services_rounded, size: 32),
                        Text(l10n.freeDrawClear, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Achado real (Rhoney, 14/10/2026): o rabisco livre não tinha
          // nenhum jeito claro de "terminei, posso seguir" — só o ícone
          // pequeno de casa no topo. Mesmo sem contar como etapa concluída
          // (RF-06 continua "sempre liberado, nunca concluído", não mexe
          // em TrailController), a criança precisa de um botão grande e
          // óbvio pra voltar, igual às outras atividades têm ao terminar.
          SizedBox(
            height: 60,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.of(context).green, shape: const StadiumBorder()),
              onPressed: () {
                ref.read(itemFeedbackProvider).sound.play(FeedbackSound.pop);
                ref.read(itemFeedbackProvider).speech.speak(l10n.freeDrawDone);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              label: Text(l10n.freeDrawDone, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeDrawPainter extends CustomPainter {
  _FreeDrawPainter(this.strokes);

  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (var i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, 12, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FreeDrawPainter oldDelegate) => true;
}
