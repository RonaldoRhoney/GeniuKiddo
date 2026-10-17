import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/features/school/school_controller.dart';
import 'package:genius_kiddo/features/school/school_screen.dart';
import 'package:genius_kiddo/features/school/world_view.dart';

import 'test_harness.dart';

Future<void> _settle(WidgetTester tester, [int frames = 20]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Celular pequeno em pé (360 × 640 dp), pra o mapa ser bem maior que a tela.
void _smallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(720, 1280);
  tester.view.devicePixelRatio = 2.0;
}

Future<void> _openSchool(WidgetTester tester, String state) async {
  await pumpAppAtHome(
    tester,
    trailDone: 8,
    extraPrefs: {'genius_kiddo_school_v1': state},
  );
  _smallPhone(tester);
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('btnSchool')));
  await _settle(tester);
}

void main() {
  testWidgets(
    'RM-01/RM-04: mapa arrastável nos dois eixos, sem zoom por pinça',
    (tester) async {
      await _openSchool(tester, '{"grade":0}');
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.scaleEnabled, isFalse);
      expect(viewer.panEnabled, isTrue);
      expect(viewer.constrained, isFalse);
    },
  );

  testWidgets('ao entrar, a câmera mostra o espaço brilhante', (tester) async {
    // Sala com aula e 6 ⭐: o sugerido é construir a Horta.
    await _openSchool(
      tester,
      '{"grade":0,"stars":6,"lessonsBySpace":{"sala":1},"lastLessonSpace":"sala"}',
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SchoolScreen)),
    );
    final suggestion = container
        .read(schoolControllerProvider.notifier)
        .suggestion()!;
    expect(suggestion, 'horta');
    final world = tester.state<WorldViewState>(find.byType(WorldView));
    expect(world.isVisible('horta'), isTrue);
  });

  testWidgets('RM-03: o voo leva a câmera até um espaço longe da tela', (
    tester,
  ) async {
    await _openSchool(tester, '{"grade":0}');
    final world = tester.state<WorldViewState>(find.byType(WorldView));
    expect(world.isVisible('refeit'), isFalse);
    world.flyTo('refeit');
    await _settle(tester, 10);
    expect(world.isVisible('refeit'), isTrue);
    expect(world.isVisible('sala'), isFalse);
  });

  testWidgets(
    'RM-03: seta na borda aparece com o espaço brilhante fora da tela e leva até ele',
    (tester) async {
      await _openSchool(
        tester,
        '{"grade":0,"stars":6,"lessonsBySpace":{"sala":1},"lastLessonSpace":"sala"}',
      );
      final world = tester.state<WorldViewState>(find.byType(WorldView));
      expect(find.byKey(const ValueKey('worldEdgeArrow')), findsNothing);
      expect(find.byKey(const ValueKey('worldGoToGlow')), findsOneWidget);

      world.flyTo('refeit', animate: false); // longe da Horta (brilhante)
      await tester.pump();
      expect(find.byKey(const ValueKey('worldEdgeArrow')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('worldEdgeArrow')));
      await _settle(tester, 10);
      expect(world.isVisible('horta'), isTrue);
      expect(find.byKey(const ValueKey('worldEdgeArrow')), findsNothing);

      // 🎯 também volta pro brilhante a qualquer momento.
      world.flyTo('refeit', animate: false);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('worldGoToGlow')));
      await _settle(tester, 10);
      expect(world.isVisible('horta'), isTrue);
    },
  );

  testWidgets(
    'RM-06: nuvens cobrem as séries futuras; tocar nelas explica quando chegam',
    (tester) async {
      await _openSchool(tester, '{"grade":0}');
      double opacityOf(int g) => tester
          .widget<AnimatedOpacity>(
            find.descendant(
              of: find.byKey(ValueKey('fog_$g')),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;
      expect(opacityOf(0), 0);
      expect(opacityOf(1), 1);
      expect(opacityOf(2), 1);

      final world = tester.state<WorldViewState>(find.byType(WorldView));
      world.flyTo('biblio', animate: false);
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('fog_1')),
        warnIfMissed: false,
      );
      await _settle(tester, 5);
      expect(
        find.text('Esse espaço chega no Pré I! Vamos passar de ano!'),
        findsOneWidget,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SchoolScreen)),
      );
      await container.read(schoolControllerProvider.notifier).chooseGrade(1);
      await _settle(tester, 20);
      expect(opacityOf(1), 0);
      expect(opacityOf(2), 1);
    },
  );

  testWidgets('RM-02: mãozinha de arrastar só até o primeiro arrasto', (
    tester,
  ) async {
    await _openSchool(tester, '{"grade":0}');
    expect(find.byKey(const ValueKey('worldDragHint')), findsOneWidget);
    await tester.drag(find.byType(InteractiveViewer), const Offset(-120, -160));
    await _settle(tester, 10);
    expect(find.byKey(const ValueKey('worldDragHint')), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SchoolScreen)),
    );
    expect(container.read(persistenceServiceProvider).worldHintSeen, isTrue);
  });
}
