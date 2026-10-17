import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/app/hold_to_unlock.dart';
import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/features/parents/parents_area_screen.dart';

import 'test_harness.dart';

Future<void> _holdToUnlock(WidgetTester tester) async {
  final center = tester.getCenter(find.byType(HoldToUnlock));
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

void main() {
  testWidgets(
    'seção 4.7: o cadeado leva à área dos pais, com som/voz, pausa, progresso e privacidade',
    (tester) async {
      await pumpAppAtTrail(tester);

      await _holdToUnlock(tester);
      expect(find.byType(ParentsAreaScreen), findsOneWidget);
      expect(find.text('Área dos pais'), findsWidgets);
      expect(find.text('Pausa sugerida'), findsOneWidget);
      expect(find.text('Privacidade'), findsOneWidget);

      // Trocar o tom de voz e a duração da pausa escreve na persistência.
      await tester.tap(find.text('Super fofa'));
      await tester.tap(find.text('10 minutos'));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ParentsAreaScreen)),
      );
      final persistence = container.read(persistenceServiceProvider);
      expect(persistence.voiceTone, 'super');
      expect(persistence.breakMinutes, 10);
    },
  );

  testWidgets(
    'seção 4.7: voz liga/desliga e "liberar todas as etapas" sem dar estrelas',
    (tester) async {
      await pumpAppAtTrail(tester, trailDone: 2, stars: 2);
      await _holdToUnlock(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ParentsAreaScreen)),
      );
      final persistence = container.read(persistenceServiceProvider);

      await tester.tap(find.byKey(const ValueKey('voiceOn')));
      await tester.pump();
      expect(persistence.voiceEnabled, isFalse);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('unlockTrail')),
        200,
      );
      await tester.tap(find.byKey(const ValueKey('unlockTrail')));
      await tester.pump();
      expect(persistence.trailDone, 8);
      expect(persistence.stars, 2); // liberar não dá estrela
      expect(find.byKey(const ValueKey('unlockTrail')), findsNothing);
    },
  );
}
