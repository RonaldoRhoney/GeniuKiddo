import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

void main() {
  testWidgets(
    'RF-01: pintar todas as regiões conclui a etapa e credita estrela; cor fala com voz clara (RT-01)',
    (tester) async {
      final (speech, _) = await pumpAppAtTrail(tester);

      await tester.tap(find.text('Pintar o jardim'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('azul'));
      await tester.pump();
      expect(speech.calls.last, (text: 'azul', clear: true));

      // As 7 regiões do jardim (paint_art.dart), em frações do viewBox
      // 300x300, uma por região, com um ponto fora do raio de "center" mas
      // dentro de "petals" pra conseguir pintar as duas separadamente.
      final canvasRect = tester.getRect(
        find.byKey(const ValueKey('paintCanvas')),
      );
      Offset at(double fx, double fy) => Offset(
        canvasRect.left + canvasRect.width * fx,
        canvasRect.top + canvasRect.height * fy,
      );
      final points = [
        at(0.10, 0.10), // sky
        at(0.78, 0.20), // sun
        at(0.23, 0.23), // cloud
        at(0.10, 0.90), // ground
        at(0.50, 0.65), // stem
        at(
          0.58,
          0.45,
        ), // petals (fora do raio 14 de center, dentro do 36 de petals)
        at(0.50, 0.45), // center
      ];
      for (final p in points) {
        await tester.tapAt(p);
        await tester.pump(const Duration(milliseconds: 30));
      }

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Que lindo! Você pintou tudo!'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      expect(find.text('⭐'), findsWidgets);
      expect(
        find.byIcon(Icons.check_rounded),
        findsOneWidget,
      ); // ✓ na 1ª etapa concluída
    },
  );
}
