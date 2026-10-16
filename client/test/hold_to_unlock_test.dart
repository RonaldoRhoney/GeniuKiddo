import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/app/hold_to_unlock.dart';

void main() {
  testWidgets(
    'seção 4.7: só desbloqueia depois de segurar 2 segundos, nunca com um toque rápido',
    (tester) async {
      var unlocked = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HoldToUnlock(onUnlock: () => unlocked++)),
        ),
      );

      // Toque rápido (tap normal) não aciona o long press — não desbloqueia.
      await tester.tap(find.byType(HoldToUnlock));
      await tester.pump();
      expect(unlocked, 0);

      // Segurar e soltar antes de 2s também não desbloqueia.
      final center = tester.getCenter(find.byType(HoldToUnlock));
      var gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 800));
      await gesture.up();
      await tester.pump();
      expect(unlocked, 0);

      // Segurar os 2 segundos inteiros desbloqueia. Pump em passos pequenos —
      // um único pump gigante confunde a âncora de tempo do AnimationController
      // (edge case conhecido, não é bug do widget).
      gesture = await tester.startGesture(center);
      await tester.pump(
        const Duration(milliseconds: 600),
      ); // supera o slop do long press
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      await gesture.up();
      await tester.pump();
      expect(unlocked, 1);
    },
  );
}
