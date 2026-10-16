import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

void main() {
  testWidgets(
    'RF-02: arrastar ao longo do caminho conclui o traçado (avanço, Anexo A)',
    (tester) async {
      // "trace_1" é a 4ª etapa (índice 3) — libera as 3 primeiras direto no
      // estado persistido do teste, pra abrir essa sem precisar jogar as
      // etapas anteriores de verdade.
      await pumpAppAtTrail(tester, trailDone: 3, stars: 3);

      await tester.tap(find.text('Traçar o número 1'));
      await tester.pumpAndSettle();

      final canvasRect = tester.getRect(
        find.byKey(const ValueKey('traceCanvas')),
      );
      // Glifo "1": M105 95 L160 52 L160 250 — viewBox 300x300. Arrasta do
      // início ao fim em passos pequenos (a tolerância é generosa, 36
      // unidades, então não precisa seguir o traço pixel a pixel).
      Offset at(double vx, double vy) => Offset(
        canvasRect.left + canvasRect.width * (vx / 300),
        canvasRect.top + canvasRect.height * (vy / 300),
      );

      final gesture = await tester.startGesture(at(105, 95));
      final waypoints = [
        const Offset(105, 95),
        const Offset(130, 75),
        const Offset(160, 52), // primeiro segmento
        const Offset(160, 110),
        const Offset(160, 170),
        const Offset(160, 230),
        const Offset(160, 250), // segundo segmento
      ];
      for (final w in waypoints) {
        await gesture.moveTo(at(w.dx, w.dy));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Muito bem! Você desenhou o número 1!'), findsOneWidget);
    },
  );
}
