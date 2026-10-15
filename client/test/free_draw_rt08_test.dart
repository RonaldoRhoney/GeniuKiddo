import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/core/item_feedback.dart';
import 'package:genius_kiddo/features/trail/trail_controller.dart';

import 'test_harness.dart';

void main() {
  testWidgets('RT-08: botão ✓ fica desabilitado em branco e celebra sem estrela ao desenhar', (tester) async {
    final (speech, sound) = await pumpAppAtTrail(tester);

    await tester.tap(find.text('Rabisco livre'));
    await tester.pumpAndSettle();

    final completionButton = find.byIcon(Icons.check_rounded);
    expect(completionButton, findsOneWidget);

    // Tela em branco: tocar no ✓ é erro sutil + fala de incentivo, sem navegar.
    speech.calls.clear();
    sound.calls.clear();
    await tester.tap(completionButton);
    await tester.pump();
    expect(sound.calls, contains(FeedbackSound.wrong));
    expect(speech.calls.last.text, 'Desenhe um pouquinho primeiro!');
    expect(find.byKey(const ValueKey('freeDrawCanvas')), findsOneWidget);

    // Depois de um traço, o ✓ liga e a celebração usa 🎨, sem "+1"/estrela.
    final canvas = find.byKey(const ValueKey('freeDrawCanvas'));
    await tester.dragFrom(tester.getCenter(canvas), const Offset(80, 40));
    await tester.pump();

    await tester.tap(completionButton);
    await tester.pumpAndSettle();

    expect(find.text('🎨'), findsOneWidget);
    expect(find.text('Que desenho lindo!'), findsOneWidget);
    expect(find.text('+1'), findsNothing);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    expect(container.read(trailControllerProvider).done, 0);
  });
}
