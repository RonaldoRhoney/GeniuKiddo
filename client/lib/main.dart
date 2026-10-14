import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme.dart';
import 'core/language_controller.dart';
import 'core/persistence_service.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [persistenceServiceProvider.overrideWithValue(PersistenceService(prefs))],
      child: const GeniusKiddoApp(),
    ),
  );
}

class GeniusKiddoApp extends ConsumerWidget {
  const GeniusKiddoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seção 4.5: um idioma por vez, nunca o locale do sistema operacional —
    // só o que a criança/pais escolheram (ou pt-BR, idioma-base, enquanto
    // ninguém escolheu nada ainda).
    final code = ref.watch(languageControllerProvider).code;
    return MaterialApp(
      title: 'Genius Kiddo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      locale: Locale(code ?? 'pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
