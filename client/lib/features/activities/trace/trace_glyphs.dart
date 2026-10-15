import 'package:flutter/material.dart';

/// Glifos (Anexo A) — mesmo viewBox 300x300 e mesmos pontos dos protótipos.
/// 'O' reconstruído com `arcToPoint` (equivalente exato ao comando SVG `A`
/// do protótipo: raio 88x100, large-arc, sentido horário), não como uma
/// elipse solta, pra manter o ponto de partida (150,50) igual ao original.
Path glyphPath(String glyph) => switch (glyph) {
      '1' => Path()
        ..moveTo(105, 95)
        ..lineTo(160, 52)
        ..lineTo(160, 250),
      'O' => Path()
        ..moveTo(150, 50)
        ..arcToPoint(const Offset(150, 250), radius: const Radius.elliptical(88, 100), largeArc: true, clockwise: true)
        ..arcToPoint(const Offset(150, 50), radius: const Radius.elliptical(88, 100), largeArc: true, clockwise: true),
      _ => throw StateError('glifo desconhecido: $glyph'),
    };
