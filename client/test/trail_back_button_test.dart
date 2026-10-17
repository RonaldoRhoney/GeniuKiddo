import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/features/home/home_screen.dart';
import 'package:genius_kiddo/features/trail/trail_screen.dart';

import 'test_harness.dart';

void main() {
  testWidgets(
    'seção 4.10: voltar da trilha leva ao menu; no menu, o voltar não fecha o app',
    (tester) async {
      await pumpAppAtTrail(tester);
      expect(find.byType(TrailScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(TrailScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);

      final popScope = tester.widget<PopScope>(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byType(PopScope),
        ),
      );
      expect(popScope.canPop, isFalse);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets('🏠 na trilha volta ao menu inicial', (tester) async {
    await pumpAppAtTrail(tester);
    await tester.tap(find.byKey(const ValueKey('trailHome')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(TrailScreen), findsNothing);
  });
}
