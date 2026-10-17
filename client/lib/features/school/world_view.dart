import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';

/// Mapa livre da escola (M6, seção 7): o mundo é maior que a tela e a
/// criança arrasta em qualquer direção, com inércia (RM-01), sem zoom por
/// pinça (RM-04). Os espaços ficam em terrenos fixos (RM-05) ligados por um
/// caminho na ordem de liberação (RT-09). `flyTo` leva a câmera até um
/// espaço — nada depende só de arrastar (RM-03/RM-08).
class WorldView extends ConsumerStatefulWidget {
  const WorldView({
    super.key,
    required this.lotBuilder,
    this.initialFocus,
    this.worldChildren = const [],
  });

  /// Constrói o terreno de um espaço (o mapa só posiciona).
  final Widget Function(SpaceDef space) lotBuilder;

  /// Espaço que a câmera mostra ao abrir (o espaço brilhante).
  final String? initialFocus;

  /// Camadas extras em coordenadas do mundo (alunos, bichinhos, nuvens).
  final List<Widget> worldChildren;

  @override
  ConsumerState<WorldView> createState() => WorldViewState();
}

class WorldViewState extends ConsumerState<WorldView>
    with SingleTickerProviderStateMixin {
  final transformation = TransformationController();
  late final AnimationController _flight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  Animation<Matrix4>? _flightTween;
  Size _viewport = Size.zero;
  bool _placed = false;

  WorldDef get _world => ref.read(contentRepositoryProvider).school.world;

  /// Tamanho visível do mapa (pra camadas que acompanham a câmera).
  Size get viewport => _viewport;

  /// Canto superior esquerdo da câmera, em coordenadas do mundo.
  Offset get camera {
    final t = transformation.value.getTranslation();
    return Offset(-t.x, -t.y);
  }

  /// Parte do mundo visível agora.
  Rect get visibleRect => camera & _viewport;

  @override
  void initState() {
    super.initState();
    _flight.addListener(() {
      final tween = _flightTween;
      if (tween != null) transformation.value = tween.value;
    });
  }

  @override
  void dispose() {
    _flight.dispose();
    transformation.dispose();
    super.dispose();
  }

  Matrix4 _matrixCentering(Offset worldPoint) {
    final maxX = max(0.0, _world.width - _viewport.width);
    final maxY = max(0.0, _world.height - _viewport.height);
    final x = (worldPoint.dx - _viewport.width / 2).clamp(0.0, maxX);
    final y = (worldPoint.dy - _viewport.height / 2).clamp(0.0, maxY);
    return Matrix4.translationValues(-x, -y, 0);
  }

  /// Leva a câmera até o espaço (voo curto; instantâneo com "reduzir
  /// movimento" ligado ou `animate: false`).
  void flyTo(String spaceId, {bool animate = true}) {
    if (_viewport == Size.zero) return;
    final space = ref.read(contentRepositoryProvider).school.space(spaceId);
    final target = _matrixCentering(Offset(space.x, space.y));
    final reduce = MediaQuery.of(context).disableAnimations;
    if (!animate || reduce) {
      _flight.stop();
      transformation.value = target;
      return;
    }
    _flightTween = Matrix4Tween(
      begin: transformation.value,
      end: target,
    ).animate(CurvedAnimation(parent: _flight, curve: Curves.easeInOut));
    _flight.forward(from: 0);
  }

  /// O espaço aparece inteiro na tela agora?
  bool isVisible(String spaceId) {
    final school = ref.read(contentRepositoryProvider).school;
    final s = school.space(spaceId);
    final half = school.world.lotSize / 2;
    return visibleRect.contains(Offset(s.x - half, s.y - half)) &&
        visibleRect.contains(Offset(s.x + half, s.y + half));
  }

  @override
  Widget build(BuildContext context) {
    final school = ref.watch(contentRepositoryProvider).school;
    final world = school.world;
    final colors = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        if (!_placed && widget.initialFocus != null) {
          _placed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) flyTo(widget.initialFocus!, animate: false);
          });
        }
        return ClipRect(
          child: InteractiveViewer(
            transformationController: transformation,
            constrained: false,
            scaleEnabled: false,
            minScale: 1,
            maxScale: 1,
            boundaryMargin: EdgeInsets.zero,
            child: SizedBox(
              width: world.width,
              height: world.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GroundPainter(school, colors, dark),
                    ),
                  ),
                  ..._decor(school),
                  for (final s in school.spaces)
                    Positioned(
                      left: s.x - world.lotSize / 2,
                      top: s.y - world.lotSize / 2,
                      width: world.lotSize,
                      height: world.lotSize,
                      child: widget.lotBuilder(s),
                    ),
                  ...widget.worldChildren,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Árvores e flores fixas (mesma semente sempre), longe dos terrenos e
  /// do caminho — só enfeite, sem toque e sem leitura de tela.
  List<Widget> _decor(SchoolDef school) {
    final r = Random(7);
    final world = school.world;
    final points = [for (final s in school.spaces) Offset(s.x, s.y)];
    const items = ['🌳', '🌲', '🌷', '🌼', '🍄', '🌳', '🪨', '🌻'];
    final out = <Widget>[];
    for (var i = 0; i < 160 && out.length < 46; i++) {
      final p = Offset(
        r.nextDouble() * world.width,
        r.nextDouble() * world.height,
      );
      final nearLot = points.any((q) => (q - p).distance < world.lotSize * .9);
      if (nearLot || _distanceToPath(p, points) < 60) continue;
      out.add(
        Positioned(
          left: p.dx - 20,
          top: p.dy - 20,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Text(
                items[r.nextInt(items.length)],
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
        ),
      );
    }
    return out;
  }

  static double _distanceToPath(Offset p, List<Offset> pts) {
    var best = double.infinity;
    for (var i = 0; i + 1 < pts.length; i++) {
      final a = pts[i], b = pts[i + 1];
      final ab = b - a;
      final t =
          (((p - a).dx * ab.dx + (p - a).dy * ab.dy) /
                  (ab.distanceSquared == 0 ? 1 : ab.distanceSquared))
              .clamp(0.0, 1.0);
      best = min(best, (p - (a + ab * t)).distance);
    }
    return best;
  }
}

/// Chão do mapa: grama, uma mancha mais clara por série e o caminho de
/// terra ligando os espaços na ordem do `school.json`.
class _GroundPainter extends CustomPainter {
  _GroundPainter(this.school, this.colors, this.dark);

  final SchoolDef school;
  final AppColors colors;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final grass = dark ? const Color(0xFF24402F) : const Color(0xFFA8E6A1);
    final patch = dark ? const Color(0xFF2D4F3A) : const Color(0xFFBDF0B5);
    final dirt = dark ? const Color(0xFF6B5A3E) : const Color(0xFFE8C994);
    final dirtEdge = dark ? const Color(0xFF54462F) : const Color(0xFFD4B074);

    canvas.drawRect(Offset.zero & size, Paint()..color = grass);
    for (final r in school.regions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(r.x, r.y, r.width, r.height),
          const Radius.circular(80),
        ),
        Paint()..color = patch,
      );
    }

    final pts = [for (final s in school.spaces) Offset(s.x, s.y)];
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final prev = pts[i - 1], cur = pts[i];
      // Curva suave: controle deslocado pro lado, pra não virar reta.
      final mid = (prev + cur) / 2;
      final normal = Offset(-(cur - prev).dy, (cur - prev).dx) * .18;
      final ctrl = mid + normal;
      path.quadraticBezierTo(ctrl.dx, ctrl.dy, cur.dx, cur.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = dirtEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 54
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = dirt
        ..style = PaintingStyle.stroke
        ..strokeWidth = 42
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GroundPainter old) =>
      old.dark != dark || old.school != school;
}
