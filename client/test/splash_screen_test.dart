import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:genius_kiddo/content/content_repository.dart';
import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/main.dart';

import 'test_harness.dart';

// Cada marco de navegação (Splash → Idioma, escolher idioma → Trilha,
// idioma já salvo → Trilha) fica em arquivo próprio — rodar os três juntos
// no mesmo `main()` trava o `pumpAndSettle()` da 2ª/3ª verificação neste
// ambiente (achado real, 14/10/2026); isolado, cada um passa em ~1s. Não é
// bug do app (confirmado rodando no celular de verdade), é alguma
// interação do test runner entre múltiplos testes no mesmo arquivo.
void main() {
  testWidgets('splash mostra o convite de toque e leva pra escolha de idioma quando não há idioma salvo', (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final content = await ContentRepository.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceServiceProvider.overrideWithValue(PersistenceService(prefs)),
          contentRepositoryProvider.overrideWithValue(content),
        ],
        child: const GeniusKiddoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toque para começar'), findsOneWidget);

    await tester.tap(find.text('Toque para começar'));
    await tester.pumpAndSettle();

    expect(find.text('Oi!'), findsOneWidget);
    expect(find.text('Hi!'), findsOneWidget);
  });
}
