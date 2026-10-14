import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/main.dart';

void main() {
  // Janela de teste do tamanho de um celular comum — o padrão (800x600) é
  // baixo demais pro splash (tem rolagem de segurança, mas o botão acaba
  // fora da área visível sem isso) e não representa o alvo real do app.
  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('splash mostra o convite de toque e leva pra escolha de idioma quando não há idioma salvo', (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceServiceProvider.overrideWithValue(PersistenceService(prefs))],
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

  testWidgets('escolher um idioma salva e navega pra tela da trilha (placeholder do M1)', (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceServiceProvider.overrideWithValue(PersistenceService(prefs))],
        child: const GeniusKiddoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toque para começar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oi!'));
    await tester.pumpAndSettle();

    expect(find.text('Oi! Eu sou o Kiddo!'), findsOneWidget);
    expect(PersistenceService(prefs).languageCode, 'pt');
  });

  testWidgets('idioma já salvo pula direto pra trilha com a fala de retorno', (tester) async {
    setPhoneSize(tester);
    SharedPreferences.setMockInitialValues({'genius_kiddo_language_code_v1': 'en'});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceServiceProvider.overrideWithValue(PersistenceService(prefs))],
        child: const GeniusKiddoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tap to start'));
    await tester.pumpAndSettle();

    expect(find.text('Hi! So good to see you!'), findsOneWidget);
  });
}
