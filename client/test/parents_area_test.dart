import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/features/parents/how_to_use_screen.dart';
import 'package:genius_kiddo/features/parents/parents_area_screen.dart';

import 'test_harness.dart';

Future<void> _holdToUnlock(WidgetTester tester) async {
  final center = tester.getCenter(find.byKey(const ValueKey('parentsEntry')));
  final gesture = await tester.startGesture(center);
  await tester.pump(const Duration(milliseconds: 600));
  // Pump em passos pequenos — um único pump gigante confunde a âncora de
  // tempo do AnimationController (edge case conhecido do widget de teste).
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _openCard(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(ValueKey('parentsCard_$key')));
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

PersistenceService _persistence(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
        .read(persistenceServiceProvider);

void main() {
  testWidgets(
    'seção 4.7: o botão "🔒 Pais" pede segurar — toque rápido só mostra a dica',
    (tester) async {
      await pumpAppAtTrail(tester);
      expect(find.text('Pais'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('parentsEntry')));
      await tester.pump();
      expect(find.byType(ParentsAreaScreen), findsNothing);
      expect(find.text('Segure para abrir'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Pais'), findsOneWidget);
    },
  );

  testWidgets(
    'seção 4.7: Controle dos pais em cartões, com resumo; cada cartão abre a sua tela',
    (tester) async {
      await pumpAppAtTrail(tester);
      await _holdToUnlock(tester);
      expect(find.byType(ParentsAreaScreen), findsOneWidget);
      expect(find.text('Controle dos pais'), findsOneWidget);
      expect(find.byKey(const ValueKey('parentsSummary')), findsOneWidget);
      for (final key in [
        'voice',
        'break',
        'school',
        'progress',
        'appearance',
        'privacy',
        'help',
      ]) {
        expect(
          find.byKey(ValueKey('parentsCard_$key')),
          findsOneWidget,
          reason: key,
        );
      }
      expect(find.byKey(const ValueKey('exitApp')), findsOneWidget);

      await _openCard(tester, 'voice');
      await tester.tap(find.text('Super fofa'));
      await tester.pump();
      expect(_persistence(tester).voiceTone, 'super');
      await tester.tap(find.byKey(const ValueKey('voiceOn')));
      await tester.pump();
      expect(_persistence(tester).voiceEnabled, isFalse);
      await _back(tester);
      expect(find.textContaining('Voz desligada'), findsOneWidget); // resumo

      await _openCard(tester, 'break');
      await tester.tap(find.text('10 minutos'));
      await tester.pump();
      expect(_persistence(tester).breakMinutes, 10);
      await _back(tester);

      await _openCard(tester, 'appearance');
      await tester.tap(find.text('Claro'));
      await tester.pump();
      expect(_persistence(tester).themeModeName, 'light');
      await _back(tester);

      await _openCard(tester, 'privacy');
      expect(find.textContaining('não pede nome'), findsOneWidget);
    expect(find.text('https://ronaldorhoney.github.io/GeniuKiddo/'), findsOneWidget);
    expect(find.byKey(const ValueKey('copyPolicy')), findsOneWidget);
    },
  );

  testWidgets(
    'RF-FASE-03: "liberar todas as etapas" no Progresso, sem dar estrelas',
    (tester) async {
      await pumpAppAtTrail(tester, trailDone: 2, stars: 2);
      await _holdToUnlock(tester);
      await _openCard(tester, 'progress');
      await tester.tap(find.byKey(const ValueKey('unlockTrail')));
      await tester.pump();
      expect(_persistence(tester).trailDone, 8);
      expect(_persistence(tester).stars, 2);
      expect(find.byKey(const ValueKey('unlockTrail')), findsNothing);
    },
  );

  testWidgets('"Como usar": guia para o adulto, com tópicos que abrem', (
    tester,
  ) async {
    await pumpAppAtTrail(tester);
    await _holdToUnlock(tester);
    await tester.tap(find.byKey(const ValueKey('parentsCard_help')));
    await tester.pumpAndSettle();
    expect(find.byType(HowToUseScreen), findsOneWidget);
    expect(find.text('Mapa da escola'), findsOneWidget);
    await tester.tap(find.text('Mapa da escola'));
    await tester.pumpAndSettle();
    expect(find.textContaining('seta amarela'), findsOneWidget);
  });
}
