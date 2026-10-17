import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/app/hold_to_unlock.dart';
import 'package:genius_kiddo/core/break_controller.dart';
import 'package:genius_kiddo/features/break/break_overlay.dart';

import 'test_harness.dart';

const _oneMinute = {'genius_kiddo_break_minutes_v1': 1};

/// Relógio controlado pelo teste (o `pump` só avança os timers falsos, não
/// o `DateTime.now()`).
class _FakeClock {
  DateTime now = DateTime(2026, 10, 16, 9);
  void advance(Duration d) => now = now.add(d);
}

Future<void> _pumpBoth(
  WidgetTester tester,
  _FakeClock clock,
  Duration d,
) async {
  clock.advance(d);
  await tester.pump(d);
}

void _lifecycle(WidgetTester tester, List<AppLifecycleState> states) {
  for (final s in states) {
    tester.binding.handleAppLifecycleStateChanged(s);
  }
}

const _toBackground = [
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
];
const _toForeground = [
  AppLifecycleState.hidden,
  AppLifecycleState.inactive,
  AppLifecycleState.resumed,
];

void main() {
  testWidgets(
    'seção 4.8: pausa sugerida aparece após o tempo configurado e só sai pelo portão',
    (tester) async {
      // 1 minuto pra o teste não esperar os 15 padrão.
      await pumpAppAtTrail(tester, extraPrefs: _oneMinute);

      expect(find.byType(BreakOverlay), findsNothing);

      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      expect(find.byType(BreakOverlay), findsOneWidget);

      // Sem o portão, continua bloqueando a tela.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(BreakOverlay), findsOneWidget);

      final center = tester.getCenter(
        find.descendant(
          of: find.byType(BreakOverlay),
          matching: find.byType(HoldToUnlock),
        ),
      );
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 600));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      await gesture.up();
      await tester.pump();

      expect(find.byType(BreakOverlay), findsNothing);
    },
  );

  testWidgets(
    'seção 4.8: tocar na tela o tempo todo NÃO adia a pausa (uso contínuo)',
    (tester) async {
      await pumpAppAtTrail(tester, extraPrefs: _oneMinute);

      // Criança brincando: um toque a cada 5s durante o minuto inteiro.
      for (var i = 0; i < 12; i++) {
        await tester.tapAt(const Offset(540, 1800));
        await tester.pump(const Duration(seconds: 5));
      }
      await tester.pump();
      expect(find.byType(BreakOverlay), findsOneWidget);
    },
  );

  testWidgets(
    'seção 4.8: segundo plano curto congela a contagem e retoma de onde parou',
    (tester) async {
      final clock = _FakeClock();
      await pumpAppAtTrail(
        tester,
        extraPrefs: _oneMinute,
        overrides: [breakClockProvider.overrideWithValue(() => clock.now)],
      );

      await _pumpBoth(tester, clock, const Duration(seconds: 40));
      _lifecycle(tester, _toBackground);
      // 5 min fora: menos que o limite de descanso, e o tempo fora não conta.
      await _pumpBoth(tester, clock, const Duration(minutes: 5));
      _lifecycle(tester, _toForeground);
      await tester.pump();
      expect(find.byType(BreakOverlay), findsNothing);

      // Faltavam 20s de uso.
      await _pumpBoth(tester, clock, const Duration(seconds: 19));
      expect(find.byType(BreakOverlay), findsNothing);
      await _pumpBoth(tester, clock, const Duration(seconds: 2));
      await tester.pump();
      expect(find.byType(BreakOverlay), findsOneWidget);
    },
  );

  testWidgets(
    'seção 4.8: ficar fora do app por 10 minutos conta como descanso e zera a contagem',
    (tester) async {
      final clock = _FakeClock();
      await pumpAppAtTrail(
        tester,
        extraPrefs: _oneMinute,
        overrides: [breakClockProvider.overrideWithValue(() => clock.now)],
      );

      await _pumpBoth(tester, clock, const Duration(seconds: 50));
      _lifecycle(tester, _toBackground);
      await _pumpBoth(tester, clock, breakRestThreshold);
      _lifecycle(tester, _toForeground);

      // Se não tivesse zerado, a pausa viria em 10s.
      await _pumpBoth(tester, clock, const Duration(seconds: 30));
      await tester.pump();
      expect(find.byType(BreakOverlay), findsNothing);
      await _pumpBoth(tester, clock, const Duration(seconds: 31));
      await tester.pump();
      expect(find.byType(BreakOverlay), findsOneWidget);
    },
  );

  testWidgets(
    'seção 4.8: com a pausa aberta, o voltar do Android não navega por baixo dela',
    (tester) async {
      await pumpAppAtTrail(tester, extraPrefs: _oneMinute);
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      expect(find.byType(BreakOverlay), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      // Continua na trilha, com a pausa por cima.
      expect(find.byKey(const ValueKey('trailHome')), findsOneWidget);
      expect(find.byType(BreakOverlay), findsOneWidget);
    },
  );
}
