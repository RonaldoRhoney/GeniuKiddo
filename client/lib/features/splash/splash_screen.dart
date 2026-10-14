import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_avatar.dart';
import '../../app/theme.dart';
import '../../core/language_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../language/language_screen.dart';
import '../trail/trail_screen.dart';

/// Mapa de telas (seção 5.1): Splash ("Toque para começar") é a primeira
/// tela, sempre — nunca pula direto pra trilha, mesmo com idioma salvo
/// (mesmo comportamento dos dois protótipos HTML).
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.light;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _start(context, ref),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              colors: [
                colors.purple.withValues(alpha: .65),
                colors.purple,
                const Color(0xFF5A3FD6),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GuideAvatar(size: MediaQuery.sizeOf(context).width * 0.5),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${l10n.appTitle.split(' ').first} '),
                          TextSpan(
                            text: l10n.appTitle.split(' ').skip(1).join(' '),
                            style: TextStyle(color: colors.yellow),
                          ),
                        ],
                      ),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ) ??
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appTagline,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colors.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 48,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.tapToStart,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _start(BuildContext context, WidgetRef ref) {
    final hasLanguage = ref.read(languageControllerProvider).code != null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            hasLanguage ? const TrailScreen() : const LanguageScreen(),
      ),
    );
  }
}
