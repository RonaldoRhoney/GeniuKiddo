import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:genius_kiddo/content/content_repository.dart';
import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/main.dart';

import 'test_harness.dart';

void main() {
  testWidgets(
    'escolher um idioma salva e navega pra trilha com a fala de 1ª vez',
    (tester) async {
      setPhoneSize(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final content = await ContentRepository.load();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            persistenceServiceProvider.overrideWithValue(
              PersistenceService(prefs),
            ),
            contentRepositoryProvider.overrideWithValue(content),
          ],
          child: const GeniusKiddoApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Toque para começar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('langCard_pt')));
      await tester.pumpAndSettle();

      expect(find.text('Oi! Eu sou o Kiddo!'), findsOneWidget);
      expect(PersistenceService(prefs).languageCode, 'pt');
    },
  );
}
