import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/motion.dart';
import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../core/item_feedback.dart';
import '../../core/persistence_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'school_controller.dart';

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
    this.beacon,
    this.onFogTap,
    this.worldChildren = const [],
  });

  /// Espaço brilhante: quando sai da tela, uma seta na borda aponta pra
  /// ele, e o botão 🎯 leva a câmera até lá (RM-03).
  final String? beacon;

  /// Toque nas nuvens de uma série futura (o guia explica quando chega).
  final void Function(int grade)? onFogTap;

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
    with TickerProviderStateMixin {
  final transformation = TransformationController();
  late final AnimationController _flight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  Animation<Matrix4>? _flightTween;
  Size _viewport = Size.zero;
  bool _placed = false;

  /// A criança já arrastou? Antes disso, se a área visível mudar (o balão
  /// do guia cresceu, a tela girou), a câmera volta a centrar o espaço
  /// brilhante.
  bool _userMoved = false;

  /// RM-02: mãozinha de "arraste" até a criança arrastar pela 1ª vez.
  late bool _showHint = !ref.read(persistenceServiceProvider).worldHintSeen;
  late final AnimationController _hand = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  Timer? _hintSpeech;

  WorldDef get _world => ref.read(contentRepositoryProvider).school.world;

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
    if (_showHint) {
      // O laço só roda sem "reduzir movimento" (ver didChangeDependencies).
      // Espera a fala de boas-vindas da escola terminar.
      _hintSpeech = Timer(const Duration(seconds: 4), () {
        if (!mounted || !_showHint) return;
        ref
            .read(itemFeedbackProvider)
            .speech
            .speak(AppLocalizations.of(context)!.worldDragHint);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (_showHint && !reduce && !_hand.isAnimating) _hand.repeat();
    if (reduce) _hand.stop();
  }

  void _onInteractionStart(ScaleStartDetails _) {
    _flight.stop();
    _userMoved = true;
    if (!_showHint) return;
    setState(() => _showHint = false);
    _hand.stop();
    _hintSpeech?.cancel();
    ref.read(persistenceServiceProvider).setWorldHintSeen();
  }

  @override
  void dispose() {
    _hintSpeech?.cancel();
    _hand.dispose();
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
        final resized = _viewport != constraints.biggest;
        _viewport = constraints.biggest;
        if (resized && _placed && !_userMoved && widget.initialFocus != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_userMoved) {
              flyTo(widget.beacon ?? widget.initialFocus!, animate: false);
            }
          });
        }
        if (!_placed && widget.initialFocus != null) {
          _placed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) flyTo(widget.initialFocus!, animate: false);
          });
        }
        final grade = ref.watch(schoolControllerProvider).grade ?? 0;
        final l10n = AppLocalizations.of(context)!;
        final map = ClipRect(
          child: InteractiveViewer(
            transformationController: transformation,
            constrained: false,
            scaleEnabled: false,
            minScale: 1,
            maxScale: 1,
            boundaryMargin: EdgeInsets.zero,
            onInteractionStart: _onInteractionStart,
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
                  // RM-06: séries futuras cobertas por nuvens, que se
                  // abrem ao passar de ano.
                  for (final r in school.regions)
                    Positioned(
                      left: r.x,
                      top: r.y,
                      width: r.width,
                      height: r.height,
                      child: _Fog(
                        key: ValueKey('fog_${r.grade}'),
                        covered: r.grade > grade,
                        onTap: () => widget.onFogTap?.call(r.grade),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
        final beacon = widget.beacon;
        return Stack(
          children: [
            Positioned.fill(child: map),
            if (beacon != null)
              AnimatedBuilder(
                animation: transformation,
                builder: (context, _) => _edgeArrow(beacon, l10n),
              ),
            if (beacon != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: _RoundButton(
                  key: const ValueKey('worldGoToGlow'),
                  label: l10n.worldGoToGlow,
                  onTap: () => flyTo(beacon),
                  child: const Text('🎯', style: TextStyle(fontSize: 30)),
                ),
              ),
            if (_showHint)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _hand,
                    builder: (context, _) {
                      // Desenho de "8" deitado: mostra que dá pra arrastar
                      // pros lados E pra cima e pra baixo.
                      final t = _hand.value * 2 * pi;
                      return Align(
                        alignment: Alignment(sin(t) * .45, sin(2 * t) * .25),
                        child: const Text(
                          '👆',
                          key: ValueKey('worldDragHint'),
                          style: TextStyle(fontSize: 56),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Seta na borda apontando pro espaço brilhante quando ele está fora da
  /// tela; tocar leva a câmera até lá.
  Widget _edgeArrow(String beacon, AppLocalizations l10n) {
    if (_viewport == Size.zero || isVisible(beacon)) {
      return const SizedBox.shrink();
    }
    final s = ref.read(contentRepositoryProvider).school.space(beacon);
    final center = Offset(_viewport.width / 2, _viewport.height / 2);
    final target = Offset(s.x, s.y) - camera;
    final dir = target - center;
    final angle = atan2(dir.dy, dir.dx);
    const inset = 44.0;
    // Ponto da borda (com margem) na direção do espaço.
    final hw = _viewport.width / 2 - inset, hh = _viewport.height / 2 - inset;
    final k = min(
      dir.dx == 0 ? double.infinity : hw / dir.dx.abs(),
      dir.dy == 0 ? double.infinity : hh / dir.dy.abs(),
    );
    final p = center + dir * k;
    return Positioned(
      left: p.dx - 32,
      top: p.dy - 32,
      child: _RoundButton(
        key: const ValueKey('worldEdgeArrow'),
        label: l10n.worldGoToGlow,
        onTap: () => flyTo(beacon),
        child: Transform.rotate(
          angle: angle,
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 34,
            color: AppColors.inkOnBright,
          ),
        ),
      ),
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

/// Botão redondo amarelo de 64 dp (alvo de toque da criança, seção 4.10).
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.of(context).yellow,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(dimension: 64, child: Center(child: child)),
        ),
      ),
    );
  }
}

/// Nuvens sobre a região de uma série futura. Some com um fade ao passar
/// de ano; enquanto cobre, o toque é da nuvem (o guia diz quando chega).
class _Fog extends StatelessWidget {
  const _Fog({super.key, required this.covered, required this.onTap});

  final bool covered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      ignoring: !covered,
      child: AnimatedOpacity(
        opacity: covered ? 1 : 0,
        duration: motion(context, const Duration(milliseconds: 1400)),
        curve: Curves.easeOut,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              decoration: BoxDecoration(
                color: (dark ? const Color(0xFF8A90B8) : Colors.white)
                    .withValues(alpha: .88),
                borderRadius: BorderRadius.circular(90),
              ),
              child: const Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 10,
                  children: [
                    Text('☁️', style: TextStyle(fontSize: 64)),
                    Text('☁️', style: TextStyle(fontSize: 48)),
                    Text('☁️', style: TextStyle(fontSize: 72)),
                    Text('☁️', style: TextStyle(fontSize: 52)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
