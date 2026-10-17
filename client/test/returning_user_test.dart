import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

void main() {
  testWidgets('idioma já salvo pula direto pra trilha com a fala de retorno', (
    tester,
  ) async {
    await pumpAppAtHome(tester, languageCode: 'en');
    expect(find.text('Hi! So good to see you!'), findsOneWidget);
  });
}
