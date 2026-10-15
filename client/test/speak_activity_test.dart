import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

void main() {
  testWidgets('RF-05: repete as 3 palavras via botão ✓, nunca aciona microfone, conclui a etapa', (tester) async {
    await pumpAppAtTrail(tester, trailDone: 4, stars: 4);

    await tester.tap(find.text('Repetir palavras'));
    await tester.pumpAndSettle();

    expect(find.text('O app não grava a voz da criança'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
    }

    expect(find.text('Você repetiu todas as palavras!'), findsOneWidget);
  });
}
