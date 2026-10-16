import 'package:flutter/material.dart';

/// Uma região pintável (equivalente a `<g class="reg" data-n="...">` nos
/// protótipos HTML) — viewBox fixo 300x300, igual ao Anexo A.
class PaintRegion {
  const PaintRegion(this.id, this.pathBuilder);

  final String id;
  final Path Function() pathBuilder;
}

const double paintViewBoxSize = 300;

Path _rect(double x, double y, double w, double h) =>
    Path()..addRect(Rect.fromLTWH(x, y, w, h));
Path _rrect(double x, double y, double w, double h, double r) => Path()
  ..addRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
  );
Path _circle(double cx, double cy, double r) =>
    Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

List<PaintRegion> paintArt(String artId) => switch (artId) {
  'garden' => [
    PaintRegion('sky', () => _rect(0, 0, 300, 215)),
    PaintRegion('sun', () => _circle(235, 62, 36)),
    PaintRegion(
      'cloud',
      () => Path()
        ..moveTo(45, 92)
        ..quadraticBezierTo(34, 66, 62, 62)
        ..quadraticBezierTo(70, 34, 102, 42)
        ..quadraticBezierTo(130, 32, 140, 60)
        ..quadraticBezierTo(168, 62, 160, 92)
        ..close(),
    ),
    PaintRegion('ground', () => _rect(0, 215, 300, 85)),
    PaintRegion('stem', () => _rect(144, 160, 12, 80)),
    PaintRegion('petals', () => _circle(150, 135, 36)),
    PaintRegion('center', () => _circle(150, 135, 14)),
  ],
  'house' => [
    PaintRegion('sky', () => _rect(0, 0, 300, 215)),
    PaintRegion('ground', () => _rect(0, 215, 300, 85)),
    PaintRegion('wall', () => _rect(75, 130, 150, 100)),
    PaintRegion(
      'roof',
      () => Path()
        ..moveTo(58, 134)
        ..lineTo(150, 64)
        ..lineTo(242, 134)
        ..close(),
    ),
    PaintRegion('door', () => _rrect(134, 170, 34, 60, 4)),
    PaintRegion('window1', () => _rrect(92, 150, 28, 28, 3)),
    PaintRegion('window2', () => _rrect(180, 150, 28, 28, 3)),
  ],
  _ => throw StateError('arte de pintura desconhecida: $artId'),
};
