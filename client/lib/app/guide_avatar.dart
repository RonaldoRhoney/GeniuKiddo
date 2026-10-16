import 'package:flutter/material.dart';

/// Personagem-guia (seção 4.2 da especificação): gênio-criança simpático —
/// turbante amarelo com joia coral, corpo roxo, cauda de fumaça azul.
/// Desenho nativo (CustomPainter) fiel ao SVG redesenhado nos protótipos
/// HTML (docs/prototype/) em 13/10/2026 — cabeça grande (proporção de
/// criança), olhos grandes com brilho, bochechas coradas, sorriso largo,
/// bracinhos acenando. Coordenadas no mesmo viewBox 120x132 dos protótipos,
/// escaladas pro tamanho pedido.
class GuideAvatar extends StatelessWidget {
  const GuideAvatar({super.key, this.size = 92});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 132 / 120,
      child: CustomPaint(painter: _GuidePainter()),
    );
  }
}

class _GuidePainter extends CustomPainter {
  static const _purple = Color(0xFF7C5CFF);
  static const _skin = Color(0xFFFFD9B8);
  static const _turban = Color(0xFFFFC93C);
  static const _gem = Color(0xFFFF6B6B);
  static const _smoke = Color(0xFF8FD0FF);
  static const _ink = Color(0xFF2B2D42);
  static const _blush = Color(0xFFFF9AA2);
  static const _mouthShine = Color(0xFFFF95A8);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 120, sy = size.height / 132;
    canvas.save();
    canvas.scale(sx, sy);

    // Cauda de fumaça (atrás do corpo).
    final tail = Path()
      ..moveTo(60, 104)
      ..cubicTo(36, 112, 42, 126, 64, 122)
      ..cubicTo(82, 119, 74, 132, 58, 130);
    canvas.drawPath(
      tail,
      Paint()
        ..color = _smoke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // Corpo.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 98), width: 54, height: 42),
      Paint()..color = _purple,
    );

    // Braços acenando + mãos.
    final armPaint = Paint()
      ..color = _purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(37, 94)
        ..quadraticBezierTo(18, 82, 21, 62),
      armPaint,
    );
    canvas.drawCircle(const Offset(20, 60), 9.5, Paint()..color = _skin);
    canvas.drawPath(
      Path()
        ..moveTo(83, 94)
        ..quadraticBezierTo(102, 82, 99, 62),
      armPaint,
    );
    canvas.drawCircle(const Offset(100, 60), 9.5, Paint()..color = _skin);

    // Cabeça.
    canvas.drawCircle(const Offset(60, 54), 38, Paint()..color = _skin);

    // Bochechas.
    final blushPaint = Paint()..color = _blush.withValues(alpha: .8);
    canvas.drawCircle(const Offset(33, 64), 7.5, blushPaint);
    canvas.drawCircle(const Offset(87, 64), 7.5, blushPaint);

    // Turbante.
    final turban = Path()
      ..moveTo(23, 46)
      ..cubicTo(25, 10, 95, 10, 97, 46)
      ..cubicTo(80, 31, 40, 31, 23, 46)
      ..close();
    canvas.drawPath(turban, Paint()..color = _turban);

    // Joia.
    canvas.drawCircle(const Offset(60, 21), 8.5, Paint()..color = _gem);
    canvas.drawCircle(
      const Offset(57, 18),
      2.6,
      Paint()..color = Colors.white.withValues(alpha: .65),
    );

    // Olhos.
    final eyePaint = Paint()..color = _ink;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(45, 56), width: 13, height: 17),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(75, 56), width: 13, height: 17),
      eyePaint,
    );
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(47.3, 52), 2.4, shinePaint);
    canvas.drawCircle(const Offset(77.3, 52), 2.4, shinePaint);
    final shineSoft = Paint()..color = Colors.white.withValues(alpha: .7);
    canvas.drawCircle(const Offset(43, 59.5), 1.3, shineSoft);
    canvas.drawCircle(const Offset(73, 59.5), 1.3, shineSoft);

    // Sorriso.
    final mouth = Path()
      ..moveTo(45, 70)
      ..quadraticBezierTo(60, 86, 75, 70)
      ..quadraticBezierTo(60, 81, 45, 70)
      ..close();
    canvas.drawPath(mouth, Paint()..color = _ink);
    canvas.drawPath(
      Path()
        ..moveTo(51, 73.5)
        ..quadraticBezierTo(60, 79, 69, 73.5),
      Paint()
        ..color = _mouthShine.withValues(alpha: .6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GuidePainter oldDelegate) => false;
}
