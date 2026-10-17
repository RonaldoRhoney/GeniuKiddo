import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:genius_kiddo/content/content_repository.dart';
import 'package:genius_kiddo/core/item_feedback.dart';
import 'package:genius_kiddo/core/persistence_service.dart';
import 'package:genius_kiddo/main.dart';

class FakeSpeechPort implements SpeechPort {
  final List<({String text, bool clear})> calls = [];
  @override
  void speak(String text, {bool clear = false}) =>
      calls.add((text: text, clear: clear));
}

class FakeSoundPort implements SoundPort {
  final List<FeedbackSound> calls = [];
  @override
  void play(FeedbackSound sound) => calls.add(sound);
}

void setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Sobe o app de verdade (mesmo `ContentRepository.load()` que o `main.dart`
/// usa, lendo os JSON reais de `assets/content/`) direto na Trilha, com
/// idioma já escolhido — pula Splash/Idioma pra ir direto ao que cada teste
/// de atividade precisa exercitar.
Future<(FakeSpeechPort, FakeSoundPort)> pumpAppAtHome(
  WidgetTester tester, {
  String languageCode = 'pt',
  int trailDone = 0,
  int stars = 0,
  Map<String, Object> extraPrefs = const {},
  List<Override> overrides = const [],
}) async {
  setPhoneSize(tester);
  SharedPreferences.setMockInitialValues({
    'genius_kiddo_language_code_v1': languageCode,
    'genius_kiddo_trail_done_v1': trailDone,
    'genius_kiddo_stars_v1': stars,
    ...extraPrefs,
  });
  // `runAsync`: leitura real de asset fora do relógio falso do teste —
  // sem isso, um segundo `testWidgets` no mesmo arquivo trava aqui.
  final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
  final content = (await tester.runAsync(ContentRepository.load))!;
  final speech = FakeSpeechPort();
  final sound = FakeSoundPort();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        persistenceServiceProvider.overrideWithValue(PersistenceService(prefs)),
        contentRepositoryProvider.overrideWithValue(content),
        speechPortProvider.overrideWithValue(speech),
        soundPortProvider.overrideWithValue(sound),
        ...overrides,
      ],
      child: const GeniusKiddoApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.text(languageCode == 'en' ? 'Tap to start' : 'Toque para começar'),
  );
  await tester.pumpAndSettle();
  return (speech, sound);
}

/// Igual a `pumpAppAtHome`, mas já entra na Trilha pelo cartão do menu.
Future<(FakeSpeechPort, FakeSoundPort)> pumpAppAtTrail(
  WidgetTester tester, {
  String languageCode = 'pt',
  int trailDone = 0,
  int stars = 0,
  Map<String, Object> extraPrefs = const {},
  List<Override> overrides = const [],
}) async {
  final ports = await pumpAppAtHome(
    tester,
    languageCode: languageCode,
    trailDone: trailDone,
    stars: stars,
    extraPrefs: extraPrefs,
    overrides: overrides,
  );
  await tester.tap(find.byKey(const ValueKey('homeTrail')));
  await tester.pumpAndSettle();
  return ports;
}
