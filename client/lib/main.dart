import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme.dart';
import 'content/content_repository.dart';
import 'core/audio_services.dart';
import 'core/break_controller.dart';
import 'core/item_feedback.dart';
import 'core/language_controller.dart';
import 'core/persistence_service.dart';
import 'core/theme_controller.dart';
import 'core/tts_speech_port.dart';
import 'features/break/break_overlay.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final content = await ContentRepository.load();
  runApp(
    ProviderScope(
      overrides: [
        persistenceServiceProvider.overrideWithValue(PersistenceService(prefs)),
        contentRepositoryProvider.overrideWithValue(content),
        // M3: troca os backends mudos do M1/M2 pela voz do sistema
        // (flutter_tts) e pelos efeitos reais — nenhuma tela de
        // atividade precisou mudar pra isso (core/item_feedback.dart).
        speechPortProvider.overrideWith(
          (ref) => TtsSpeechPort(FlutterTts(), ref),
        ),
        soundPortProvider.overrideWith((ref) => JustAudioSoundPort()),
      ],
      child: const GeniusKiddoApp(),
    ),
  );
}

class GeniusKiddoApp extends ConsumerStatefulWidget {
  const GeniusKiddoApp({super.key});

  @override
  ConsumerState<GeniusKiddoApp> createState() => _GeniusKiddoAppState();
}

class _GeniusKiddoAppState extends ConsumerState<GeniusKiddoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Seção 4.4: "pausar tudo quando o app vai para segundo plano; retomar
    // ao voltar."
    final music = ref.read(musicControllerProvider.notifier);
    final pause = ref.read(breakControllerProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      music.pauseForBackground();
    } else if (state == AppLifecycleState.resumed) {
      music.resumeFromBackground();
      pause.onForeground();
    }
    // Seção 4.8: só o tempo em primeiro plano conta como uso contínuo
    // (`inactive` fica de fora — é só a cortina de notificações por cima).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      pause.onBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = ref.watch(languageControllerProvider).code;
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Genius Kiddo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      locale: Locale(code ?? 'pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
      // Seção 4.8: quando a pausa sugerida dispara, a sobreposição cobre o
      // app inteiro, acima de qualquer tela ou diálogo aberto.
      builder: (context, child) => Stack(
        children: [
          ?child,
          if (ref.watch(breakControllerProvider)) const BreakOverlay(),
        ],
      ),
    );
  }
}
