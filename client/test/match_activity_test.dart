import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

const _knownItemIds = ['dog', 'cat', 'fish', 'bird', 'apple', 'ball'];

String _currentTargetId(WidgetTester tester) {
  for (final id in _knownItemIds) {
    if (find.byKey(ValueKey('matchTarget_$id')).evaluate().isNotEmpty) return id;
  }
  fail('não achei a chave matchTarget_<id> na tela — alvo da rodada não identificado');
}

void main() {
  testWidgets('RF-04/RT-05: silhueta nunca fala o nome antes de revelada; acerto revela a cor e completa em 3 rodadas', (tester) async {
    final (speech, _) = await pumpAppAtTrail(tester, trailDone: 2, stars: 2);

    await tester.tap(find.text('Quem é a sombra?'));
    await tester.pumpAndSettle();

    for (var round = 0; round < 3; round++) {
      // RT-05: antes do acerto, a silhueta está dentro de um ColorFiltered
      // (preto sólido) — só revela a cor de verdade depois de acertar.
      expect(find.byType(ColorFiltered), findsOneWidget);
      final targetId = _currentTargetId(tester);

      final speechCountBefore = speech.calls.length;
      await tester.tap(find.byKey(ValueKey('matchOption_$targetId')));
      // pumpAndSettle (não um pump(duration) fixo): a transição do
      // AnimatedSwitcher (seção 5.4 revela a figura) só remove o widget
      // antigo da árvore um frame depois dela terminar — um único pump não
      // é suficiente pra isso.
      await tester.pumpAndSettle();

      expect(find.byType(ColorFiltered), findsNothing);
      expect(speech.calls.sublist(speechCountBefore).any((c) => c.clear), isTrue);

      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
    }

    expect(find.text('Você descobriu todas as sombras!'), findsOneWidget);
  });
}
