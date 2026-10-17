import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_repository.dart';
import '../../app/motion.dart';
import '../../content/labels.dart';
import '../../content/models.dart';
import '../../core/item_feedback.dart';
import '../../l10n/generated/app_localizations.dart';
import '../activities/lesson_common.dart';
import 'school_controller.dart';

/// Bichinhos de cada região (só aparecem quando a região está aberta).
const _animalsByGrade = [
  ['dog', 'cat', 'duck'],
  ['bird', 'frog'],
  ['bee', 'cow'],
];

const _kidFaces = ['🧒', '👧', '👦', '🧒🏽', '👧🏾', '👦🏻', '🧒🏿', '👧🏼'];

/// Vida no cenário (RM-07): alunos passeiam perto dos espaços construídos
/// (a população cresce com a escola, Anexo B) e bichinhos passeiam nas
/// regiões já abertas. Tocar num bichinho fala o nome dele (RT-01); tocar
/// num aluno, uma saudação. Com "reduzir movimento", ficam parados.
class WorldLife extends ConsumerStatefulWidget {
  const WorldLife({super.key});

  @override
  ConsumerState<WorldLife> createState() => _WorldLifeState();
}

typedef _Walker = ({
  String id,
  String emoji,
  Offset home,
  double phase,
  bool kid,
});

class _WorldLifeState extends ConsumerState<WorldLife>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );
  String? _hopping;
  Timer? _hopTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _hopTimer?.cancel();
    _clock.dispose();
    super.dispose();
  }

  /// Pontos fixos (mesma semente) dentro da região, longe dos terrenos.
  List<Offset> _spotsIn(RegionDef r, SchoolDef school, int count, int seed) {
    final rnd = Random(seed);
    final lots = [for (final s in school.spaces) Offset(s.x, s.y)];
    final out = <Offset>[];
    for (var i = 0; i < 200 && out.length < count; i++) {
      final p = Offset(
        r.x + 50 + rnd.nextDouble() * (r.width - 100),
        r.y + 50 + rnd.nextDouble() * (r.height - 100),
      );
      if (lots.any((q) => (q - p).distance < school.world.lotSize * .85)) {
        continue;
      }
      if (out.any((q) => (q - p).distance < 70)) continue;
      out.add(p);
    }
    return out;
  }

  List<_Walker> _walkers(SchoolDef school) {
    final state = ref.read(schoolControllerProvider);
    final ctrl = ref.read(schoolControllerProvider.notifier);
    final grade = state.grade ?? 0;
    final out = <_Walker>[];
    for (final r in school.regions) {
      if (r.grade > grade || r.grade >= _animalsByGrade.length) continue;
      final animals = _animalsByGrade[r.grade];
      final spots = _spotsIn(r, school, animals.length, 11 + r.grade);
      for (var i = 0; i < spots.length; i++) {
        final id = animals[i];
        out.add((
          id: id,
          emoji: ref.read(contentRepositoryProvider).item(id).emoji,
          home: spots[i],
          phase: i * .37 + r.grade * .21,
          kid: false,
        ));
      }
    }
    final built = [
      for (final s in school.spaces)
        if (ctrl.isOpen(s) && state.levelOf(s.id) > 0) s,
    ];
    if (built.isEmpty) return out;
    final half = school.world.lotSize / 2;
    for (var i = 0; i < ctrl.kids; i++) {
      final s = built[i % built.length];
      // Em volta do terreno: embaixo, dos lados, alternando.
      final ring = i ~/ built.length;
      final side = [
        Offset(-half + 20 + ring * 28.0, half + 24),
        Offset(half + 26, -half + 40 + ring * 30.0),
        Offset(-half - 26, -half + 40 + ring * 30.0),
      ][ring % 3];
      out.add((
        id: 'kid_$i',
        emoji: _kidFaces[i % _kidFaces.length],
        home: Offset(s.x, s.y) + side,
        phase: i * .13,
        kid: true,
      ));
    }
    return out;
  }

  void _tap(_Walker w) {
    final l10n = AppLocalizations.of(context)!;
    final feedback = ref.read(itemFeedbackProvider);
    feedback.sound.play(FeedbackSound.pop);
    if (w.kid) {
      feedback.speech.speak(l10n.worldKidHello);
    } else {
      feedback.nameOnly(capitalize(itemName(l10n, w.id)));
    }
    setState(() => _hopping = w.id);
    _hopTimer?.cancel();
    _hopTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _hopping = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final school = ref.watch(contentRepositoryProvider).school;
    ref.watch(schoolControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final walkers = _walkers(school);
    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final t = _clock.value * 2 * pi;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final w in walkers)
              Builder(
                builder: (context) {
                  // Passeio em elipse pequena em volta do ponto de casa;
                  // alunos andam menos que os bichinhos.
                  final a = t + w.phase * 2 * pi;
                  final rx = w.kid ? 14.0 : 46.0, ry = w.kid ? 6.0 : 26.0;
                  final p = w.home + Offset(cos(a) * rx, sin(a) * ry);
                  final size = w.kid ? 28.0 : 40.0;
                  final label = w.kid
                      ? l10n.worldKidLabel
                      : capitalize(itemName(l10n, w.id));
                  return Positioned(
                    left: p.dx - 32,
                    top: p.dy - 32,
                    child: Semantics(
                      button: true,
                      label: label,
                      excludeSemantics: true,
                      child: GestureDetector(
                        key: ValueKey('life_${w.id}'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _tap(w),
                        child: SizedBox.square(
                          // Alvo de toque de 64 dp (4.10), mesmo pros alunos.
                          dimension: 64,
                          child: Center(
                            child: AnimatedSlide(
                              offset: _hopping == w.id
                                  ? const Offset(0, -.5)
                                  : Offset.zero,
                              duration: motion(
                                context,
                                const Duration(milliseconds: 180),
                              ),
                              child: Transform.flip(
                                // Olha pra direção em que anda.
                                flipX: sin(a) > 0,
                                child: Text(
                                  w.emoji,
                                  style: TextStyle(fontSize: size),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
