import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../content/labels.dart';
import '../../../core/item_feedback.dart';
import '../../../core/language_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../celebration/celebration_overlay.dart';
import '../activity_shell.dart';
import '../color_palette.dart';

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
  static const _colorIds = PaintPalette.ids;

  final List<_Stroke> _strokes = [];
  Color _color = PaintPalette.colors[0];
  String _colorId = _colorIds[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(itemFeedbackProvider)
          .speech
          .speak(AppLocalizations.of(context)!.freeDrawIntro);
    });
  }

  /// Seção 4.5: trocar de idioma no meio reinicia a atividade — mesmo
  /// comportamento do protótipo (`startFree()` de novo, tela limpa).
  void _restart() {
    setState(_strokes.clear);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(itemFeedbackProvider)
          .speech
          .speak(AppLocalizations.of(context)!.freeDrawIntro);
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
      onRepeat: () =>
          ref.read(itemFeedbackProvider).speech.speak(l10n.freeDrawIntro),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    color: Colors.white,
                    child: GestureDetector(
                      key: const ValueKey('freeDrawCanvas'),
                      onPanStart: (d) => setState(() {
                        _strokes.add(
                          _Stroke(_color)..points.add(d.localPosition),
                        );
                      }),
                      onPanUpdate: (d) => setState(() {
                        _strokes.last.points.add(d.localPosition);
                      }),
                      child: CustomPaint(
                        painter: _FreeDrawPainter(_strokes),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _CompletionButton(
                    hasDrawn: _strokes.isNotEmpty,
                    onTap: _onCompletionTap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ColorPaletteBar(
            ids: _colorIds,
            selectedId: _colorId,
            onPick: _pickColor,
            trailing: Semantics(
              button: true,
              label: l10n.freeDrawClear,
              excludeSemantics: true,
              child: GestureDetector(
                key: const ValueKey('freeDrawClear'),
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(_strokes.clear),
                child: SizedBox(
                  width: 64,
                  height: 76,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cleaning_services_rounded, size: 32),
                      Text(
                        l10n.freeDrawClear,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// RT-08 (seção 4.11): tocar com a tela em branco é erro sutil + fala de
  /// incentivo, sem navegar; tocar depois de desenhar é uma celebração
  /// curta com o ícone próprio da atividade (🎨), sem estrela, e o ▶ volta
  /// à tela anterior (o menu inicial) — não conta como etapa (RF-06).
  Future<void> _onCompletionTap() async {
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    if (_strokes.isEmpty) {
      feedback.sound.play(FeedbackSound.wrong);
      feedback.speech.speak(l10n.freeDrawFirst);
      return;
    }
    await showCelebration(context, icon: '🎨', message: l10n.freeDrawCelebrate);
    if (mounted) Navigator.of(context).pop();
  }
}

class _CompletionButton extends StatelessWidget {
  const _CompletionButton({required this.hasDrawn, required this.onTap});

  final bool hasDrawn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedOpacity(
      opacity: hasDrawn ? 1 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: colors.green,
        shape: const CircleBorder(),
        elevation: hasDrawn ? 4 : 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 84,
            height: 84,
            child: Icon(Icons.check_rounded, size: 44, color: Colors.white),
          ),
        ),
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
        canvas.drawCircle(
          stroke.points.first,
          12,
          paint..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FreeDrawPainter oldDelegate) => true;
}
