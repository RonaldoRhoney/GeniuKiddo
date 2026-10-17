import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/app/hold_to_unlock.dart';
import 'package:genius_kiddo/features/activities/count/count_lesson.dart';
import 'package:genius_kiddo/features/school/school_controller.dart';
import 'package:genius_kiddo/features/school/grade_choice_screen.dart';
import 'package:genius_kiddo/features/school/school_screen.dart';

import 'test_harness.dart';

/// A escola tem animação contínua (sugestão pulsando), então
/// `pumpAndSettle` nunca terminaria lá — avança o tempo em passos.
Future<void> _settle(WidgetTester tester, [int frames = 20]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _hold(WidgetTester tester, Finder finder) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  await tester.pump(const Duration(milliseconds: 600));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await gesture.up();
  await _settle(tester);
}

void main() {
  testWidgets(
    'RF-FASE-01: sem concluir a trilha, a Escolinha fica trancada no menu',
    (tester) async {
      await pumpAppAtHome(tester, trailDone: 3);
      // O cartão aparece trancado: tocar não abre, o guia explica.
      await tester.tap(find.byKey(const ValueKey('btnSchool')));
      await _settle(tester);
      expect(find.byType(SchoolScreen), findsNothing);
      expect(find.byType(GradeChoiceScreen), findsNothing);
    },
  );

  testWidgets(
    'seção 6: trilha concluída → portão → série → escola; Horta trancada até a 1ª aula na Sala',
    (tester) async {
      await pumpAppAtHome(tester, trailDone: 8);
      await tester.tap(find.byKey(const ValueKey('btnSchool')));
      await _settle(tester);

      // Tela dos pais: a criança não escolhe sem o portão.
      expect(find.text('Maternal'), findsNothing);
      await _hold(tester, find.byType(HoldToUnlock));
      await tester.tap(find.text('Maternal'));
      await _settle(tester);

      expect(find.byType(SchoolScreen), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SchoolScreen)),
      );
      expect(container.read(schoolControllerProvider).grade, 0);
      expect(container.read(schoolControllerProvider).stars, 3);

      // Ordem de liberação: Horta só depois da Sala ter 1 aula.
      await tester.tap(find.byKey(const ValueKey('lot_horta')));
      await _settle(tester);
      expect(find.byKey(const ValueKey('sheetBuild')), findsNothing);
      expect(find.text('Ainda não! Primeiro: Sala de aula.'), findsOneWidget);
      expect(container.read(schoolControllerProvider).stars, 3);

      // Espaço de série futura: não abre folha, só a fala encorajadora.
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('lot_biblio')),
        200,
        scrollable: find
            .descendant(
              of: find.byType(SchoolScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byKey(const ValueKey('lot_biblio')));
      await _settle(tester);
      expect(find.byKey(const ValueKey('sheetBuild')), findsNothing);
      expect(find.textContaining('Pré I'), findsWidgets);
    },
  );

  testWidgets(
    'seção 6.5: aula da Horta concluída rende +3 ⭐ e conta no objetivo do ano',
    (tester) async {
      await pumpAppAtHome(
        tester,
        trailDone: 8,
        extraPrefs: const {
          'genius_kiddo_school_v1': '{"grade":0,"stars":0,"built":{"sala":1,"horta":1},"lessonsBySpace":{"sala":1},"lastLessonSpace":"sala"}',
        },
      );
      await tester.tap(find.byKey(const ValueKey('btnSchool')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('lot_horta')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('sheetLesson')));
      await _settle(tester);
      expect(find.byType(CountLesson), findsOneWidget);

      for (var round = 0; round < 3; round++) {
        final n = find
            .byWidgetPredicate(
              (w) =>
                  w.key is ValueKey &&
                  '${(w.key as ValueKey).value}'.startsWith('plant_'),
            )
            .evaluate()
            .length;
        await tester.tap(find.byKey(ValueKey('count_$n')));
        await tester.pump(const Duration(milliseconds: 1900));
        await _settle(tester);
      }
      // Celebração com +3: toca ▶ e volta pra escola.
      expect(find.text('+3'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await _settle(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SchoolScreen)),
      );
      expect(container.read(schoolControllerProvider).stars, 3);
      expect(container.read(schoolControllerProvider).lessonsYear, 1);
    },
  );

  testWidgets(
    'RF-FASE-03: os pais liberam a Escolinha antes da trilha acabar',
    (tester) async {
      await pumpAppAtHome(tester, trailDone: 2);
      await _hold(tester, find.byType(HoldToUnlock));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('unlockSchool')),
        200,
      );
      await tester.tap(find.byKey(const ValueKey('unlockSchool')));
      await _settle(tester);
      expect(find.text('Série da criança'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await _settle(tester);
      expect(find.text('🏫'), findsOneWidget); // cartão destrancado no menu
    },
  );

  testWidgets(
    'seção 4.5: trocar o idioma na escola traduz o balão do guia na hora',
    (tester) async {
      await pumpAppAtHome(
        tester,
        trailDone: 8,
        extraPrefs: const {'genius_kiddo_school_v1': '{"grade":0}'},
      );
      await tester.tap(find.byKey(const ValueKey('btnSchool')));
      await _settle(tester);
      expect(
        find.text('Oi! Que bom te ver! Vamos cuidar da nossa escola?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Hi!'));
      await _settle(tester);
      expect(
        find.text('Hi! So good to see you! Shall we take care of our school?'),
        findsOneWidget,
      );
      expect(
        find.text('Oi! Que bom te ver! Vamos cuidar da nossa escola?'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'aulas em ordem: fora da aula da vez, ▶ Ter aula não abre e o guia diz onde é',
    (tester) async {
      await pumpAppAtHome(
        tester,
        trailDone: 8,
        extraPrefs: const {
          'genius_kiddo_school_v1': '{"grade":0,"stars":0,"built":{"sala":1,"horta":1},"lessonsBySpace":{"sala":1},"lastLessonSpace":"sala"}',
        },
      );
      await tester.tap(find.byKey(const ValueKey('btnSchool')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('lot_sala')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('sheetLesson')));
      await _settle(tester);
      expect(find.byType(CountLesson), findsNothing);
      expect(find.text('A próxima aula é: Horta!'), findsOneWidget);
    },
  );
}
