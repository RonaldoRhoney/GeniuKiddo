import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/core/item_feedback.dart';

import 'test_harness.dart';

// items.json: dog/cat/fish/bird — nome pt-BR -> emoji, pra achar o cartão
// certo lendo o pedido falado no balão (prompt sorteado a cada rodada).
const _namesToEmoji = {'cachorro': '🐶', 'gato': '🐱', 'peixe': '🐟', 'passarinho': '🐦'};

String? _targetEmojiFromPrompt(WidgetTester tester) {
  for (final entry in _namesToEmoji.entries) {
    if (find.textContaining(entry.key).evaluate().isNotEmpty) return entry.value;
  }
  return null;
}

void main() {
  testWidgets('RF-03: 3 rodadas, acerto avança e chama ItemFeedback.correct (RT-02); erro chama .wrong (RT-03)', (tester) async {
    final (speech, sound) = await pumpAppAtTrail(tester, trailDone: 1, stars: 1);

    await tester.tap(find.text('Ouvir os bichinhos'));
    await tester.pumpAndSettle();

    for (var round = 0; round < 3; round++) {
      final targetEmoji = _targetEmojiFromPrompt(tester);
      expect(targetEmoji, isNotNull, reason: 'não consegui ler o pedido da rodada $round no balão');

      // Toca num cartão qualquer que NÃO seja o alvo primeiro, pra provar
      // RT-03 (som de erro sutil + fala o nome do que foi tocado + repete
      // o pedido, nunca "errou").
      final wrongCandidates = _namesToEmoji.values.where((e) => e != targetEmoji);
      final wrongEmoji = wrongCandidates.first;
      final soundCallsBefore = sound.calls.length;
      await tester.tap(find.text(wrongEmoji));
      await tester.pump(const Duration(milliseconds: 50));
      expect(sound.calls.sublist(soundCallsBefore), contains(FeedbackSound.wrong));

      await tester.tap(find.text(targetEmoji!));
      await tester.pump(const Duration(milliseconds: 50));
      expect(sound.calls.last, FeedbackSound.correct);
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
    }

    expect(find.text('Você ouviu e acertou tudo!'), findsOneWidget);
    expect(speech.calls.any((c) => c.clear), isTrue, reason: 'nome do item deve ser falado com voz clara (RT-01)');
  });
}
