import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/features/trail/trail_controller.dart';

import 'test_harness.dart';

void main() {
  testWidgets('RF-06: rabisco livre não mexe no progresso da trilha e é sempre acessível', (tester) async {
    await pumpAppAtTrail(tester);

    // Sempre liberado mesmo com a trilha inteira travada (nenhuma etapa
    // concluída ainda, trailDone=0 no estado padrão do harness).
    await tester.tap(find.text('Rabisco livre'));
    await tester.pumpAndSettle();

    final canvas = find.byKey(const ValueKey('freeDrawCanvas'));
    await tester.dragFrom(tester.getCenter(canvas), const Offset(80, 40));
    await tester.pump();

    expect(find.byType(CustomPaint), findsWidgets);

    await tester.tap(find.text('limpar'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    expect(container.read(trailControllerProvider).done, 0);
  });
}
