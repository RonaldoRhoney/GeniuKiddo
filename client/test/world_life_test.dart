import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/features/school/world_view.dart';

import 'test_harness.dart';

Future<void> _settle(WidgetTester tester, [int frames = 20]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets(
    'RM-07: bichinhos só nas regiões abertas; tocar fala o nome (RT-01)',
    (tester) async {
      final (speech, _) = await pumpAppAtHome(
        tester,
        trailDone: 8,
        extraPrefs: const {'genius_kiddo_school_v1': '{"grade":0}'},
      );
      await tester.tap(find.byKey(const ValueKey('btnSchool')));
      await _settle(tester);

      expect(find.byKey(const ValueKey('life_dog')), findsOneWidget);
      expect(find.byKey(const ValueKey('life_duck')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('life_bird')),
        findsNothing,
      ); // Pré I, sob nuvens

      final world = tester.state<WorldViewState>(find.byType(WorldView));
      world.transformation.value = Matrix4.identity();
      // Leva a câmera até o cachorro e toca nele.
      final dog = tester.getCenter(find.byKey(const ValueKey('life_dog')));
      final view = tester.getRect(find.byType(InteractiveViewer));
      world.transformation.value = Matrix4.translationValues(
        view.center.dx - dog.dx,
        view.center.dy - dog.dy,
        0,
      );
      await tester.pump();
      speech.calls.clear();
      await tester.tap(
        find.byKey(const ValueKey('life_dog')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(speech.calls.any((c) => c.text == 'Cachorro' && c.clear), isTrue);
    },
  );

  testWidgets('RM-07: a população de alunos acompanha a escola (Anexo B)', (
    tester,
  ) async {
    await pumpAppAtHome(
      tester,
      trailDone: 8,
      extraPrefs: const {
        'genius_kiddo_school_v1': '{"grade":0,"built":{"sala":2,"horta":1}}',
      },
    );
    await tester.tap(find.byKey(const ValueKey('btnSchool')));
    await _settle(tester);
    // min(14, 2 + 3 níveis) = 5 alunos.
    final kids = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey &&
          '${(w.key as ValueKey).value}'.startsWith('life_kid_'),
    );
    expect(kids, findsNWidgets(5));
  });
}
