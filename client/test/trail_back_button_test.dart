import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

void main() {
  testWidgets(
    'seção 4.10: o botão voltar do Android não fecha o app a partir da trilha',
    (tester) async {
      await pumpAppAtTrail(tester);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);

      // Simula o botão de sistema: a tela continua a mesma, nada fecha.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PopScope), findsOneWidget);
    },
  );
}
